# Personalized Study Plan Generator for Graduation Readiness

## Overview

The Personalized Study Plan Generator for Graduation Readiness is a web-based academic planning system developed to assist university students in planning their academic journey toward graduation.

The system automatically generates personalized semester-by-semester study plans based on completed courses, prerequisite rules, failed subjects, credit-hour limitations, programme curriculum structures, and graduation requirements.

## Features

### Student Module

* Student Login
* Dashboard Overview
* Graduation Readiness Monitoring
* Smart Study Plan Generation
* Update Academic Results
* Elective Selection
* Progress Tracking
* Graduation Prediction

### Admin Module

* Admin Login
* Manage Students
* Manage Courses
* Manage Programme Curriculum
* Manage Prerequisites
* Monitor Student Progress

## System Functions

* Automatic prerequisite checking
* Failed subject retake planning
* Credit hour limit validation
* Industrial Training scheduling
* Final Year Project scheduling
* Graduation readiness forecasting
* Personalized study plan generation

## Technology Stack

* Python Flask
* SQLite Database
* HTML
* CSS
* Bootstrap
* Jinja2 Templates

## Project Structure

```text
app.py
database.db.sql
requirements.txt

templates/
static/
```

## Key Features

- Student Login
- Admin Login
- Smart Study Plan Generation
- Rule-Based Prerequisite Validation
- Failed Subject Retake Scheduling
- Graduation Readiness Monitoring
- Industrial Training Planning
- FYP I & FYP II Dependency Validation
- Elective Recommendation
- Extended Semester Support

## System Screenshots

### Student Login

![Student Login](images/student%20login.png)

### Student Dashboard

![Dashboard](images/student%20dashboard.png)

### Generate Study Plan

![Generate Plan](images/generate%20plan.png)

### Study Plan

![Study Plan](images/study%20plan.png)

### Update Result

![Update Result](images/update%20result.png)

### Admin Dashboard

![Admin Dashboard](images/admin%20dashboard.png)

### Manage Subjects

![Manage Subjects](images/admin%20manage%20subject.png)

### Manage Students

![Manage Students](images/admin%20manage%20student.png)

## Installation Guide

### 1. Clone the Repository

```bash
git clone https://github.com/nurratiiqah/personalized-study-plan-generator.git
cd personalized-study-plan-generator
```

### 2. Install Required Packages

```bash
pip install -r requirements.txt
```

### 3. Prepare Database

Import the provided SQL file into SQLite:

```bash
sqlite3 database.db < database.db.sql
```

Alternatively, open the database using DB Browser for SQLite and execute the SQL script.

### 4. Run the Application

```bash
python app.py
```

### 5. Access the System

Open a web browser and visit:

```text
http://127.0.0.1:5000
```

### Default Accounts

**Admin**

Username: admin
Password: admin123

**Student**

Use any student account available in the database.

## Developer

Nur Atiqah Aziera Binti Khamijas

Bachelor of Information Systems

Faculty of Computer Science and Information Technology (FCSIT)

Universiti Malaysia Sarawak (UNIMAS)

## Final Year Project

Personalized Study Plan Generator for Graduation Readiness
