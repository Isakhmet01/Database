--Part A:
CREATE DATABASE advanced_lab;

CREATE TABLE employees (
    emp_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    department VARCHAR(50),
    salary INTEGER,
    hire_date DATE,
    status VARCHAR(20) DEFAULT 'Active'
);

CREATE TABLE departments (
    dept_id SERIAL PRIMARY KEY,
    dept_name VARCHAR(100),
    budget INTEGER,
    manager_id INTEGER
);

CREATE TABLE projects (
    project_id SERIAL PRIMARY KEY,
    project_name VARCHAR(100),
    dept_id INTEGER,
    start_date DATE,
    end_date DATE,
    budget INTEGER
);

-- Part B
INSERT INTO employees (first_name, last_name, department)
VALUES ('Aidar', 'Nurzhanov', 'IT');

INSERT INTO employees (first_name, last_name, department, salary, status)
VALUES ('Dana', 'Kairatova', 'HR', DEFAULT, DEFAULT);

INSERT INTO departments (dept_name, budget, manager_id)
VALUES
    ('IT', 150000, 1),
    ('HR', 80000, 2),
    ('Sales', 120000, 3);

INSERT INTO employees (first_name, last_name, department, hire_date, salary)
VALUES ('Murat', 'Bekov', 'Finance', CURRENT_DATE, 50000 * 1.1);

CREATE TEMP TABLE temp_employees AS
SELECT * FROM employees WHERE department = 'IT';

-- Part C
UPDATE employees
SET salary = salary * 1.10;

UPDATE employees
SET status = 'Senior'
WHERE salary > 60000 AND hire_date < '2020-01-01';

UPDATE employees
SET department = CASE
    WHEN salary > 80000 THEN 'Management'
    WHEN salary BETWEEN 50000 AND 80000 THEN 'Senior'
    ELSE 'Junior'
END;

UPDATE employees
SET department = DEFAULT
WHERE status = 'Inactive';

UPDATE departments
SET budget = (SELECT AVG(salary) * 1.2
              FROM employees
              WHERE employees.department = departments.dept_name);

UPDATE employees
SET salary = salary * 1.15,
    status = 'Promoted'
WHERE department = 'Sales';

-- Part D
DELETE FROM employees
WHERE status = 'Terminated';

DELETE FROM employees
WHERE salary < 40000
  AND hire_date > '2023-01-01'
  AND department IS NULL;

DELETE FROM departments
WHERE dept_id NOT IN (
    SELECT DISTINCT department
    FROM employees
    WHERE department IS NOT NULL
);

DELETE FROM projects
WHERE end_date < '2023-01-01'
RETURNING *;

-- Part E
INSERT INTO employees (first_name, last_name, salary, department)
VALUES ('Aigerim', 'Sultanova', NULL, NULL);

UPDATE employees
SET department = 'Unassigned'
WHERE department IS NULL;

DELETE FROM employees
WHERE salary IS NULL OR department IS NULL;


-- Part F
INSERT INTO employees (first_name, last_name, department)
VALUES ('Dias', 'Karimov', 'IT')
RETURNING emp_id, first_name || ' ' || last_name AS full_name;

UPDATE employees
SET salary = salary + 5000
WHERE department = 'IT'
RETURNING emp_id, salary - 5000 AS old_salary, salary AS new_salary;

DELETE FROM employees
WHERE hire_date < '2020-01-01'
RETURNING *;

-- Part G
INSERT INTO employees (first_name, last_name, department)
SELECT 'Askar', 'Tlegenov', 'IT'
WHERE NOT EXISTS (
    SELECT 1 FROM employees
    WHERE first_name = 'Askar' AND last_name = 'Tlegenov'
);

UPDATE employees
SET salary = salary *
    (CASE
        WHEN (SELECT budget FROM departments d WHERE d.dept_name = employees.department) > 100000
        THEN 1.10
        ELSE 1.05
     END);

INSERT INTO employees (first_name, last_name, department, salary)
VALUES
    ('Aliya', 'Serikova', 'HR', 40000),
    ('Nurzhan', 'Omarov', 'IT', 50000),
    ('Karina', 'Abdullaeva', 'Sales', 45000),
    ('Daniyar', 'Tuleshov', 'Finance', 55000),
    ('Zarina', 'Sabitova', 'Marketing', 42000);

UPDATE employees
SET salary = salary * 1.10
WHERE first_name IN ('Aliya', 'Nurzhan', 'Karina', 'Daniyar', 'Zarina');

CREATE TABLE employee_archive AS
SELECT * FROM employees WHERE status = 'Inactive';

DELETE FROM employees
WHERE status = 'Inactive';

UPDATE projects
SET end_date = end_date + INTERVAL '30 days'
WHERE budget > 50000
  AND (SELECT COUNT(*) FROM employees e WHERE e.department = projects.dept_id) > 3;
