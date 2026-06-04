from flask import Flask, render_template, request, redirect, session, flash
import sqlite3
from collections import defaultdict, OrderedDict

app = Flask(__name__)
app.secret_key = "unimas_secret_key"

DATABASE = "database.db"
TOTAL_GRAD_CREDITS = 120
MAX_ELECTIVES = 3
MAX_ELECTIVE_CLUSTERS = 2
INDUSTRIAL_CODE = "TMF39412"
PASS_GRADES = {"A", "A-", "B+", "B", "B-", "C+", "C", "D", "E"}
GRADE_POINTS = {
    "A": 4.0, "A-": 3.7, "B+": 3.3, "B": 3.0,
    "B-": 2.7, "C+": 2.3, "C": 2.0, "D": 1.7, "E": 1.0, "F": 0.0
}


def get_db():
    conn = sqlite3.connect(DATABASE)
    conn.row_factory = sqlite3.Row
    return conn

def sync_student_academic_record(conn, student_id):
    cgpa, credits_completed, attempted_credits, failed_count = calculate_academic_totals(conn, student_id)

    conn.execute("""
        UPDATE students
        SET cgpa=?, credits_completed=?
        WHERE id=?
    """, (cgpa, credits_completed, student_id))

    return cgpa, credits_completed

def absolute_semester(year_no, semester_no):
    return ((int(year_no) - 1) * 2) + int(semester_no)


def semester_to_year_semester(abs_sem):
    """Convert absolute semester number to Year/Semester pair."""
    abs_sem = int(abs_sem)
    year_no = ((abs_sem - 1) // 2) + 1
    semester_no = 1 if abs_sem % 2 == 1 else 2
    return year_no, semester_no


def sync_student_current_semester(conn, student_id):
    """Move student to next semester after latest submitted result."""
    student = conn.execute("""
        SELECT current_year, current_semester
        FROM students
        WHERE id=?
    """, (student_id,)).fetchone()

    if not student:
        return 1

    stored_sem = absolute_semester(
        student["current_year"],
        student["current_semester"]
    )

    latest_result_sem = conn.execute("""
        SELECT MAX(semester)
        FROM results
        WHERE student_id=?
    """, (student_id,)).fetchone()[0]

    if latest_result_sem is None:
        return stored_sem

    detected_sem = int(latest_result_sem) + 1

    if detected_sem > stored_sem:
        new_year, new_semester = semester_to_year_semester(detected_sem)

        conn.execute("""
            UPDATE students
            SET current_year=?, current_semester=?
            WHERE id=?
        """, (new_year, new_semester, student_id))

        return detected_sem

    return stored_sem



def credit_limit(cgpa):
    cgpa = float(cgpa or 0)
    if cgpa > 2.50:
        return 20
    if cgpa >= 2.00:
        return 15
    return 12


def latest_results(conn, student_id):
    """Return the latest attempt for each subject using highest semester, then highest id.
    This prevents an older failed attempt inserted later from overriding a passed retake.
    """
    return conn.execute("""
        SELECT r.*
        FROM results r
        JOIN (
            SELECT course_code, MAX(semester) AS latest_semester
            FROM results
            WHERE student_id=?
            GROUP BY course_code
        ) latest_sem ON latest_sem.course_code = r.course_code
                    AND latest_sem.latest_semester = r.semester
        JOIN (
            SELECT course_code, semester, MAX(id) AS max_id
            FROM results
            WHERE student_id=?
            GROUP BY course_code, semester
        ) latest_id ON latest_id.course_code = r.course_code
                   AND latest_id.semester = r.semester
                   AND latest_id.max_id = r.id
        WHERE r.student_id=?
        ORDER BY r.semester, r.course_code
    """, (student_id, student_id, student_id)).fetchall()


def latest_result_map(conn, student_id):
    return {r["course_code"]: r for r in latest_results(conn, student_id)}


def calculate_academic_totals(conn, student_id):
    rows = conn.execute("""
        SELECT r.course_code, r.grade, c.credit
        FROM results r
        JOIN (
            SELECT course_code, MAX(semester) AS latest_semester
            FROM results
            WHERE student_id=?
            GROUP BY course_code
        ) latest_sem ON latest_sem.course_code = r.course_code
                    AND latest_sem.latest_semester = r.semester
        JOIN (
            SELECT course_code, semester, MAX(id) AS max_id
            FROM results
            WHERE student_id=?
            GROUP BY course_code, semester
        ) latest_id ON latest_id.course_code = r.course_code
                   AND latest_id.semester = r.semester
                   AND latest_id.max_id = r.id
        JOIN courses c ON c.code = r.course_code
        WHERE r.student_id=?
    """, (student_id, student_id, student_id)).fetchall()

    attempted_points = 0.0
    attempted_credits = 0
    passed_credits = 0
    failed_count = 0

    for r in rows:
        grade = (r["grade"] or "").upper()
        credit = int(r["credit"] or 0)
        if grade in GRADE_POINTS:
            attempted_points += GRADE_POINTS[grade] * credit
            attempted_credits += credit
        if grade != "F":
            passed_credits += credit
        else:
            failed_count += 1

    cgpa = round(attempted_points / attempted_credits, 2) if attempted_credits else 0.00
    return cgpa, passed_credits, attempted_credits, failed_count


def elective_rule_ok(conn, student_id, new_code=None):
    rows = conn.execute("""
        SELECT c.code, c.cluster_no
        FROM student_elective_choices s
        JOIN courses c ON c.code=s.course_code
        WHERE s.student_id=?
    """, (student_id,)).fetchall()

    codes = {r["code"] for r in rows}
    clusters = {r["cluster_no"] for r in rows if r["cluster_no"] is not None}

    if new_code:
        if new_code in codes:
            return False, "This elective has already been added."
        e = conn.execute("SELECT code, cluster_no FROM courses WHERE code=? AND category='Elective'", (new_code,)).fetchone()
        if not e:
            return False, "Invalid elective subject."
        codes.add(new_code)
        if e["cluster_no"] is not None:
            clusters.add(e["cluster_no"])

    if len(codes) > MAX_ELECTIVES:
        return False, "You can only take maximum 3 elective subjects."
    if len(clusters) > MAX_ELECTIVE_CLUSTERS:
        return False, "Your electives can only come from maximum 2 clusters."
    return True, ""


def plan_semester_credit(conn, student_id, semester):
    return conn.execute("""
        SELECT COALESCE(SUM(c.credit), 0)
        FROM study_plan sp
        JOIN courses c ON c.code=sp.course_code
        WHERE sp.student_id=? AND sp.semester=?
          AND sp.status NOT LIKE 'Blocked%'
    """, (student_id, semester)).fetchone()[0] or 0

def get_programme_curriculum(conn, programme):

    return conn.execute("""

        SELECT
            c.*,
            pc.year_no,
            pc.semester_no,
            (((pc.year_no - 1) * 2) + pc.semester_no) AS curriculum_sem

        FROM programme_courses pc

        JOIN courses c
        ON c.code = pc.course_code

        WHERE pc.programme_code=?

        ORDER BY
            pc.year_no,
            pc.semester_no,
            c.code

    """, (programme,)).fetchall()

def get_prereqs(conn, programme, course_code):
    return conn.execute("""
        SELECT prerequisite_code
        FROM course_prerequisites
        WHERE course_code=?
        AND (programme_code=? OR programme_code='ALL')
    """, (course_code, programme)).fetchall()

@app.route("/")
def index():
    return render_template("index.html")


@app.route("/student_login", methods=["GET", "POST"])
def student_login():
    if request.method == "POST":
        matric_no = request.form["matric_no"]
        password = request.form["password"]
        conn = get_db()
        student = conn.execute("SELECT * FROM students WHERE matric_no=? AND password=?", (matric_no, password)).fetchone()
        conn.close()
        if student:
            session["student_id"] = student["id"]
            return redirect("/dashboard")
        flash("Invalid student login.")
    return render_template("login.html", role="Student")


@app.route("/admin_login", methods=["GET", "POST"])
def admin_login():
    if request.method == "POST":
        username = request.form["username"]
        password = request.form["password"]
        conn = get_db()
        admin = conn.execute("SELECT * FROM admins WHERE username=? AND password=?", (username, password)).fetchone()
        conn.close()
        if admin:
            session["admin"] = admin["username"]
            return redirect("/admin_dashboard")
        flash("Invalid admin login.")
    return render_template("login.html", role="Admin")


@app.route("/dashboard")
def dashboard():

    if "student_id" not in session:
        return redirect("/student_login")

    conn = get_db()
    student_id = session["student_id"]

    # Sync latest CGPA, completed credits, and current semester
    sync_student_academic_record(conn, student_id)
    sync_student_current_semester(conn, student_id)
    conn.commit()

    student = conn.execute("""
        SELECT s.*, p.name AS programme_name
        FROM students s
        LEFT JOIN programmes p ON p.code = s.programme_code
        WHERE s.id = ?
    """, (student_id,)).fetchone()

    cgpa, passed_credit, attempted_credits, failed_count = \
        calculate_academic_totals(conn, student_id)

    current_sem = absolute_semester(
        student["current_year"],
        student["current_semester"]
    )

    if attempted_credits == 0:
        max_credit = 20
    else:
        max_credit = min(20, credit_limit(cgpa))

    total_credits = conn.execute("""
        SELECT COALESCE(SUM(c.credit), 0)
        FROM programme_courses pc
        JOIN courses c ON c.code = pc.course_code
        WHERE pc.programme_code = ?
    """, (student["programme_code"],)).fetchone()[0] or 120

    progress = min(
        100,
        int((passed_credit / total_credits) * 100)
    )

    remaining = max(
        0,
        total_credits - passed_credit
    )

    current_load = conn.execute("""
        SELECT COALESCE(SUM(c.credit), 0)
        FROM study_plan sp
        JOIN courses c ON c.code = sp.course_code
        WHERE sp.student_id=?
        AND sp.semester=?
        AND sp.status NOT LIKE 'Blocked%'
    """, (student_id, current_sem)).fetchone()[0] or 0

    elective_count = conn.execute("""
        SELECT COUNT(*)
        FROM student_elective_choices
        WHERE student_id = ?
    """, (student_id,)).fetchone()[0]

    plan_count = conn.execute("""
        SELECT COUNT(*)
        FROM study_plan
        WHERE student_id = ?
    """, (student_id,)).fetchone()[0]

    upcoming = conn.execute("""
        SELECT
            sp.semester,
            sp.course_code,
            c.name,
            c.credit,
            sp.status

        FROM study_plan sp

        JOIN courses c
        ON c.code = sp.course_code

        WHERE sp.student_id = ?
        AND sp.semester >= ?

        ORDER BY sp.semester, sp.id

        LIMIT 6
    """, (student_id, current_sem)).fetchall()

    # Risk status
    if cgpa >= 3.0 and failed_count == 0:
        risk = "On Track"
        color = "green"

    elif cgpa >= 2.3 and failed_count <= 2:
        risk = "Moderate Risk"
        color = "orange"

    else:
        risk = "At Risk"
        color = "red"

    # Graduation prediction
    if risk == "On Track" and remaining <= 40:
        prediction = "Likely to graduate on time if all planned subjects are passed."

    elif risk == "On Track":
        prediction = "Progress is healthy. Continue following the generated study plan."

    elif risk == "Moderate Risk":
        prediction = "May delay if prerequisite or failed subjects are not cleared early."

    else:
        prediction = "Delay risk detected. The system will prioritize retakes and prerequisite recovery."

    # Recommendation message
    if cgpa >= 3.5:
        ai_message = "Excellent standing. You may proceed with the normal maximum workload if prerequisite rules are met."

    elif cgpa >= 2.7:
        ai_message = "Stable progress. Keep a balanced load and complete prerequisite subjects early."

    elif cgpa >= 2.0:
        ai_message = "Use a reduced workload. Retake failed or blocking prerequisite subjects first."

    else:
        ai_message = "Academic risk detected. The system recommends a lighter plan and immediate retake scheduling."

    conn.close()

    return render_template(
        "dashboard.html",
        student=student,
        cgpa=cgpa,
        risk=risk,
        color=color,
        prediction=prediction,
        pred_color=color,
        progress=progress,
        credits_completed=passed_credit,
        attempted_credits=attempted_credits,
        total_credits=total_credits,
        remaining=remaining,
        current_sem=current_sem,
        current_load=current_load,
        max_credit=max_credit,
        failed_count=failed_count,
        elective_count=elective_count,
        plan_count=plan_count,
        upcoming=upcoming,
        ai_message=ai_message
    )


@app.route("/generate_recommendation")
def generate_recommendation():
    if "student_id" not in session:
        return redirect("/student_login")

    conn = get_db()
    student_id = session["student_id"]
    sync_student_academic_record(conn, student_id)
    sync_student_current_semester(conn, student_id)
    conn.commit()

    student = conn.execute("SELECT * FROM students WHERE id=?", (student_id,)).fetchone()
    programme = student["programme_code"]
    cgpa, _, attempted_credits, _ = calculate_academic_totals(conn, student_id)

    if attempted_credits == 0:
        max_credit = 20
    else:
        max_credit = min(20, credit_limit(cgpa))
    current_sem = absolute_semester(student["current_year"], student["current_semester"])

    plans = conn.execute("""
        SELECT sp.semester, sp.course_code, c.name, c.credit, sp.status
        FROM study_plan sp
        JOIN courses c ON c.code=sp.course_code
        WHERE sp.student_id=?
        ORDER BY sp.semester, sp.id
    """, (student_id,)).fetchall()

    sem_credits = defaultdict(int)
    industrial_sems = set()

    for p in plans:
        if p["course_code"] == INDUSTRIAL_CODE:
            industrial_sems.add(p["semester"])

        if "Blocked" not in p["status"]:
            sem_credits[p["semester"]] += p["credit"]

    open_sems = [
        s for s, total in sorted(sem_credits.items())
        if s >= current_sem
        and s not in industrial_sems
        and total + 3 <= max_credit
    ]

    suggested_semester = open_sems[0] if open_sems else current_sem

    # Current Load shown on the page must refer to the student's CURRENT semester,
    # not the suggested elective semester.
    current_load = conn.execute("""
        SELECT COALESCE(SUM(c.credit), 0)
        FROM study_plan sp
        JOIN courses c ON c.code = sp.course_code
        WHERE sp.student_id=?
        AND sp.semester=?
        AND sp.status NOT LIKE 'Blocked%'
    """, (student_id, current_sem)).fetchone()[0] or 0

    # Available credit is based on the suggested slot where the elective will be added.
    suggested_load = conn.execute("""
        SELECT COALESCE(SUM(c.credit), 0)
        FROM study_plan sp
        JOIN courses c ON c.code = sp.course_code
        WHERE sp.student_id=?
        AND sp.semester=?
        AND sp.status NOT LIKE 'Blocked%'
    """, (student_id, suggested_semester)).fetchone()[0] or 0

    remaining_credit = max_credit - suggested_load

    chosen_electives = conn.execute("""
        SELECT c.*
        FROM student_elective_choices s
        JOIN courses c ON c.code=s.course_code
        WHERE s.student_id=?
        ORDER BY c.cluster_no, c.code
    """, (student_id,)).fetchall()

    chosen_clusters = {
        e["cluster_no"] for e in chosen_electives
        if e["cluster_no"] is not None
    }

    allow_elective = (
        remaining_credit >= 3
        and len(chosen_electives) < MAX_ELECTIVES
        and len(plans) > 0
    )

    electives = conn.execute("""
        SELECT *
        FROM courses
        WHERE category='Elective'
          AND code NOT IN (
              SELECT course_code 
              FROM student_elective_choices 
              WHERE student_id=?
          )
        ORDER BY cluster_no, code
    """, (student_id,)).fetchall()

    elective_clusters = OrderedDict()

    for e in electives:
        after = set(chosen_clusters)

        if e["cluster_no"] is not None:
            after.add(e["cluster_no"])

        if len(after) <= MAX_ELECTIVE_CLUSTERS:
            label = f"Cluster {e['cluster_no'] or '-'} - {e['cluster_name'] or 'General'}"
            elective_clusters.setdefault(label, []).append(e)

    failed_codes = [
        r["course_code"]
        for r in latest_results(conn, student_id)
        if r["grade"] == "F"
    ]

    courses = get_programme_curriculum(conn, programme)

    conn.close()

    return render_template(
        "generate_recommendation.html",
        student=student,
        courses=courses,
        chosen_electives=chosen_electives,
        elective_clusters=elective_clusters,
        failed_codes=failed_codes,
        blocked_count=len(failed_codes),
        credit_allowed=max_credit,
        current_load=current_load,
        remaining_credit=remaining_credit,
        allow_elective=allow_elective,
        suggested_semester=suggested_semester,
        has_plan=len(plans) > 0,
        max_electives=MAX_ELECTIVES
    )


@app.route("/add_elective_to_plan", methods=["POST"])
def add_elective_to_plan():
    if "student_id" not in session:
        return redirect("/student_login")

    student_id = session["student_id"]
    course_code = request.form["course_code"]
    semester = int(request.form["semester"])

    conn = get_db()

    cgpa, _, attempted_credits, _ = calculate_academic_totals(conn, student_id)

    if attempted_credits == 0:
        max_credit = 20
    else:
        max_credit = min(20, credit_limit(cgpa))

    if conn.execute("""
        SELECT 1 
        FROM study_plan 
        WHERE student_id=? 
          AND semester=? 
          AND course_code=?
    """, (student_id, semester, INDUSTRIAL_CODE)).fetchone():
        conn.close()
        flash("Electives cannot be added to the Industrial Training semester.")
        return redirect("/generate_recommendation")

    ok, message = elective_rule_ok(conn, student_id, course_code)

    if not ok:
        conn.close()
        flash(message)
        return redirect("/generate_recommendation")

    elective = conn.execute("""
        SELECT * 
        FROM courses 
        WHERE code=? 
          AND category='Elective'
    """, (course_code,)).fetchone()

    used_credit = plan_semester_credit(conn, student_id, semester)

    if used_credit + elective["credit"] > max_credit:
        conn.close()
        flash("This elective cannot be added because it exceeds the semester credit limit.")
        return redirect("/generate_recommendation")

    conn.execute("""
        INSERT INTO student_elective_choices(student_id, course_code) 
        VALUES (?, ?)
    """, (student_id, course_code))

    conn.execute("""
        INSERT INTO study_plan(student_id, semester, course_code, status) 
        VALUES (?, ?, ?, 'Planned Elective')
    """, (student_id, semester, course_code))

    conn.commit()
    conn.close()

    flash("Elective added to your study plan.")
    return redirect("/study_plan")

@app.route("/remove_elective/<course_code>")
def remove_elective(course_code):
    if "student_id" not in session:
        return redirect("/student_login")

    student_id = session["student_id"]
    conn = get_db()

    conn.execute("""
        DELETE FROM student_elective_choices
        WHERE student_id=? AND course_code=?
    """, (student_id, course_code))

    conn.execute("""
        DELETE FROM study_plan
        WHERE student_id=? AND course_code=? AND status='Planned Elective'
    """, (student_id, course_code))

    conn.commit()
    conn.close()

    flash("Elective removed successfully.")
    return redirect("/generate_recommendation")

@app.route("/generate_plan")
def generate_plan():
    if "student_id" not in session:
        return redirect("/student_login")

    conn = get_db()
    student_id = session["student_id"]

    sync_student_academic_record(conn, student_id)
    conn.commit()

    student = conn.execute("""
        SELECT * FROM students
        WHERE id=?
    """, (student_id,)).fetchone()

    programme = student["programme_code"]

    cgpa, _, attempted_credits, _ = calculate_academic_totals(conn, student_id)

    # New student has no result yet, so use normal 20-credit limit
    if attempted_credits == 0:
        max_credit = 20
    else:
        max_credit = min(20, credit_limit(cgpa))

    conn.execute("DELETE FROM study_plan WHERE student_id=?", (student_id,))

    courses = get_programme_curriculum(conn, programme)
    course_map = {c["code"]: c for c in courses}

    raw_results = conn.execute("""
        SELECT *
        FROM results
        WHERE student_id=?
        ORDER BY semester, id
    """, (student_id,)).fetchall()

    # Keep latest correction per subject per semester
    result_by_course_sem = {}
    for r in raw_results:
        result_by_course_sem[(r["course_code"], int(r["semester"]))] = r

    all_results = sorted(
        result_by_course_sem.values(),
        key=lambda r: (int(r["semester"]), r["id"])
    )

    inserts = []
    semester_credit = defaultdict(int)
    available_after_sem = {}
    planned_codes = set()
    retake_scheduled = set()
    industrial_sems = set()

    def semester_type(sem):
        return 1 if int(sem) % 2 == 1 else 2

    def has_industrial(sem):
        return sem in industrial_sems or any(
            item[1] == sem and item[2] == INDUSTRIAL_CODE
            for item in inserts
        )

    def add_plan(sem, code, status):
        sem = int(sem)

        if code not in course_map:
            return False

        credit = int(course_map[code]["credit"])

        if code == INDUSTRIAL_CODE:
            if semester_credit[sem] > 0:
                return False
        else:
            if has_industrial(sem):
                return False

        for item in inserts:
            existing_sem = item[1]
            existing_code = item[2]
            existing_status = item[3]

            if existing_sem == sem and existing_code == code:
                return False

            if existing_code == code:

                if existing_status == "Blocked by Prerequisite" and status == "Planned":
                    continue

                if "Failed" in existing_status and status in ["Retake", "Retake - Passed"]:
                    continue

                if existing_status in ["Passed", "Retake - Passed"]:
                    return False

                if existing_status == "Retake" and status in ["Planned", "Retake"]:
                    return False

                if existing_status == "Planned" and status == "Planned":
                    return False

        history_statuses = [
            "Passed",
            "Failed - Retake Required",
            "Retake - Passed"
        ]

        if status not in history_statuses:
            if semester_credit[sem] + credit > max_credit:
                return False

        inserts.append((student_id, sem, code, status))

        if not status.startswith("Blocked"):
            semester_credit[sem] += credit

        if code == INDUSTRIAL_CODE:
            industrial_sems.add(sem)

        return True

    def prereqs_ready(code, target_sem):
        for p in get_prereqs(conn, programme, code):
            prereq_code = p["prerequisite_code"]

            if prereq_code not in available_after_sem:
                return False

            if int(available_after_sem[prereq_code]) >= int(target_sem):
                return False

        return True

    # 1. Preserve real result history
    # Keep failed attempts, keep real retake passes,
    # but ignore accidental duplicate passed records after an earlier pass.
    failed_before = defaultdict(bool)
    passed_before = defaultdict(bool)

    for r in all_results:
        code = r["course_code"]
        grade = (r["grade"] or "").upper()
        sem = int(r["semester"])

        if code not in course_map:
            continue

        if grade == "F":
            # If the subject was already passed before, this is invalid/noise and should not
            # affect the generated plan.
            if passed_before[code]:
                continue

            add_plan(sem, code, "Failed - Retake Required")
            failed_before[code] = True
            continue

        # grade is passed
        if passed_before[code]:
            continue

        if failed_before[code]:
            if add_plan(sem, code, "Retake - Passed"):
                available_after_sem[code] = sem
                planned_codes.add(code)
                passed_before[code] = True
        else:
            if add_plan(sem, code, "Passed"):
                available_after_sem[code] = sem
                planned_codes.add(code)
                passed_before[code] = True
                
    # 2. Latest status per subject
    latest_status = {}

    for r in all_results:
        code = r["course_code"]
        sem = int(r["semester"])
        grade = (r["grade"] or "").upper()

        if code not in latest_status or sem > latest_status[code]["semester"]:
            latest_status[code] = {
                "semester": sem,
                "grade": grade
            }

    # 3. Schedule failed subject retakes first
    failed_subjects = []

    for code, latest in latest_status.items():
        if code not in course_map:
            continue

        if latest["grade"] == "F":
            failed_subjects.append({
                "code": code,
                "failed_sem": int(latest["semester"])
            })

    failed_subjects.sort(key=lambda x: x["failed_sem"])

    for failed in failed_subjects:
        code = failed["code"]
        failed_sem = failed["failed_sem"]
        retake_sem = failed_sem + 2

        while retake_sem <= 20:
            if semester_type(retake_sem) != semester_type(failed_sem):
                retake_sem += 1
                continue

            industrial_course = course_map.get(INDUSTRIAL_CODE)

            industrial_original_sem = None
            industrial_prereq_codes = [
                p["prerequisite_code"]
                for p in get_prereqs(conn, programme, INDUSTRIAL_CODE)
            ]

            if industrial_course:
                industrial_original_sem = int(industrial_course["curriculum_sem"])

            # If this retake falls on the original Industrial Training semester
            # and the failed subject is NOT an Industrial Training prerequisite,
            # move retake later so Industrial Training stays on time.
            if (
                industrial_original_sem
                and retake_sem == industrial_original_sem
                and code not in industrial_prereq_codes
            ):
                retake_sem += 2
                continue

            # If Industrial Training is already placed in that semester,
            # also do not mix retake with it.
            if has_industrial(retake_sem):
                retake_sem += 2
                continue

            if add_plan(retake_sem, code, "Retake"):
                available_after_sem[code] = retake_sem
                retake_scheduled.add(code)
                planned_codes.add(code)
                break

            retake_sem += 2

    # 4. Plan remaining curriculum subjects
    for sem in range(1, 20):

        industrial_course = course_map.get(INDUSTRIAL_CODE)

        if industrial_course and INDUSTRIAL_CODE not in planned_codes:
            industrial_sem = int(industrial_course["curriculum_sem"])

            if sem >= industrial_sem:
                if semester_credit[sem] == 0 and prereqs_ready(INDUSTRIAL_CODE, sem):
                    if add_plan(sem, INDUSTRIAL_CODE, "Industrial Training Only"):
                        planned_codes.add(INDUSTRIAL_CODE)
                        available_after_sem[INDUSTRIAL_CODE] = sem
                        continue

        for c in courses:
            code = c["code"]

            if code == INDUSTRIAL_CODE:
                continue

            if code in planned_codes:
                continue

            if code in retake_scheduled:
                continue

            latest = latest_status.get(code)

            if latest and latest["grade"] != "F":
                continue

            curriculum_sem = int(c["curriculum_sem"])

            if sem < curriculum_sem:
                continue

            if has_industrial(sem):
                continue

            # FYP I must be after Industrial Training
            if code == "TMF4913":
                if INDUSTRIAL_CODE not in available_after_sem:
                    continue
                if available_after_sem[INDUSTRIAL_CODE] >= sem:
                    continue

            # FYP II must be after FYP I
            if code == "TMF4935":
                if "TMF4913" not in available_after_sem:
                    continue
                if available_after_sem["TMF4913"] >= sem:
                    continue

            # If subject has prerequisite, only delay if the prerequisite
            # was actually failed or retaken later.
            # For new students with no result yet, follow the normal curriculum.
            if not prereqs_ready(code, sem):

                prereq_blocked_or_failed = False

                for p in get_prereqs(conn, programme, code):
                    prereq_code = p["prerequisite_code"]
                    latest_prereq = latest_status.get(prereq_code)

                    # Case 1: prerequisite latest result is failed
                    if latest_prereq and latest_prereq["grade"] == "F":
                        prereq_blocked_or_failed = True
                        break

                    # Case 2: prerequisite itself is already blocked in the generated plan
                    for item in inserts:
                        existing_code = item[2]
                        existing_status = item[3]

                        if existing_code == prereq_code and existing_status == "Blocked by Prerequisite":
                            prereq_blocked_or_failed = True
                            break

                    if prereq_blocked_or_failed:
                        break

                if prereq_blocked_or_failed:
                    if sem == curriculum_sem:
                        add_plan(sem, code, "Blocked by Prerequisite")
                    continue

            if add_plan(sem, code, "Planned"):
                planned_codes.add(code)
                available_after_sem[code] = sem

    conn.executemany("""
        INSERT INTO study_plan(student_id, semester, course_code, status)
        VALUES (?, ?, ?, ?)
    """, inserts)

    sync_student_academic_record(conn, student_id)
    sync_student_current_semester(conn, student_id)

    conn.commit()
    conn.close()

    return redirect("/study_plan")

@app.route("/study_plan")
def study_plan():
    if "student_id" not in session:
        return redirect("/student_login")

    conn = get_db()
    student_id = session["student_id"]

    sync_student_current_semester(conn, student_id)
    conn.commit()

    plans = conn.execute("""
        SELECT sp.id, sp.semester, sp.course_code, c.name, c.credit, sp.status, r.grade
        FROM study_plan sp
        JOIN courses c ON c.code=sp.course_code
        LEFT JOIN (
            SELECT rr.course_code, rr.semester, rr.grade
            FROM results rr
            JOIN (
                SELECT course_code, semester, MAX(id) AS max_id
                FROM results
                WHERE student_id=?
                GROUP BY course_code, semester
            ) latest_attempt ON latest_attempt.max_id = rr.id
            WHERE rr.student_id=?
        ) r ON r.course_code=sp.course_code AND r.semester=sp.semester
        WHERE sp.student_id=?
        ORDER BY sp.semester, sp.id
    """, (student_id, student_id, student_id)).fetchall()

    semester_groups = OrderedDict()
    semester_totals = defaultdict(int)

    for p in plans:
        semester_groups.setdefault(p["semester"], []).append(p)

        if not str(p["status"]).startswith("Blocked"):
            semester_totals[p["semester"]] += int(p["credit"] or 0)

    conn.close()

    return render_template(
        "study_plan.html",
        semester_groups=semester_groups,
        semester_totals=semester_totals
    )

@app.route("/update_result", methods=["GET", "POST"])
def update_result():

    if "student_id" not in session:
        return redirect("/student_login")

    conn = get_db()
    student_id = session["student_id"]

    # =====================================================
    # SAVE RESULT
    # =====================================================
    if request.method == "POST":

        course_code = request.form["course_code"]
        grade = request.form["grade"]
        semester = int(request.form["semester"])

        # -----------------------------------------
        # INSERT RESULT SAFELY
        # Do not create duplicate passed records unless this is a real retake.
        # -----------------------------------------
        latest_attempt = conn.execute("""
            SELECT *
            FROM results
            WHERE student_id=? AND course_code=?
            ORDER BY semester DESC, id DESC
            LIMIT 1
        """, (student_id, course_code)).fetchone()

        existing_same_semester = conn.execute("""
            SELECT id
            FROM results
            WHERE student_id=? AND course_code=? AND semester=?
            ORDER BY id DESC
            LIMIT 1
        """, (student_id, course_code, semester)).fetchone()

        if existing_same_semester:
            # Same semester correction: update that semester only.
            conn.execute("""
                UPDATE results
                SET grade=?
                WHERE id=?
            """, (grade, existing_same_semester["id"]))

        elif latest_attempt and latest_attempt["grade"] != "F" and grade != "F":
            # Already passed before; do not insert another duplicate pass in a later semester.
            flash("This subject already has a passed result. Duplicate passed result was not added.")
            conn.commit()
            conn.close()
            return redirect("/update_result")

        else:
            # New attempt or real retake attempt.
            conn.execute("""
                INSERT INTO results
                (student_id, course_code, grade, semester)
                VALUES (?, ?, ?, ?)
            """, (
                student_id,
                course_code,
                grade,
                semester
            ))

        # -----------------------------------------
        # UPDATE CGPA + CURRENT SEMESTER + PLAN
        # -----------------------------------------
        sync_student_academic_record(conn, student_id)
        sync_student_current_semester(conn, student_id)

        conn.commit()
        conn.close()

        return redirect("/generate_plan")

    # =====================================================
    # GET STUDENT
    # =====================================================
    sync_student_current_semester(conn, student_id)
    conn.commit()

    student = conn.execute("""
        SELECT *
        FROM students
        WHERE id=?
    """, (student_id,)).fetchone()

    # =====================================================
    # GET AVAILABLE SUBJECTS
    # =====================================================
    courses = conn.execute("""
        SELECT DISTINCT
            c.code,
            c.name,
            c.credit

        FROM courses c

        LEFT JOIN programme_courses pc
        ON pc.course_code = c.code

        WHERE
            pc.programme_code = ?
            OR c.category = 'Elective'

        ORDER BY c.code
    """, (student["programme_code"],)).fetchall()

    # =====================================================
    # RESULT HISTORY
    # =====================================================
    history = conn.execute("""
        SELECT
            r.semester,
            r.course_code,
            c.name,
            r.grade

        FROM results r

        JOIN courses c
        ON c.code = r.course_code

        WHERE r.student_id=?

        ORDER BY
            r.semester DESC,
            r.id DESC
    """, (student_id,)).fetchall()

    # =====================================================
    # CURRENT SEMESTER
    # =====================================================
    current_sem = absolute_semester(
        student["current_year"],
        student["current_semester"]
    )

    conn.close()

    return render_template(
        "update_result.html",
        courses=courses,
        history=history,
        current_sem=current_sem,
        grades=list(GRADE_POINTS.keys())
    )


@app.route("/admin_dashboard")
def admin_dashboard():
    if "admin" not in session:
        return redirect("/admin_login")

    conn = get_db()
    total_students = conn.execute("SELECT COUNT(*) FROM students").fetchone()[0]
    total_courses = conn.execute("SELECT COUNT(*) FROM courses").fetchone()[0]
    total_programmes = conn.execute("SELECT COUNT(*) FROM programmes").fetchone()[0]
    total_results = conn.execute("SELECT COUNT(*) FROM results").fetchone()[0]
    at_risk = conn.execute("SELECT COUNT(*) FROM students WHERE cgpa < 2.50").fetchone()[0]
    failed_records = conn.execute("SELECT COUNT(*) FROM results WHERE grade='F'").fetchone()[0]
    recent_students = conn.execute("""
        SELECT matric_no, name, programme_code, cgpa, credits_completed
        FROM students
        ORDER BY id DESC
        LIMIT 6
    """).fetchall()
    conn.close()
    return render_template("admin_dashboard.html", total_students=total_students, total_courses=total_courses, total_programmes=total_programmes, total_results=total_results, at_risk=at_risk, failed_records=failed_records, recent_students=recent_students)


@app.route("/manage_courses", methods=["GET", "POST"])
def manage_courses():

    if "admin" not in session:
        return redirect("/admin_login")

    conn = get_db()

    # =====================================================
    # SAVE SUBJECT
    # =====================================================
    if request.method == "POST":

        code = request.form["code"]
        name = request.form["name"]
        credit = request.form["credit"]
        programme_code = request.form["programme_code"]
        year_no = request.form["year_no"]
        semester_no = request.form["semester_no"]
        category = request.form["category"]

        # OPTIONAL FIELDS
        cluster_no = request.form.get("cluster_no") or None
        cluster_name = request.form.get("cluster_name") or None
        faculty = request.form.get("faculty") or None

        # =========================================
        # INSERT SUBJECT
        # =========================================

        conn.execute("""
            INSERT INTO courses
            (code, name, credit, category, cluster_no, cluster_name, faculty)
            VALUES (?, ?, ?, ?, ?, ?, ?)
            ON CONFLICT(code) DO UPDATE SET
                name=excluded.name,
                credit=excluded.credit,
                category=excluded.category,
                cluster_no=excluded.cluster_no,
                cluster_name=excluded.cluster_name,
                faculty=excluded.faculty
        """, (
            code,
            name,
            credit,
            category,
            cluster_no,
            cluster_name,
            faculty
        ))

        conn.execute("""
            DELETE FROM programme_courses
            WHERE programme_code=? AND course_code=?
        """, (
            programme_code,
            code
        ))

        conn.execute("""
            INSERT INTO programme_courses
            (programme_code, course_code, year_no, semester_no)
            VALUES (?, ?, ?, ?)
        """, (
            programme_code,
            code,
            year_no,
            semester_no
        ))

        conn.commit()

        flash(
            "Subject saved successfully. "
            "Students should regenerate their study plan "
            "to reflect the latest curriculum."
        )

    # =====================================================
    # GET SUBJECTS
    # =====================================================
    courses = conn.execute("""

        SELECT
            c.*,
            pc.programme_code,
            pc.year_no,
            pc.semester_no

        FROM courses c

        LEFT JOIN programme_courses pc
        ON pc.course_code = c.code

        ORDER BY
            c.category,
            pc.programme_code,
            pc.year_no,
            pc.semester_no,
            c.code

    """).fetchall()

    # =====================================================
    # GROUP SUBJECTS
    # =====================================================
    grouped_courses = OrderedDict()

    for c in courses:

        key = c["category"] or "Other"

        grouped_courses.setdefault(key, []).append(c)

    # =====================================================
    # GET PROGRAMMES
    # =====================================================
    programmes = conn.execute("""
        SELECT *
        FROM programmes
        ORDER BY code
    """).fetchall()

    conn.close()

    return render_template(
        "manage_courses.html",
        grouped_courses=grouped_courses,
        programmes=programmes
    )


@app.route("/delete_course/<code>")
def delete_course(code):
    if "admin" not in session:
        return redirect("/admin_login")

    conn = get_db()
    conn.execute("DELETE FROM programme_courses WHERE course_code=?", (code,))
    conn.execute("DELETE FROM course_prerequisites WHERE course_code=? OR prerequisite_code=?", (code, code))
    conn.execute("DELETE FROM student_elective_choices WHERE course_code=?", (code,))
    conn.execute("DELETE FROM study_plan WHERE course_code=?", (code,))
    conn.execute("DELETE FROM results WHERE course_code=?", (code,))
    conn.execute("DELETE FROM courses WHERE code=?", (code,))
    # Re-sync students because deleting a course can change credits and CGPA calculation.
    for row in conn.execute("SELECT id FROM students").fetchall():
        sync_student_academic_record(conn, row["id"])
    conn.commit()
    conn.close()
    flash("Course removed and related records were cleaned.")
    return redirect("/manage_courses")


@app.route("/delete_student/<int:student_id>")
def delete_student(student_id):
    if "admin" not in session:
        return redirect("/admin_login")

    conn = get_db()

    conn.execute("DELETE FROM results WHERE student_id=?", (student_id,))
    conn.execute("DELETE FROM study_plan WHERE student_id=?", (student_id,))
    conn.execute("DELETE FROM student_elective_choices WHERE student_id=?", (student_id,))
    conn.execute("DELETE FROM students WHERE id=?", (student_id,))

    conn.commit()
    conn.close()

    flash("Student removed successfully.")
    return redirect("/manage_students")

@app.route("/manage_students", methods=["GET", "POST"])
def manage_students():
    if "admin" not in session:
        return redirect("/admin_login")

    conn = get_db()

    if request.method == "POST":
        student_id = request.form.get("student_id")
        matric_no = request.form["matric_no"]
        name = request.form["name"]
        password = request.form["password"]
        programme_code = request.form["programme_code"]
        current_year = request.form["current_year"]
        current_semester = request.form["current_semester"]

        if student_id:
            conn.execute("""
                UPDATE students
                SET matric_no=?, name=?, password=?, programme_code=?,
                    current_year=?, current_semester=?
                WHERE id=?
            """, (
                matric_no, name, password, programme_code,
                current_year, current_semester, student_id
            ))
            flash("Student information updated successfully.")
        else:
            conn.execute("""
                INSERT INTO students
                (matric_no, name, password, programme_code,
                 current_year, current_semester, cgpa, credits_completed)
                VALUES (?, ?, ?, ?, ?, ?, 0.00, 0)
            """, (
                matric_no, name, password, programme_code,
                current_year, current_semester
            ))
            flash("New student added successfully.")

        conn.commit()

    students = conn.execute("""
        SELECT *
        FROM students
        ORDER BY programme_code, matric_no
    """).fetchall()

    conn.close()

    return render_template("manage_students.html", students=students)


@app.route("/logout")
def logout():
    session.clear()
    return redirect("/")


if __name__ == "__main__":
    app.run(debug=True)