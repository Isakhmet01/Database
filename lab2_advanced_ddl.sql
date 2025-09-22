-- Task 1.1
CREATE DATABASE university_main
  WITH OWNER = postgres
       TEMPLATE = template0
       ENCODING 'UTF8';

CREATE DATABASE university_archive
  WITH OWNER = postgres
       TEMPLATE = template0
       CONNECTION LIMIT 50;

CREATE DATABASE university_test
  WITH OWNER = postgres
       TEMPLATE = template0
       IS_TEMPLATE true
       CONNECTION LIMIT 10;

-- Task 1.2
CREATE TABLESPACE student_data
  OWNER postgres
  LOCATION 'C:\\pg_tables\\students';

CREATE TABLESPACE course_data
  OWNER postgres
  LOCATION 'C:\\pg_tables\\courses';

CREATE DATABASE university_distributed
  WITH OWNER = postgres
       TEMPLATE = template0
       TABLESPACE = student_data
       ENCODING 'LATIN9';

-- Task 2.1

CREATE TABLE students (
    student_id       SERIAL PRIMARY KEY,
    first_name       VARCHAR(50) NOT NULL,
    last_name        VARCHAR(50) NOT NULL,
    email            VARCHAR(100) UNIQUE NOT NULL,
    phone            VARCHAR(15),
    date_of_birth    DATE,
    enrollment_date  DATE,
    gpa              NUMERIC(4,2) DEFAULT 0.00,
    is_active        BOOLEAN DEFAULT true,
    graduation_year  SMALLINT
);

CREATE TABLE professors (
    professor_id     SERIAL PRIMARY KEY,
    first_name       VARCHAR(50) NOT NULL,
    last_name        VARCHAR(50) NOT NULL,
    email            VARCHAR(100) UNIQUE NOT NULL,
    office_number    VARCHAR(20),
    hire_date        DATE,
    salary           NUMERIC(12,2),
    is_tenured       BOOLEAN DEFAULT false,
    years_experience SMALLINT
);

CREATE TABLE courses (
    course_id        SERIAL PRIMARY KEY,
    course_code      VARCHAR(20) UNIQUE NOT NULL,
    course_title     VARCHAR(100) NOT NULL,
    description      TEXT,
    credits          SMALLINT DEFAULT 3,
    max_enrollment   INT,
    course_fee       NUMERIC(8,2),
    is_online        BOOLEAN DEFAULT false,
    created_at       TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Task 2.2
CREATE TABLE class_schedule (
    schedule_id   SERIAL PRIMARY KEY,
    course_id     INT REFERENCES courses(course_id),
    professor_id  INT REFERENCES professors(professor_id),
    classroom     VARCHAR(30),
    class_date    DATE NOT NULL,
    start_time    TIME WITHOUT TIME ZONE NOT NULL,
    end_time      TIME WITHOUT TIME ZONE NOT NULL,
    duration      INTERVAL
);

CREATE TABLE student_records (
    record_id             SERIAL PRIMARY KEY,
    student_id            INT REFERENCES students(student_id),
    course_id             INT REFERENCES courses(course_id),
    semester              VARCHAR(20),
    year                  INT,
    grade                 VARCHAR(2),
    attendance_percentage NUMERIC(4,1),
    submission_timestamp  TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    last_updated          TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

--Task 3.1
ALTER TABLE students
  ADD COLUMN middle_name VARCHAR(30),
  ADD COLUMN student_status VARCHAR(20) DEFAULT 'ACTIVE',
  ALTER COLUMN phone TYPE VARCHAR(20),
  ALTER COLUMN gpa SET DEFAULT 0.00;

ALTER TABLE professors
  ADD COLUMN department_code CHAR(5),
  ADD COLUMN research_area TEXT,
  ALTER COLUMN years_experience TYPE SMALLINT,
  ALTER COLUMN is_tenured SET DEFAULT false,
  ADD COLUMN last_promotion_date DATE;

ALTER TABLE courses
  ADD COLUMN prerequisite_course_id INT REFERENCES courses(course_id),
  ADD COLUMN difficulty_level SMALLINT,
  ALTER COLUMN course_code TYPE VARCHAR(10),
  ALTER COLUMN credits SET DEFAULT 3,
  ADD COLUMN lab_required BOOLEAN DEFAULT false;

-- Task 3.2
ALTER TABLE class_schedule
  ADD COLUMN room_capacity INT,
  DROP COLUMN duration,
  ADD COLUMN session_type VARCHAR(15),
  ALTER COLUMN classroom TYPE VARCHAR(30),
  ADD COLUMN equipment_needed TEXT;

ALTER TABLE student_records
  ADD COLUMN extra_credit_points NUMERIC(4,1) DEFAULT 0.0,
  ALTER COLUMN grade TYPE VARCHAR(5),
  ADD COLUMN final_exam_date DATE,
  DROP COLUMN last_updated;

-- Task 4.1
CREATE TABLE departments (
    department_id     SERIAL PRIMARY KEY,
    department_name   VARCHAR(100) NOT NULL,
    department_code   VARCHAR(10) UNIQUE NOT NULL,
    building          VARCHAR(50),
    phone_number      VARCHAR(20),
    budget            NUMERIC(12,2),
    established_year  INT
);

CREATE TABLE library_books (
    book_id     SERIAL PRIMARY KEY,
    isbn        VARCHAR(20) UNIQUE NOT NULL,
    title       VARCHAR(200) NOT NULL,
    author      VARCHAR(150),
    publisher   VARCHAR(100),
    publish_date DATE,
    price       NUMERIC(8,2),
    is_available BOOLEAN DEFAULT true,
    added_at    TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE student_book_loans (
    loan_id     SERIAL PRIMARY KEY,
    student_id  INT NOT NULL REFERENCES students(student_id),
    book_id     INT NOT NULL REFERENCES library_books(book_id),
    loan_date   DATE NOT NULL,
    due_date    DATE NOT NULL,
    return_date DATE,
    fine_amount NUMERIC(6,2) DEFAULT 0.00,
    status      VARCHAR(20) DEFAULT 'ongoing'
);

-- Task 4.2
ALTER TABLE professors
  ADD COLUMN department_id INT;

ALTER TABLE students
  ADD COLUMN advisor_id INT;

ALTER TABLE courses
  ADD COLUMN department_id INT;

CREATE TABLE grade_scale (
    grade_id       SERIAL PRIMARY KEY,
    letter_grade   CHAR(2) NOT NULL,
    min_percentage NUMERIC(4,1) NOT NULL,
    max_percentage NUMERIC(4,1) NOT NULL,
    gpa_points     NUMERIC(4,2) NOT NULL
);

CREATE TABLE semester_calendar (
    semester_id          SERIAL PRIMARY KEY,
    semester_name        VARCHAR(20) NOT NULL,
    academic_year        INT NOT NULL,
    start_date           DATE NOT NULL,
    end_date             DATE NOT NULL,
    registration_deadline TIMESTAMPTZ NOT NULL,
    is_current           BOOLEAN DEFAULT false
);

-- Task 5.1
DROP TABLE IF EXISTS student_book_loans CASCADE;
DROP TABLE IF EXISTS library_books CASCADE;
DROP TABLE IF EXISTS grade_scale CASCADE;

CREATE TABLE grade_scale (
    grade_id       SERIAL PRIMARY KEY,
    letter_grade   CHAR(2) NOT NULL,
    min_percentage NUMERIC(4,1) NOT NULL,
    max_percentage NUMERIC(4,1) NOT NULL,
    gpa_points     NUMERIC(4,2) NOT NULL,
    description    TEXT
);

DROP TABLE IF EXISTS semester_calendar CASCADE;

CREATE TABLE semester_calendar (
    semester_id           SERIAL PRIMARY KEY,
    semester_name         VARCHAR(20) NOT NULL,
    academic_year         INT NOT NULL,
    start_date            DATE NOT NULL,
    end_date              DATE NOT NULL,
    registration_deadline TIMESTAMPTZ NOT NULL,
    is_current            BOOLEAN DEFAULT false
);

-- Task 5.2
DROP DATABASE IF EXISTS university_test;
DROP DATABASE IF EXISTS university_distributed;

CREATE DATABASE university_backup
  WITH OWNER = postgres
       TEMPLATE = university_main;


