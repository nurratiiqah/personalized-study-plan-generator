BEGIN TRANSACTION;
CREATE TABLE IF NOT EXISTS "academic_rules" (
	"id"	INTEGER,
	"rule_name"	TEXT UNIQUE,
	"rule_value"	INTEGER,
	PRIMARY KEY("id" AUTOINCREMENT)
);
CREATE TABLE IF NOT EXISTS "admins" (
	"id"	INTEGER,
	"username"	TEXT UNIQUE,
	"password"	TEXT,
	PRIMARY KEY("id" AUTOINCREMENT)
);
CREATE TABLE IF NOT EXISTS "course_prerequisites" (
	"programme_code"	TEXT,
	"course_code"	TEXT,
	"prerequisite_code"	TEXT,
	PRIMARY KEY("programme_code","course_code","prerequisite_code")
);
CREATE TABLE IF NOT EXISTS "courses" (
	"code"	TEXT,
	"name"	TEXT,
	"credit"	INTEGER,
	"category"	TEXT,
	"cluster_no"	INTEGER,
	"cluster_name"	TEXT,
	"faculty"	TEXT,
	PRIMARY KEY("code")
);
CREATE TABLE IF NOT EXISTS "programme_courses" (
	"id"	INTEGER,
	"programme_code"	TEXT,
	"course_code"	TEXT,
	"year_no"	INTEGER,
	"semester_no"	INTEGER,
	PRIMARY KEY("id" AUTOINCREMENT),
	FOREIGN KEY("course_code") REFERENCES "courses"("code"),
	FOREIGN KEY("programme_code") REFERENCES "programmes"("code")
);
CREATE TABLE IF NOT EXISTS "programmes" (
	"code"	TEXT,
	"name"	TEXT,
	PRIMARY KEY("code")
);
CREATE TABLE IF NOT EXISTS "results" (
	"id"	INTEGER,
	"student_id"	INTEGER,
	"course_code"	TEXT,
	"grade"	TEXT,
	"semester"	INTEGER,
	PRIMARY KEY("id" AUTOINCREMENT),
	FOREIGN KEY("course_code") REFERENCES "courses"("code"),
	FOREIGN KEY("student_id") REFERENCES "students"("id")
);
CREATE TABLE IF NOT EXISTS "student_elective_choices" (
	"id"	INTEGER,
	"student_id"	INTEGER,
	"course_code"	TEXT,
	PRIMARY KEY("id" AUTOINCREMENT),
	FOREIGN KEY("course_code") REFERENCES "courses"("code"),
	FOREIGN KEY("student_id") REFERENCES "students"("id")
);
CREATE TABLE IF NOT EXISTS "students" (
	"id"	INTEGER,
	"matric_no"	TEXT UNIQUE,
	"name"	TEXT,
	"password"	TEXT,
	"programme_code"	TEXT,
	"current_year"	INTEGER,
	"current_semester"	INTEGER,
	"cgpa"	REAL,
	"credits_completed"	INTEGER DEFAULT 0,
	PRIMARY KEY("id" AUTOINCREMENT),
	FOREIGN KEY("programme_code") REFERENCES "programmes"("code")
);
CREATE TABLE IF NOT EXISTS "study_plan" (
	"id"	INTEGER,
	"student_id"	INTEGER,
	"semester"	INTEGER,
	"course_code"	TEXT,
	"status"	TEXT,
	PRIMARY KEY("id" AUTOINCREMENT),
	FOREIGN KEY("course_code") REFERENCES "courses"("code"),
	FOREIGN KEY("student_id") REFERENCES "students"("id")
);
INSERT INTO "academic_rules" VALUES (3,'required_electives',3);
INSERT INTO "academic_rules" VALUES (4,'max_elective_clusters',2);
INSERT INTO "admins" VALUES (1,'admin','admin123');
INSERT INTO "course_prerequisites" VALUES ('ALL','TMF1434','TMF1414');
INSERT INTO "course_prerequisites" VALUES ('ALL','TMF1434','TMF1814');
INSERT INTO "course_prerequisites" VALUES ('ALL','TMF2954','TMF1434');
INSERT INTO "course_prerequisites" VALUES ('ALL','TMF4935','TMF4913');
INSERT INTO "course_prerequisites" VALUES ('IS','TMI2073','TMF2034');
INSERT INTO "course_prerequisites" VALUES ('IS','TMI2123','TMF1434');
INSERT INTO "course_prerequisites" VALUES ('IS','TMF39412','TMF1434');
INSERT INTO "course_prerequisites" VALUES ('IS','TMI2113','TMF1434');
INSERT INTO "course_prerequisites" VALUES ('IS','TMF2954','TMF1434');
INSERT INTO "course_prerequisites" VALUES ('IS','TMI3073','TMF1434');
INSERT INTO "course_prerequisites" VALUES ('IS','TMI4133','TMF1254');
INSERT INTO "course_prerequisites" VALUES ('IS','TMF4913','TMF3113');
INSERT INTO "course_prerequisites" VALUES ('IS','TMF39412','TMF1014');
INSERT INTO "course_prerequisites" VALUES ('IS','TMF4935','TMF4913');
INSERT INTO "course_prerequisites" VALUES ('CS','TMF39412','TMF1913');
INSERT INTO "course_prerequisites" VALUES ('CS','TMF39412','TMF1434');
INSERT INTO "course_prerequisites" VALUES ('CS','TMS2833','TMF1434');
INSERT INTO "course_prerequisites" VALUES ('CS','TMF4935','TMF4913');
INSERT INTO "course_prerequisites" VALUES ('CS','TMF39412','TMF3963');
INSERT INTO "course_prerequisites" VALUES ('MC','TMF39412','TMF1434');
INSERT INTO "course_prerequisites" VALUES ('MC','TMT2673','TMF1434');
INSERT INTO "course_prerequisites" VALUES ('MC','TMT3123','TMF1214');
INSERT INTO "course_prerequisites" VALUES ('MC','TMF39412','TMF1913');
INSERT INTO "course_prerequisites" VALUES ('MC','TMF39412','TMF3963');
INSERT INTO "course_prerequisites" VALUES ('SE','TMF39412','TMF1913');
INSERT INTO "course_prerequisites" VALUES ('SE','TMF39412','TMF3963');
INSERT INTO "course_prerequisites" VALUES ('SE','TMF39412','TMF1434');
INSERT INTO "course_prerequisites" VALUES ('SE','TMA4093','TMF1913');
INSERT INTO "course_prerequisites" VALUES ('SE','TMF2964','TMF1434');
INSERT INTO "course_prerequisites" VALUES ('SE','TMF2243','TMF1434');
INSERT INTO "course_prerequisites" VALUES ('SE','TMA4093','TMF2243');
INSERT INTO "course_prerequisites" VALUES ('SE','TMA3084','TMF2243');
INSERT INTO "course_prerequisites" VALUES ('SE','TMA4103','TMA3084');
INSERT INTO "course_prerequisites" VALUES ('SE','TMA4113','TMA3084');
INSERT INTO "course_prerequisites" VALUES ('SE','TMF4935','TMF4913');
INSERT INTO "course_prerequisites" VALUES ('NC','TMF39412','TMF1434');
INSERT INTO "course_prerequisites" VALUES ('NC','TMF39412','TMF1913');
INSERT INTO "course_prerequisites" VALUES ('NC','TMN4033','TMF1214');
INSERT INTO "course_prerequisites" VALUES ('NC','TMN2073','TMF1254');
INSERT INTO "course_prerequisites" VALUES ('NC','TMN3093','TMF1254');
INSERT INTO "course_prerequisites" VALUES ('NC','TMN3213','TMF1254');
INSERT INTO "course_prerequisites" VALUES ('NC','TMN4143','TMF1254');
INSERT INTO "course_prerequisites" VALUES ('NC','TMN4113','TMF2234');
INSERT INTO "course_prerequisites" VALUES ('NC','TMN4143','TMF2234');
INSERT INTO "course_prerequisites" VALUES ('NC','TMF39412','TMF3963');
INSERT INTO "course_prerequisites" VALUES ('NC','TMF4935','TMF4913');
INSERT INTO "course_prerequisites" VALUES ('MC','TMF4935','TMF4913');
INSERT INTO "courses" VALUES ('BEU1013','Building Anatomy and Basic Estimating',3,'Elective',1,'Science, Technology and Medicine','FAB');
INSERT INTO "courses" VALUES ('BEU1023','Creative Sketches',3,'Elective',4,'Creative Arts and Design','FAB');
INSERT INTO "courses" VALUES ('BEU1033','Fundamentals of the Built Environment',3,'Elective',1,'Science, Technology and Medicine','FAB');
INSERT INTO "courses" VALUES ('EBU1023','Managing Small Business Accounts',3,'Elective',3,'Business and Management','FEP');
INSERT INTO "courses" VALUES ('EBU1033','Malaysian Economics Environments',3,'Elective',3,'Business and Management','FEP');
INSERT INTO "courses" VALUES ('EBU1053','Online Business Management',3,'Elective',3,'Business and Management','FEP');
INSERT INTO "courses" VALUES ('EBU1063','Smart Money Management',3,'Elective',3,'Business and Management','FEP');
INSERT INTO "courses" VALUES ('EBU2043','Introduction to Intellectual Property',3,'Elective',3,'Business and Management','FEP');
INSERT INTO "courses" VALUES ('GKU1013','Modern Malay Drama and Theatre of Malaysia',3,'Elective',4,'Creative Arts and Design','FSGK');
INSERT INTO "courses" VALUES ('GKU1033','Digital Photography and Social Media Imaging',3,'Elective',4,'Creative Arts and Design','FSGK');
INSERT INTO "courses" VALUES ('GKU1043','History of Malaysian Cinema',3,'Elective',4,'Creative Arts and Design','FSGK');
INSERT INTO "courses" VALUES ('GKU1053','History of Drama and Theater',3,'Elective',4,'Creative Arts and Design','FSGK');
INSERT INTO "courses" VALUES ('GKU1063','Introduction to Basic Music',3,'Elective',4,'Creative Arts and Design','FSGK');
INSERT INTO "courses" VALUES ('GKU1083','Introduction to Stage Directing',3,'Elective',4,'Creative Arts and Design','FSGK');
INSERT INTO "courses" VALUES ('GKU1093','Basic Figure Drawing',3,'Elective',4,'Creative Arts and Design','FSGK');
INSERT INTO "courses" VALUES ('KMU1013','Helping Relationship',3,'Elective',2,'Social Science and Humanities','FSKPM');
INSERT INTO "courses" VALUES ('KMU1023','Introduction to Human Resource Development',3,'Elective',3,'Business and Management','FSKPM');
INSERT INTO "courses" VALUES ('KMU1053','Theories and Concepts: Human Computer Interaction',3,'Elective',1,'Science, Technology and Medicine','FSKPM');
INSERT INTO "courses" VALUES ('KMU1063','Introduction to Mental Health',3,'Elective',2,'Social Science and Humanities','FSKPM');
INSERT INTO "courses" VALUES ('KNU1013','Introduction to Green Technology',3,'Elective',1,'Science, Technology and Medicine','FK');
INSERT INTO "courses" VALUES ('KNU1023','Engineers in Society',3,'Elective',1,'Science, Technology and Medicine','FK');
INSERT INTO "courses" VALUES ('KNU1033','Energy, Environment and Society',3,'Elective',1,'Science, Technology and Medicine','FK');
INSERT INTO "courses" VALUES ('KNU1053','Safety Management in Workplace',3,'Elective',1,'Science, Technology and Medicine','FK');
INSERT INTO "courses" VALUES ('KNU1073','Introduction to Solar Photovoltaic System',3,'Elective',1,'Science, Technology and Medicine','FK');
INSERT INTO "courses" VALUES ('KNU1093','Water Resources in Community Development',3,'Elective',1,'Science, Technology and Medicine','FK');
INSERT INTO "courses" VALUES ('KNU1103','Introduction to Hydro Power System',3,'Elective',1,'Science, Technology and Medicine','FK');
INSERT INTO "courses" VALUES ('MDU1013','Basic First Aid',3,'Elective',1,'Science, Technology and Medicine','FPSK');
INSERT INTO "courses" VALUES ('MDU1023','Introduction to Medical Genetics',3,'Elective',1,'Science, Technology and Medicine','FPSK');
INSERT INTO "courses" VALUES ('MDU1033','Healthy Lifestyle',3,'Elective',1,'Science, Technology and Medicine','FPSK');
INSERT INTO "courses" VALUES ('MDU1043','Introduction to Medical Entomology',3,'Elective',1,'Science, Technology and Medicine','FPSK');
INSERT INTO "courses" VALUES ('MDU1053','Introduction to Medical Parasitology',3,'Elective',1,'Science, Technology and Medicine','FPSK');
INSERT INTO "courses" VALUES ('MDU1073','Introduction to Biomedical Physiology',3,'Elective',1,'Science, Technology and Medicine','FPSK');
INSERT INTO "courses" VALUES ('MDU1083','Introduction to Health and Behaviour',3,'Elective',1,'Science, Technology and Medicine','FPSK');
INSERT INTO "courses" VALUES ('MDU1123','Introduction to Learning Disabilities',3,'Elective',1,'Science, Technology and Medicine','FPSK');
INSERT INTO "courses" VALUES ('MDU1133','Introduction to Community-Based Health Promotion',3,'Elective',1,'Science, Technology and Medicine','FPSK');
INSERT INTO "courses" VALUES ('MPU3182','Philosophy and Current Issues',2,'MPU',NULL,NULL,NULL);
INSERT INTO "courses" VALUES ('MPU3192','Appreciation of Ethics and Civilisation',2,'MPU',NULL,NULL,NULL);
INSERT INTO "courses" VALUES ('MPU3222','Foundation of Entrepreneurship Inculturation',2,'MPU',NULL,NULL,NULL);
INSERT INTO "courses" VALUES ('MPU3332','National Heritage',2,'MPU',NULL,NULL,NULL);
INSERT INTO "courses" VALUES ('MPU3342','Culture and Ethnicity in Malaysia',2,'MPU',NULL,NULL,NULL);
INSERT INTO "courses" VALUES ('MPU3432','Credited Co-curricular',2,'MPU',NULL,NULL,NULL);
INSERT INTO "courses" VALUES ('PBI1112','Preparatory English 1',2,'English',NULL,NULL,NULL);
INSERT INTO "courses" VALUES ('PBI1122','Preparatory English 2',2,'English',NULL,NULL,NULL);
INSERT INTO "courses" VALUES ('PBI2012','English Course 1',2,'English',NULL,NULL,NULL);
INSERT INTO "courses" VALUES ('PBI2022','English Course 2',2,'English',NULL,NULL,NULL);
INSERT INTO "courses" VALUES ('PBM2072','Malay Language',2,'Language',NULL,NULL,NULL);
INSERT INTO "courses" VALUES ('PBM2082','Advanced Malay Language for Communication',2,'Language',NULL,NULL,NULL);
INSERT INTO "courses" VALUES ('PBU0033','Iban for Communication',3,'Elective',5,'Linguistic and Communication','FBK');
INSERT INTO "courses" VALUES ('PBU1043','Japanese Language Level 1',3,'Elective',5,'Linguistic and Communication','FBK');
INSERT INTO "courses" VALUES ('PBU1073','French Level 1',3,'Elective',5,'Linguistic and Communication','FBK');
INSERT INTO "courses" VALUES ('PBU1103','Mandarin Level 1',3,'Elective',5,'Linguistic and Communication','FBK');
INSERT INTO "courses" VALUES ('PBU1133','Arabic Language Level 1',3,'Elective',5,'Linguistic and Communication','FBK');
INSERT INTO "courses" VALUES ('PBU2053','Japanese Language Level 2',3,'Elective',5,'Linguistic and Communication','FBK');
INSERT INTO "courses" VALUES ('PBU2083','French Level 2',3,'Elective',5,'Linguistic and Communication','FBK');
INSERT INTO "courses" VALUES ('PBU2113','Mandarin Level 2',3,'Elective',5,'Linguistic and Communication','FBK');
INSERT INTO "courses" VALUES ('PBU2143','Arabic Language Level 2',3,'Elective',5,'Linguistic and Communication','FBK');
INSERT INTO "courses" VALUES ('PBU3063','Japanese Language Level 3',3,'Elective',5,'Linguistic and Communication','FBK');
INSERT INTO "courses" VALUES ('PBU3093','French Level 3',3,'Elective',5,'Linguistic and Communication','FBK');
INSERT INTO "courses" VALUES ('PBU3123','Mandarin Level 3',3,'Elective',5,'Linguistic and Communication','FBK');
INSERT INTO "courses" VALUES ('PBU3153','Arabic Language Level 3',3,'Elective',5,'Linguistic and Communication','FBK');
INSERT INTO "courses" VALUES ('PPD1041','Soft Skill & Basic Volunteerism',1,'University',NULL,NULL,NULL);
INSERT INTO "courses" VALUES ('SSU1013','Basics of Social Science',3,'Elective',2,'Social Science and Humanities','FSSK');
INSERT INTO "courses" VALUES ('SSU1023','Basics of Anthropology and Sociology',3,'Elective',2,'Social Science and Humanities','FSSK');
INSERT INTO "courses" VALUES ('SSU1033','Introduction to Psychology',3,'Elective',2,'Social Science and Humanities','FSSK');
INSERT INTO "courses" VALUES ('SSU1053','Introduction to Social Interaction',3,'Elective',2,'Social Science and Humanities','FSSK');
INSERT INTO "courses" VALUES ('STU1013','Introduction to Biotechnology',3,'Elective',1,'Science, Technology and Medicine','FSTS');
INSERT INTO "courses" VALUES ('STU1033','Aquatic Science and Daily Life',3,'Elective',1,'Science, Technology and Medicine','FSTS');
INSERT INTO "courses" VALUES ('STU1043','Introduction to Plant Physiology',3,'Elective',1,'Science, Technology and Medicine','FSTS');
INSERT INTO "courses" VALUES ('STU2063','Ecotourism Industry in Malaysia',3,'Elective',1,'Science, Technology and Medicine','FSTS');
INSERT INTO "courses" VALUES ('STU2073','Natural Resource Managements',3,'Elective',1,'Science, Technology and Medicine','FSTS');
INSERT INTO "courses" VALUES ('TMA3084','Software Engineering Laboratory',4,'Core',NULL,NULL,NULL);
INSERT INTO "courses" VALUES ('TMA3093','Formal Method',3,'Core',NULL,NULL,NULL);
INSERT INTO "courses" VALUES ('TMA4093','Software Maintenance and Configuration Management',3,'Core',NULL,NULL,NULL);
INSERT INTO "courses" VALUES ('TMA4103','Software Testing',3,'Core',NULL,NULL,NULL);
INSERT INTO "courses" VALUES ('TMA4113','Software Security Engineering',3,'Core',NULL,NULL,NULL);
INSERT INTO "courses" VALUES ('TMF1014','System Analysis and Design',4,'Core',NULL,NULL,NULL);
INSERT INTO "courses" VALUES ('TMF1214','Computer Architecture',4,'Core',NULL,NULL,NULL);
INSERT INTO "courses" VALUES ('TMF1254','Communication and Computer Network',4,'Core',NULL,NULL,NULL);
INSERT INTO "courses" VALUES ('TMF1414','Introduction to Programming',4,'Core',NULL,NULL,NULL);
INSERT INTO "courses" VALUES ('TMF1434','Data Structure and Algorithm',4,'Core',NULL,NULL,NULL);
INSERT INTO "courses" VALUES ('TMF1814','Discrete Mathematics',4,'Core',NULL,NULL,NULL);
INSERT INTO "courses" VALUES ('TMF1874','Mathematics for Computing',4,'Core',NULL,NULL,NULL);
INSERT INTO "courses" VALUES ('TMF1883','Automata Theory',3,'Core',NULL,NULL,NULL);
INSERT INTO "courses" VALUES ('TMF1913','System Analysis and Design',3,'Core',NULL,NULL,NULL);
INSERT INTO "courses" VALUES ('TMF2034','Database Concept & Design',4,'Core',NULL,NULL,NULL);
INSERT INTO "courses" VALUES ('TMF2234','Operating System',4,'Core',NULL,NULL,NULL);
INSERT INTO "courses" VALUES ('TMF2243','Object Oriented Software Engineering',3,'Core',NULL,NULL,NULL);
INSERT INTO "courses" VALUES ('TMF2263','Human Computer Interaction',3,'Core',NULL,NULL,NULL);
INSERT INTO "courses" VALUES ('TMF2954','Java Programming',4,'Core',NULL,NULL,NULL);
INSERT INTO "courses" VALUES ('TMF2964','Software Economics',4,'Core',NULL,NULL,NULL);
INSERT INTO "courses" VALUES ('TMF2973','Software Requirement Engineering',3,'Core',NULL,NULL,NULL);
INSERT INTO "courses" VALUES ('TMF3012','Ethics and Professionalism',2,'Core',NULL,NULL,NULL);
INSERT INTO "courses" VALUES ('TMF3113','Project Management',3,'Core',NULL,NULL,NULL);
INSERT INTO "courses" VALUES ('TMF39412','Industrial Training',12,'Core',NULL,NULL,NULL);
INSERT INTO "courses" VALUES ('TMF3963','Ethics and Professionalism',3,'Core',NULL,NULL,NULL);
INSERT INTO "courses" VALUES ('TMF3973','Web Application Development',3,'Core',NULL,NULL,NULL);
INSERT INTO "courses" VALUES ('TMF4034','Technopreneurship and Product Development',4,'Core',NULL,NULL,NULL);
INSERT INTO "courses" VALUES ('TMF4913','Final Year Project I',3,'Core',NULL,NULL,NULL);
INSERT INTO "courses" VALUES ('TMF4935','Final Year Project II',5,'Core',NULL,NULL,NULL);
INSERT INTO "courses" VALUES ('TMI2053','Information Systems in Organisations',3,'Core',NULL,NULL,NULL);
INSERT INTO "courses" VALUES ('TMI2073','Advance Database Management System',3,'Core',NULL,NULL,NULL);
INSERT INTO "courses" VALUES ('TMI2104','Web-based System Development',4,'Core',NULL,NULL,NULL);
INSERT INTO "courses" VALUES ('TMI2113','Object Oriented Software Development',3,'Core',NULL,NULL,NULL);
INSERT INTO "courses" VALUES ('TMI2123','Intelligent Systems',3,'Core',NULL,NULL,NULL);
INSERT INTO "courses" VALUES ('TMI3013','Information System Laboratory',3,'Core',NULL,NULL,NULL);
INSERT INTO "courses" VALUES ('TMI3053','Human Computer Interaction',3,'Core',NULL,NULL,NULL);
INSERT INTO "courses" VALUES ('TMI3073','Human Centered Technology',3,'Core',NULL,NULL,NULL);
INSERT INTO "courses" VALUES ('TMI4013','Data Mining',3,'Core',NULL,NULL,NULL);
INSERT INTO "courses" VALUES ('TMI4033','Collective Intelligence',3,'Core',NULL,NULL,NULL);
INSERT INTO "courses" VALUES ('TMI4093','Advanced Topics in Information Systems',3,'Core',NULL,NULL,NULL);
INSERT INTO "courses" VALUES ('TMI4133','Computer Security',3,'Core',NULL,NULL,NULL);
INSERT INTO "courses" VALUES ('TMN1003','Systematic Innovation and Innovative Problem Solving',3,'Core',NULL,NULL,NULL);
INSERT INTO "courses" VALUES ('TMN2073','Computer Security',3,'Core',NULL,NULL,NULL);
INSERT INTO "courses" VALUES ('TMN2223','Object Oriented Software Development',3,'Core',NULL,NULL,NULL);
INSERT INTO "courses" VALUES ('TMN2243','Human Computer Interaction',3,'Core',NULL,NULL,NULL);
INSERT INTO "courses" VALUES ('TMN3093','Computer System Administration and Management',3,'Core',NULL,NULL,NULL);
INSERT INTO "courses" VALUES ('TMN3213','Internetworking Technology Laboratory',3,'Core',NULL,NULL,NULL);
INSERT INTO "courses" VALUES ('TMN3223','Web Application Development',3,'Core',NULL,NULL,NULL);
INSERT INTO "courses" VALUES ('TMN4013','Distributed System',3,'Core',NULL,NULL,NULL);
INSERT INTO "courses" VALUES ('TMN4033','Embedded System',3,'Core',NULL,NULL,NULL);
INSERT INTO "courses" VALUES ('TMN4113','Network Performance and Simulation',3,'Core',NULL,NULL,NULL);
INSERT INTO "courses" VALUES ('TMN4133','System Programming',3,'Core',NULL,NULL,NULL);
INSERT INTO "courses" VALUES ('TMN4143','Wireless and Broadband Networks',3,'Core',NULL,NULL,NULL);
INSERT INTO "courses" VALUES ('TMS1003','Systematic Innovation and Innovative Problem Solving',3,'Core',NULL,NULL,NULL);
INSERT INTO "courses" VALUES ('TMS2033','Differential Equations',3,'Core',NULL,NULL,NULL);
INSERT INTO "courses" VALUES ('TMS2813','Computational Science Laboratory',3,'Core',NULL,NULL,NULL);
INSERT INTO "courses" VALUES ('TMS2833','Object Oriented Software Development',3,'Core',NULL,NULL,NULL);
INSERT INTO "courses" VALUES ('TMS2843','Human Computer Interaction',3,'Core',NULL,NULL,NULL);
INSERT INTO "courses" VALUES ('TMS2853','Numerical Methods',3,'Core',NULL,NULL,NULL);
INSERT INTO "courses" VALUES ('TMS3033','Operational Research',3,'Core',NULL,NULL,NULL);
INSERT INTO "courses" VALUES ('TMS3093','Mathematical Modelling and Simulation',3,'Core',NULL,NULL,NULL);
INSERT INTO "courses" VALUES ('TMS3853','Web Application Development',3,'Core',NULL,NULL,NULL);
INSERT INTO "courses" VALUES ('TMS4013','Parallel Processing',3,'Core',NULL,NULL,NULL);
INSERT INTO "courses" VALUES ('TMS4033','Statistical Data Analysis',3,'Core',NULL,NULL,NULL);
INSERT INTO "courses" VALUES ('TMS4853','Computer Security',3,'Core',NULL,NULL,NULL);
INSERT INTO "courses" VALUES ('TMT1003','Systematic Innovation and Innovative Problem Solving',3,'Core',NULL,NULL,NULL);
INSERT INTO "courses" VALUES ('TMT2033','Computer Graphics',3,'Core',NULL,NULL,NULL);
INSERT INTO "courses" VALUES ('TMT2673','Object Oriented Software Development',3,'Core',NULL,NULL,NULL);
INSERT INTO "courses" VALUES ('TMT2703','UI/UX Design',3,'Core',NULL,NULL,NULL);
INSERT INTO "courses" VALUES ('TMT2713','Human Computer Interaction',3,'Core',NULL,NULL,NULL);
INSERT INTO "courses" VALUES ('TMT3123','Computer Game Design and Development',3,'Core',NULL,NULL,NULL);
INSERT INTO "courses" VALUES ('TMT3693','Web Application Development',3,'Core',NULL,NULL,NULL);
INSERT INTO "courses" VALUES ('TMT3703','Mobile Application Development',3,'Core',NULL,NULL,NULL);
INSERT INTO "courses" VALUES ('TMT4113','Data Visualisation',3,'Core',NULL,NULL,NULL);
INSERT INTO "courses" VALUES ('TMT4663','Data Mining',3,'Core',NULL,NULL,NULL);
INSERT INTO "courses" VALUES ('TMT4703','Distributed System',3,'Core',NULL,NULL,NULL);
INSERT INTO "courses" VALUES ('TMT4713','Computer Security',3,'Core',NULL,NULL,NULL);
INSERT INTO "courses" VALUES ('TMU1013','Introduction to Computer Technologies',3,'Elective',1,'Science, Technology and Medicine','FSKTM');
INSERT INTO "courses" VALUES ('TMU1023','Ethics in Information Technology',3,'Elective',1,'Science, Technology and Medicine','FSKTM');
INSERT INTO "courses" VALUES ('TMU1043','Multimedia Technology',3,'Elective',1,'Science, Technology and Medicine','FSKTM');
INSERT INTO "courses" VALUES ('TMU1053','Mathematics in Daily Life',3,'Elective',1,'Science, Technology and Medicine','FSKTM');
INSERT INTO "courses" VALUES ('TMF1893','Probability & Statistics',3,'Core',NULL,NULL,NULL);
INSERT INTO "courses" VALUES ('TMF2673','Object Oriented Software Development',3,'Core',NULL,NULL,NULL);
INSERT INTO "courses" VALUES ('TMN4935','Final Year Project II',5,'Core',NULL,NULL,NULL);
INSERT INTO "courses" VALUES ('TMF3093','Formal Method',3,'Core',NULL,NULL,NULL);
INSERT INTO "courses" VALUES ('TMF3084','Software Engineering Laboratory',4,'Core',NULL,NULL,NULL);
INSERT INTO "programme_courses" VALUES (573,'IS','MPU3222',1,1);
INSERT INTO "programme_courses" VALUES (574,'IS','PBI1112',1,1);
INSERT INTO "programme_courses" VALUES (575,'IS','PPD1041',1,1);
INSERT INTO "programme_courses" VALUES (576,'IS','TMF1014',1,1);
INSERT INTO "programme_courses" VALUES (577,'IS','TMF1414',1,1);
INSERT INTO "programme_courses" VALUES (578,'IS','TMF1814',1,1);
INSERT INTO "programme_courses" VALUES (579,'IS','MPU3432',1,2);
INSERT INTO "programme_courses" VALUES (580,'IS','PBI1122',1,2);
INSERT INTO "programme_courses" VALUES (581,'IS','TMF1214',1,2);
INSERT INTO "programme_courses" VALUES (582,'IS','TMF1254',1,2);
INSERT INTO "programme_courses" VALUES (583,'IS','TMF1434',1,2);
INSERT INTO "programme_courses" VALUES (584,'IS','TMF1874',1,2);
INSERT INTO "programme_courses" VALUES (585,'IS','MPU3192',2,1);
INSERT INTO "programme_courses" VALUES (586,'IS','PBI2012',2,1);
INSERT INTO "programme_courses" VALUES (587,'IS','TMF2034',2,1);
INSERT INTO "programme_courses" VALUES (588,'IS','TMF2234',2,1);
INSERT INTO "programme_courses" VALUES (589,'IS','TMI2113',2,1);
INSERT INTO "programme_courses" VALUES (590,'IS','TMI2123',2,1);
INSERT INTO "programme_courses" VALUES (591,'IS','MPU3182',2,2);
INSERT INTO "programme_courses" VALUES (592,'IS','MPU3332',2,2);
INSERT INTO "programme_courses" VALUES (593,'IS','PBI2022',2,2);
INSERT INTO "programme_courses" VALUES (594,'IS','TMF2954',2,2);
INSERT INTO "programme_courses" VALUES (595,'IS','TMI2053',2,2);
INSERT INTO "programme_courses" VALUES (596,'IS','TMI2073',2,2);
INSERT INTO "programme_courses" VALUES (597,'IS','TMI2104',2,2);
INSERT INTO "programme_courses" VALUES (598,'IS','PBM2072',3,1);
INSERT INTO "programme_courses" VALUES (599,'IS','TMF3012',3,1);
INSERT INTO "programme_courses" VALUES (600,'IS','TMF3113',3,1);
INSERT INTO "programme_courses" VALUES (601,'IS','TMI3013',3,1);
INSERT INTO "programme_courses" VALUES (602,'IS','TMI3053',3,1);
INSERT INTO "programme_courses" VALUES (603,'IS','TMI3073',3,1);
INSERT INTO "programme_courses" VALUES (604,'IS','TMF39412',3,2);
INSERT INTO "programme_courses" VALUES (605,'IS','TMF4913',4,1);
INSERT INTO "programme_courses" VALUES (606,'IS','TMI4013',4,1);
INSERT INTO "programme_courses" VALUES (607,'IS','TMI4033',4,1);
INSERT INTO "programme_courses" VALUES (608,'IS','TMF4034',4,2);
INSERT INTO "programme_courses" VALUES (609,'IS','TMF4935',4,2);
INSERT INTO "programme_courses" VALUES (610,'IS','TMI4093',4,2);
INSERT INTO "programme_courses" VALUES (611,'IS','TMI4133',4,2);
INSERT INTO "programme_courses" VALUES (612,'MC','MPU3222',1,1);
INSERT INTO "programme_courses" VALUES (613,'MC','PBI1112',1,1);
INSERT INTO "programme_courses" VALUES (614,'MC','PPD1041',1,1);
INSERT INTO "programme_courses" VALUES (615,'MC','TMF1414',1,1);
INSERT INTO "programme_courses" VALUES (616,'MC','TMF1814',1,1);
INSERT INTO "programme_courses" VALUES (617,'MC','TMF1913',1,1);
INSERT INTO "programme_courses" VALUES (618,'MC','TMT1003',1,1);
INSERT INTO "programme_courses" VALUES (619,'MC','MPU3432',1,2);
INSERT INTO "programme_courses" VALUES (620,'MC','PBI1122',1,2);
INSERT INTO "programme_courses" VALUES (621,'MC','TMF1214',1,2);
INSERT INTO "programme_courses" VALUES (622,'MC','TMF1434',1,2);
INSERT INTO "programme_courses" VALUES (623,'MC','TMF1893',1,2);
INSERT INTO "programme_courses" VALUES (624,'MC','TMF1254',1,2);
INSERT INTO "programme_courses" VALUES (625,'MC','MPU3192',2,1);
INSERT INTO "programme_courses" VALUES (626,'MC','PBI2012',2,1);
INSERT INTO "programme_courses" VALUES (627,'MC','TMF2234',2,1);
INSERT INTO "programme_courses" VALUES (628,'MC','TMT2033',2,1);
INSERT INTO "programme_courses" VALUES (629,'MC','TMT2703',2,1);
INSERT INTO "programme_courses" VALUES (630,'MC','TMF2673',2,1);
INSERT INTO "programme_courses" VALUES (631,'MC','MPU3182',2,2);
INSERT INTO "programme_courses" VALUES (632,'MC','MPU3332',2,2);
INSERT INTO "programme_courses" VALUES (633,'MC','PBI2022',2,2);
INSERT INTO "programme_courses" VALUES (634,'MC','TMF2954',2,2);
INSERT INTO "programme_courses" VALUES (635,'MC','TMT2713',2,2);
INSERT INTO "programme_courses" VALUES (636,'MC','TMF2034',2,2);
INSERT INTO "programme_courses" VALUES (637,'MC','PBM2072',3,1);
INSERT INTO "programme_courses" VALUES (638,'MC','TMF3113',3,1);
INSERT INTO "programme_courses" VALUES (639,'MC','TMT3123',3,1);
INSERT INTO "programme_courses" VALUES (640,'MC','TMT3693',3,1);
INSERT INTO "programme_courses" VALUES (641,'MC','TMT3703',3,1);
INSERT INTO "programme_courses" VALUES (642,'MC','TMF39412',3,2);
INSERT INTO "programme_courses" VALUES (643,'MC','TMF4034',4,1);
INSERT INTO "programme_courses" VALUES (644,'MC','TMF4913',4,1);
INSERT INTO "programme_courses" VALUES (645,'MC','TMT4663',4,1);
INSERT INTO "programme_courses" VALUES (646,'MC','TMT4703',4,1);
INSERT INTO "programme_courses" VALUES (647,'MC','TMF4935',4,2);
INSERT INTO "programme_courses" VALUES (648,'MC','TMT4113',4,2);
INSERT INTO "programme_courses" VALUES (649,'MC','TMT4713',4,2);
INSERT INTO "programme_courses" VALUES (650,'NC','MPU3222',1,1);
INSERT INTO "programme_courses" VALUES (651,'NC','PBI1112',1,1);
INSERT INTO "programme_courses" VALUES (652,'NC','PPD1041',1,1);
INSERT INTO "programme_courses" VALUES (653,'NC','TMF1414',1,1);
INSERT INTO "programme_courses" VALUES (654,'NC','TMF1814',1,1);
INSERT INTO "programme_courses" VALUES (655,'NC','TMF1913',1,1);
INSERT INTO "programme_courses" VALUES (656,'NC','TMN1003',1,1);
INSERT INTO "programme_courses" VALUES (657,'NC','MPU3432',1,2);
INSERT INTO "programme_courses" VALUES (658,'NC','PBI1122',1,2);
INSERT INTO "programme_courses" VALUES (659,'NC','TMF1214',1,2);
INSERT INTO "programme_courses" VALUES (660,'NC','TMF1434',1,2);
INSERT INTO "programme_courses" VALUES (661,'NC','TMF1893',1,2);
INSERT INTO "programme_courses" VALUES (662,'NC','TMF1254',1,2);
INSERT INTO "programme_courses" VALUES (663,'NC','MPU3192',2,1);
INSERT INTO "programme_courses" VALUES (664,'NC','PBI2012',2,1);
INSERT INTO "programme_courses" VALUES (665,'NC','TMF2034',2,1);
INSERT INTO "programme_courses" VALUES (666,'NC','TMF2234',2,1);
INSERT INTO "programme_courses" VALUES (667,'NC','TMN2223',2,1);
INSERT INTO "programme_courses" VALUES (668,'NC','MPU3182',2,2);
INSERT INTO "programme_courses" VALUES (669,'NC','MPU3332',2,2);
INSERT INTO "programme_courses" VALUES (670,'NC','PBI2022',2,2);
INSERT INTO "programme_courses" VALUES (671,'NC','TMF2954',2,2);
INSERT INTO "programme_courses" VALUES (672,'NC','TMN2073',2,2);
INSERT INTO "programme_courses" VALUES (673,'NC','TMN2243',2,2);
INSERT INTO "programme_courses" VALUES (674,'NC','PBM2072',3,1);
INSERT INTO "programme_courses" VALUES (675,'NC','TMF3963',3,1);
INSERT INTO "programme_courses" VALUES (676,'NC','TMF3113',3,1);
INSERT INTO "programme_courses" VALUES (677,'NC','TMN3093',3,1);
INSERT INTO "programme_courses" VALUES (678,'NC','TMN3213',3,1);
INSERT INTO "programme_courses" VALUES (679,'NC','TMN3223',3,1);
INSERT INTO "programme_courses" VALUES (680,'NC','TMF39412',3,2);
INSERT INTO "programme_courses" VALUES (681,'NC','TMF4034',4,1);
INSERT INTO "programme_courses" VALUES (682,'NC','TMF4913',4,1);
INSERT INTO "programme_courses" VALUES (683,'NC','TMN4013',4,1);
INSERT INTO "programme_courses" VALUES (684,'NC','TMN4133',4,1);
INSERT INTO "programme_courses" VALUES (685,'NC','TMN4935',4,2);
INSERT INTO "programme_courses" VALUES (686,'NC','TMN4113',4,2);
INSERT INTO "programme_courses" VALUES (687,'NC','TMN4143',4,2);
INSERT INTO "programme_courses" VALUES (688,'NC','TMN4033',4,2);
INSERT INTO "programme_courses" VALUES (689,'SE','MPU3222',1,1);
INSERT INTO "programme_courses" VALUES (690,'SE','PBI1112',1,1);
INSERT INTO "programme_courses" VALUES (691,'SE','PPD1041',1,1);
INSERT INTO "programme_courses" VALUES (692,'SE','TMF1414',1,1);
INSERT INTO "programme_courses" VALUES (693,'SE','TMF1814',1,1);
INSERT INTO "programme_courses" VALUES (694,'SE','TMF1913',1,1);
INSERT INTO "programme_courses" VALUES (695,'SE','MPU3432',1,2);
INSERT INTO "programme_courses" VALUES (696,'SE','PBI1122',1,2);
INSERT INTO "programme_courses" VALUES (697,'SE','TMF1254',1,2);
INSERT INTO "programme_courses" VALUES (698,'SE','TMF1434',1,2);
INSERT INTO "programme_courses" VALUES (699,'SE','TMF1883',1,2);
INSERT INTO "programme_courses" VALUES (700,'SE','TMF1214',1,2);
INSERT INTO "programme_courses" VALUES (701,'SE','MPU3192',2,1);
INSERT INTO "programme_courses" VALUES (702,'SE','PBI2012',2,1);
INSERT INTO "programme_courses" VALUES (703,'SE','TMF2034',2,1);
INSERT INTO "programme_courses" VALUES (704,'SE','TMF2234',2,1);
INSERT INTO "programme_courses" VALUES (705,'SE','TMF2243',2,1);
INSERT INTO "programme_courses" VALUES (706,'SE','MPU3182',2,2);
INSERT INTO "programme_courses" VALUES (707,'SE','MPU3332',2,2);
INSERT INTO "programme_courses" VALUES (708,'SE','PBI2022',2,2);
INSERT INTO "programme_courses" VALUES (709,'SE','TMF2263',2,2);
INSERT INTO "programme_courses" VALUES (710,'SE','TMF2954',2,2);
INSERT INTO "programme_courses" VALUES (711,'SE','TMF2964',2,2);
INSERT INTO "programme_courses" VALUES (712,'SE','TMF2973',2,2);
INSERT INTO "programme_courses" VALUES (713,'SE','PBM2072',3,1);
INSERT INTO "programme_courses" VALUES (714,'SE','TMF3963',3,1);
INSERT INTO "programme_courses" VALUES (715,'SE','TMF3113',3,1);
INSERT INTO "programme_courses" VALUES (716,'SE','TMF3973',3,1);
INSERT INTO "programme_courses" VALUES (717,'SE','TMF3093',3,1);
INSERT INTO "programme_courses" VALUES (718,'SE','TMF3084',3,1);
INSERT INTO "programme_courses" VALUES (719,'SE','TMF39412',3,2);
INSERT INTO "programme_courses" VALUES (720,'SE','TMF4913',4,1);
INSERT INTO "programme_courses" VALUES (721,'SE','TMF4034',4,1);
INSERT INTO "programme_courses" VALUES (722,'SE','TMA4093',4,1);
INSERT INTO "programme_courses" VALUES (723,'SE','TMF4935',4,2);
INSERT INTO "programme_courses" VALUES (724,'SE','TMA4103',4,2);
INSERT INTO "programme_courses" VALUES (725,'SE','TMA4113',4,2);
INSERT INTO "programme_courses" VALUES (726,'CS','MPU3222',1,1);
INSERT INTO "programme_courses" VALUES (727,'CS','PBI1112',1,1);
INSERT INTO "programme_courses" VALUES (728,'CS','PPD1041',1,1);
INSERT INTO "programme_courses" VALUES (729,'CS','TMF1414',1,1);
INSERT INTO "programme_courses" VALUES (730,'CS','TMF1814',1,1);
INSERT INTO "programme_courses" VALUES (731,'CS','TMS1003',1,1);
INSERT INTO "programme_courses" VALUES (732,'CS','TMF1913',1,1);
INSERT INTO "programme_courses" VALUES (733,'CS','MPU3432',1,2);
INSERT INTO "programme_courses" VALUES (734,'CS','PBI1122',1,2);
INSERT INTO "programme_courses" VALUES (735,'CS','TMF1893',1,2);
INSERT INTO "programme_courses" VALUES (736,'CS','TMF1214',1,2);
INSERT INTO "programme_courses" VALUES (737,'CS','TMF1254',1,2);
INSERT INTO "programme_courses" VALUES (738,'CS','TMF1434',1,2);
INSERT INTO "programme_courses" VALUES (739,'CS','MPU3192',2,1);
INSERT INTO "programme_courses" VALUES (740,'CS','PBI2012',2,1);
INSERT INTO "programme_courses" VALUES (741,'CS','TMF2034',2,1);
INSERT INTO "programme_courses" VALUES (742,'CS','TMF2234',2,1);
INSERT INTO "programme_courses" VALUES (743,'CS','TMS2833',2,1);
INSERT INTO "programme_courses" VALUES (744,'CS','TMS2033',2,1);
INSERT INTO "programme_courses" VALUES (745,'CS','MPU3182',2,2);
INSERT INTO "programme_courses" VALUES (746,'CS','MPU3332',2,2);
INSERT INTO "programme_courses" VALUES (747,'CS','PBI2022',2,2);
INSERT INTO "programme_courses" VALUES (748,'CS','TMF2954',2,2);
INSERT INTO "programme_courses" VALUES (749,'CS','TMS2843',2,2);
INSERT INTO "programme_courses" VALUES (750,'CS','TMS2853',2,2);
INSERT INTO "programme_courses" VALUES (751,'CS','TMS2813',2,2);
INSERT INTO "programme_courses" VALUES (752,'CS','PBM2072',3,1);
INSERT INTO "programme_courses" VALUES (753,'CS','TMF3113',3,1);
INSERT INTO "programme_courses" VALUES (754,'CS','TMF3963',3,1);
INSERT INTO "programme_courses" VALUES (755,'CS','TMS3853',3,1);
INSERT INTO "programme_courses" VALUES (756,'CS','TMS3033',3,1);
INSERT INTO "programme_courses" VALUES (757,'CS','TMS3093',3,1);
INSERT INTO "programme_courses" VALUES (758,'CS','TMF39412',3,2);
INSERT INTO "programme_courses" VALUES (759,'CS','TMF4034',4,1);
INSERT INTO "programme_courses" VALUES (760,'CS','TMF4913',4,1);
INSERT INTO "programme_courses" VALUES (761,'CS','TMS4013',4,1);
INSERT INTO "programme_courses" VALUES (762,'CS','TMS4033',4,1);
INSERT INTO "programme_courses" VALUES (763,'CS','TMF4935',4,2);
INSERT INTO "programme_courses" VALUES (764,'CS','TMS4853',4,2);
INSERT INTO "programme_courses" VALUES (767,'MC','TMF3963',3,1);
INSERT INTO "programmes" VALUES ('IS','Information Systems');
INSERT INTO "programmes" VALUES ('SE','Software Engineering');
INSERT INTO "programmes" VALUES ('MC','Multimedia Computing');
INSERT INTO "programmes" VALUES ('NC','Network Computing');
INSERT INTO "programmes" VALUES ('CS','Computational Science');
INSERT INTO "results" VALUES (177,1,'MPU3222','A',1);
INSERT INTO "results" VALUES (178,1,'PBI1112','A',1);
INSERT INTO "results" VALUES (179,1,'PPD1041','A-',1);
INSERT INTO "results" VALUES (180,1,'TMF1014','A-',1);
INSERT INTO "results" VALUES (181,1,'TMF1414','A-',1);
INSERT INTO "results" VALUES (182,1,'TMF1814','A',1);
INSERT INTO "results" VALUES (183,1,'MPU3432','A-',2);
INSERT INTO "results" VALUES (184,1,'PBI1122','A',2);
INSERT INTO "results" VALUES (185,1,'TMF1214','A',2);
INSERT INTO "results" VALUES (186,1,'TMF1254','B+',2);
INSERT INTO "results" VALUES (187,1,'TMF1434','B+',2);
INSERT INTO "results" VALUES (188,1,'TMF1874','A',2);
INSERT INTO "results" VALUES (189,5,'MPU3222','B+',1);
INSERT INTO "results" VALUES (190,5,'PBI1112','A',1);
INSERT INTO "results" VALUES (191,5,'PPD1041','A-',1);
INSERT INTO "results" VALUES (192,5,'TMF1414','B',1);
INSERT INTO "results" VALUES (193,5,'TMF1814','A-',1);
INSERT INTO "results" VALUES (194,5,'TMF1913','A',1);
INSERT INTO "results" VALUES (195,5,'TMN1003','B-',1);
INSERT INTO "results" VALUES (196,5,'MPU3432','A-',2);
INSERT INTO "results" VALUES (197,5,'PBI1122','A',2);
INSERT INTO "results" VALUES (198,5,'TMF1214','A',2);
INSERT INTO "results" VALUES (199,5,'TMF1254','B+',2);
INSERT INTO "results" VALUES (200,5,'TMF1434','F',2);
INSERT INTO "results" VALUES (201,5,'TMF1874','A',2);
INSERT INTO "results" VALUES (202,5,'MPU3192','A-',3);
INSERT INTO "results" VALUES (203,5,'PBI2012','A-',3);
INSERT INTO "results" VALUES (204,5,'TMF2034','F',3);
INSERT INTO "results" VALUES (205,5,'TMF2234','B',3);
INSERT INTO "results" VALUES (206,5,'TMN2223','B+',3);
INSERT INTO "results" VALUES (207,2,'MPU3222','B+',1);
INSERT INTO "results" VALUES (208,2,'PBI1112','A-',1);
INSERT INTO "results" VALUES (209,2,'PPD1041','A',1);
INSERT INTO "results" VALUES (210,2,'TMF1014','B+',1);
INSERT INTO "results" VALUES (211,2,'TMF1414','C+',1);
INSERT INTO "results" VALUES (212,2,'TMF1814','B+',1);
INSERT INTO "results" VALUES (213,2,'MPU3432','A-',2);
INSERT INTO "results" VALUES (214,2,'PBI1122','A-',2);
INSERT INTO "results" VALUES (215,2,'TMF1214','A-',2);
INSERT INTO "results" VALUES (216,2,'TMF1254','B-',2);
INSERT INTO "results" VALUES (217,2,'TMF1434','B+',2);
INSERT INTO "results" VALUES (218,2,'TMF1874','A-',2);
INSERT INTO "results" VALUES (219,2,'MPU3192','A-',3);
INSERT INTO "results" VALUES (220,2,'PBI2012','B+',3);
INSERT INTO "results" VALUES (221,2,'TMF2034','A-',3);
INSERT INTO "results" VALUES (222,2,'TMF2234','B+',3);
INSERT INTO "results" VALUES (223,2,'TMI2113','A-',3);
INSERT INTO "results" VALUES (224,2,'TMI2123','A-',3);
INSERT INTO "results" VALUES (225,2,'MPU3182','A-',4);
INSERT INTO "results" VALUES (226,2,'MPU3332','B+',4);
INSERT INTO "results" VALUES (227,2,'PBI2022','A-',4);
INSERT INTO "results" VALUES (228,2,'TMF2954','F',4);
INSERT INTO "results" VALUES (229,2,'TMI2053','A-',4);
INSERT INTO "results" VALUES (230,2,'TMI2073','B+',4);
INSERT INTO "results" VALUES (231,2,'TMI2104','B+',4);
INSERT INTO "results" VALUES (238,5,'TMF1893','B+',2);
INSERT INTO "results" VALUES (239,3,'TMF1414','F',1);
INSERT INTO "results" VALUES (240,3,'MPU3222','A',1);
INSERT INTO "results" VALUES (241,3,'PBI1112','A',1);
INSERT INTO "results" VALUES (242,3,'PPD1041','A-',1);
INSERT INTO "results" VALUES (243,3,'TMF1814','A-',1);
INSERT INTO "results" VALUES (244,3,'TMF1913','B-',1);
INSERT INTO "results" VALUES (272,6,'MPU3222','A',1);
INSERT INTO "results" VALUES (273,6,'PBI1112','A',1);
INSERT INTO "results" VALUES (274,6,'PPD1041','A',1);
INSERT INTO "results" VALUES (275,6,'TMF1414','B+',1);
INSERT INTO "results" VALUES (276,6,'TMF1913','A-',1);
INSERT INTO "results" VALUES (277,6,'TMS1003','B+',1);
INSERT INTO "results" VALUES (278,6,'TMF1814','B+',1);
INSERT INTO "results" VALUES (279,6,'MPU3432','A',2);
INSERT INTO "results" VALUES (280,6,'PBI1122','A-',2);
INSERT INTO "results" VALUES (281,6,'TMF1214','A-',2);
INSERT INTO "results" VALUES (282,6,'TMF1254','B+',2);
INSERT INTO "results" VALUES (283,6,'TMF1434','A-',2);
INSERT INTO "results" VALUES (284,6,'TMF1893','B-',2);
INSERT INTO "results" VALUES (285,6,'MPU3192','A-',3);
INSERT INTO "results" VALUES (286,6,'PBI2012','A-',3);
INSERT INTO "results" VALUES (287,6,'TMF2034','A-',3);
INSERT INTO "results" VALUES (288,6,'TMF2234','B+',3);
INSERT INTO "results" VALUES (289,6,'TMS2033','C+',3);
INSERT INTO "results" VALUES (290,6,'TMS2833','B+',3);
INSERT INTO "results" VALUES (291,6,'MPU3182','A-',4);
INSERT INTO "results" VALUES (292,6,'MPU3332','A-',4);
INSERT INTO "results" VALUES (293,6,'PBI2022','A-',4);
INSERT INTO "results" VALUES (294,6,'TMF2954','C+',4);
INSERT INTO "results" VALUES (295,6,'TMS2813','B-',4);
INSERT INTO "results" VALUES (296,6,'TMS2843','B+',4);
INSERT INTO "results" VALUES (297,6,'TMS2853','C+',4);
INSERT INTO "student_elective_choices" VALUES (1,6,'GKU1043');
INSERT INTO "students" VALUES (1,'82808','Atiqah','12345','IS',2,1,3.76,37);
INSERT INTO "students" VALUES (2,'81234','Ali','12345','IS',3,1,3.22,71);
INSERT INTO "students" VALUES (3,'84567','Sarah','12345','SE',1,2,2.66,12);
INSERT INTO "students" VALUES (4,'85678','John','12345','MC',2,2,2.34,26);
INSERT INTO "students" VALUES (5,'86789','Mei Ling','12345','NC',2,2,3.02,49);
INSERT INTO "students" VALUES (6,'87890','Hakim','12345','CS',3,1,3.33,75);
INSERT INTO "study_plan" VALUES (18875,3,1,'TMF1414','Failed - Retake Required');
INSERT INTO "study_plan" VALUES (18876,3,1,'MPU3222','Passed');
INSERT INTO "study_plan" VALUES (18877,3,1,'PBI1112','Passed');
INSERT INTO "study_plan" VALUES (18878,3,1,'PPD1041','Passed');
INSERT INTO "study_plan" VALUES (18879,3,1,'TMF1814','Passed');
INSERT INTO "study_plan" VALUES (18880,3,1,'TMF1913','Passed');
INSERT INTO "study_plan" VALUES (18881,3,3,'TMF1414','Retake');
INSERT INTO "study_plan" VALUES (18882,3,2,'MPU3432','Planned');
INSERT INTO "study_plan" VALUES (18883,3,2,'PBI1122','Planned');
INSERT INTO "study_plan" VALUES (18884,3,2,'TMF1214','Planned');
INSERT INTO "study_plan" VALUES (18885,3,2,'TMF1254','Planned');
INSERT INTO "study_plan" VALUES (18886,3,2,'TMF1434','Blocked by Prerequisite');
INSERT INTO "study_plan" VALUES (18887,3,2,'TMF1883','Planned');
INSERT INTO "study_plan" VALUES (18888,3,3,'MPU3192','Planned');
INSERT INTO "study_plan" VALUES (18889,3,3,'PBI2012','Planned');
INSERT INTO "study_plan" VALUES (18890,3,3,'TMF2034','Planned');
INSERT INTO "study_plan" VALUES (18891,3,3,'TMF2234','Planned');
INSERT INTO "study_plan" VALUES (18892,3,3,'TMF2243','Blocked by Prerequisite');
INSERT INTO "study_plan" VALUES (18893,3,4,'TMF1434','Planned');
INSERT INTO "study_plan" VALUES (18894,3,4,'MPU3182','Planned');
INSERT INTO "study_plan" VALUES (18895,3,4,'MPU3332','Planned');
INSERT INTO "study_plan" VALUES (18896,3,4,'PBI2022','Planned');
INSERT INTO "study_plan" VALUES (18897,3,4,'TMF2263','Planned');
INSERT INTO "study_plan" VALUES (18898,3,4,'TMF2954','Blocked by Prerequisite');
INSERT INTO "study_plan" VALUES (18899,3,4,'TMF2964','Blocked by Prerequisite');
INSERT INTO "study_plan" VALUES (18900,3,4,'TMF2973','Planned');
INSERT INTO "study_plan" VALUES (18901,3,5,'TMF2243','Planned');
INSERT INTO "study_plan" VALUES (18902,3,5,'TMF2954','Planned');
INSERT INTO "study_plan" VALUES (18903,3,5,'TMF2964','Planned');
INSERT INTO "study_plan" VALUES (18904,3,5,'PBM2072','Planned');
INSERT INTO "study_plan" VALUES (18905,3,5,'TMF3084','Planned');
INSERT INTO "study_plan" VALUES (18906,3,5,'TMF3093','Planned');
INSERT INTO "study_plan" VALUES (18907,3,6,'TMF3113','Planned');
INSERT INTO "study_plan" VALUES (18908,3,6,'TMF3963','Planned');
INSERT INTO "study_plan" VALUES (18909,3,6,'TMF3973','Planned');
INSERT INTO "study_plan" VALUES (18910,3,7,'TMF39412','Industrial Training Only');
INSERT INTO "study_plan" VALUES (18911,3,8,'TMA4093','Planned');
INSERT INTO "study_plan" VALUES (18912,3,8,'TMF4034','Planned');
INSERT INTO "study_plan" VALUES (18913,3,8,'TMF4913','Planned');
INSERT INTO "study_plan" VALUES (18914,3,8,'TMA4103','Planned');
INSERT INTO "study_plan" VALUES (18915,3,8,'TMA4113','Planned');
INSERT INTO "study_plan" VALUES (18916,3,9,'TMF4935','Planned');
INSERT INTO "study_plan" VALUES (18917,1,1,'MPU3222','Passed');
INSERT INTO "study_plan" VALUES (18918,1,1,'PBI1112','Passed');
INSERT INTO "study_plan" VALUES (18919,1,1,'PPD1041','Passed');
INSERT INTO "study_plan" VALUES (18920,1,1,'TMF1014','Passed');
INSERT INTO "study_plan" VALUES (18921,1,1,'TMF1414','Passed');
INSERT INTO "study_plan" VALUES (18922,1,1,'TMF1814','Passed');
INSERT INTO "study_plan" VALUES (18923,1,2,'MPU3432','Passed');
INSERT INTO "study_plan" VALUES (18924,1,2,'PBI1122','Passed');
INSERT INTO "study_plan" VALUES (18925,1,2,'TMF1214','Passed');
INSERT INTO "study_plan" VALUES (18926,1,2,'TMF1254','Passed');
INSERT INTO "study_plan" VALUES (18927,1,2,'TMF1434','Passed');
INSERT INTO "study_plan" VALUES (18928,1,2,'TMF1874','Passed');
INSERT INTO "study_plan" VALUES (18929,1,3,'MPU3192','Planned');
INSERT INTO "study_plan" VALUES (18930,1,3,'PBI2012','Planned');
INSERT INTO "study_plan" VALUES (18931,1,3,'TMF2034','Planned');
INSERT INTO "study_plan" VALUES (18932,1,3,'TMF2234','Planned');
INSERT INTO "study_plan" VALUES (18933,1,3,'TMI2113','Planned');
INSERT INTO "study_plan" VALUES (18934,1,3,'TMI2123','Planned');
INSERT INTO "study_plan" VALUES (18935,1,4,'MPU3182','Planned');
INSERT INTO "study_plan" VALUES (18936,1,4,'MPU3332','Planned');
INSERT INTO "study_plan" VALUES (18937,1,4,'PBI2022','Planned');
INSERT INTO "study_plan" VALUES (18938,1,4,'TMF2954','Planned');
INSERT INTO "study_plan" VALUES (18939,1,4,'TMI2053','Planned');
INSERT INTO "study_plan" VALUES (18940,1,4,'TMI2073','Planned');
INSERT INTO "study_plan" VALUES (18941,1,4,'TMI2104','Planned');
INSERT INTO "study_plan" VALUES (18942,1,5,'PBM2072','Planned');
INSERT INTO "study_plan" VALUES (18943,1,5,'TMF3012','Planned');
INSERT INTO "study_plan" VALUES (18944,1,5,'TMF3113','Planned');
INSERT INTO "study_plan" VALUES (18945,1,5,'TMI3013','Planned');
INSERT INTO "study_plan" VALUES (18946,1,5,'TMI3053','Planned');
INSERT INTO "study_plan" VALUES (18947,1,5,'TMI3073','Planned');
INSERT INTO "study_plan" VALUES (18948,1,6,'TMF39412','Industrial Training Only');
INSERT INTO "study_plan" VALUES (18949,1,7,'TMF4913','Planned');
INSERT INTO "study_plan" VALUES (18950,1,7,'TMI4013','Planned');
INSERT INTO "study_plan" VALUES (18951,1,7,'TMI4033','Planned');
INSERT INTO "study_plan" VALUES (18952,1,8,'TMF4034','Planned');
INSERT INTO "study_plan" VALUES (18953,1,8,'TMF4935','Planned');
INSERT INTO "study_plan" VALUES (18954,1,8,'TMI4093','Planned');
INSERT INTO "study_plan" VALUES (18955,1,8,'TMI4133','Planned');
COMMIT;
