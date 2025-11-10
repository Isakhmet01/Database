-- PART 1
CREATE TABLE employees (
    emp_id INT PRIMARY KEY,
    emp_name VARCHAR(50),
    dept_id INT,
    salary DECIMAL(10, 2)
);

CREATE TABLE departments (
    dept_id INT PRIMARY KEY,
    dept_name VARCHAR(50),
    location VARCHAR(50)
);

CREATE TABLE projects (
    project_id INT PRIMARY KEY,
    project_name VARCHAR(50),
    dept_id INT,
    budget DECIMAL(10, 2)
);

INSERT INTO employees (emp_id, emp_name, dept_id, salary) VALUES
(1, 'John Smith', 101, 50000),
(2, 'Jane Doe', 102, 60000),
(3, 'Mike Johnson', 101, 55000),
(4, 'Sarah Williams', 103, 65000),
(5, 'Tom Brown', NULL, 45000);

INSERT INTO departments (dept_id, dept_name, location) VALUES
(101, 'IT', 'Building A'),
(102, 'HR', 'Building B'),
(103, 'Finance', 'Building C'),
(104, 'Marketing', 'Building D');

INSERT INTO projects (project_id, project_name, dept_id, budget) VALUES
(1, 'Website Redesign', 101, 100000),
(2, 'Employee Training', 102, 50000),
(3, 'Budget Analysis', 103, 75000),
(4, 'Cloud Migration', 101, 150000),
(5, 'AI Research', NULL, 200000);


-- PART 2
CREATE VIEW employee_details AS
SELECT e.emp_name,e.salary, d.dept_name, d.location
FROM employees e
INNER JOIN departments d ON e.dept_id = d.dept_id;

SELECT * FROM employee_details;
-- Question: How many rows are returned? Why doesn't Tom Brown appear?
-- Answer: 4 rows. Tom Brown does not appear because his dept_id is NULL.

CREATE VIEW dept_statistics AS
SELECT d.dept_name,
    COUNT(e.emp_id) AS employee_count,
    COALESCE(AVG(e.salary), 0) AS avg_salary,
    COALESCE(MAX(e.salary), 0) AS max_salary,
    COALESCE(MIN(e.salary), 0) AS min_salary
FROM departments d
LEFT JOIN employees e ON d.dept_id = e.dept_id
GROUP BY d.dept_name;

SELECT * FROM dept_statistics
ORDER BY employee_count DESC;

CREATE VIEW project_overview AS
SELECT p.project_name, p.budget, d.dept_name, d.location,
    COUNT(e.emp_id) AS team_size
FROM projects p
LEFT JOIN departments d ON p.dept_id = d.dept_id
LEFT JOIN employees e ON d.dept_id = e.dept_id
GROUP BY p.project_name, p.budget, d.dept_name, d.location;

CREATE VIEW high_earners AS
SELECT e.emp_name, e.salary, d.dept_name
FROM employees e
INNER JOIN departments d ON e.dept_id = d.dept_id
WHERE e.salary > 55000;

-- Question: What happens when you query this view? Can you see all high-earning employees?
-- Answer: Only employees with salary > 55000 and assigned to a department are shown.
-- Employees without a department (like Tom Brown) are not visible in this view.


-- PART 3
CREATE OR REPLACE VIEW employee_details AS
SELECT  e.emp_name, e.salary, d.dept_name, d.location,
    CASE
        WHEN e.salary > 60000 THEN 'High'
        WHEN e.salary > 50000 THEN 'Medium'
        ELSE 'Standard'
    END AS salary_grade
FROM employees e
INNER JOIN departments d ON e.dept_id = d.dept_id;

ALTER VIEW high_earners RENAME TO top_performers;

SELECT * FROM top_performers;

CREATE VIEW temp_view AS
SELECT emp_name, salary, dept_id
FROM employees
WHERE salary < 50000;

DROP VIEW temp_view;


-- PART 4
CREATE VIEW employee_salaries AS
SELECT emp_id, emp_name, dept_id, salary
FROM employees;

UPDATE employee_salaries
SET salary = 52000
WHERE emp_name = 'John Smith';

SELECT * FROM employees WHERE emp_name = 'John Smith';
-- Question: Did the underlying table get updated?
-- Answer: Yes, because the view is directly based on the employees table without aggregation or joins.

INSERT INTO employee_salaries (emp_id, emp_name, dept_id, salary)
VALUES (6, 'Alice Johnson', 102, 58000);

SELECT * FROM employees WHERE emp_name = 'Alice Johnson';
-- Question: Was the insert successful? Check the employees table.
-- Answer: Yes, the new row appears in employees because the view is updatable.

CREATE VIEW it_employees AS
SELECT emp_id, emp_name, dept_id, salary
FROM employees
WHERE dept_id = 101
WITH LOCAL CHECK OPTION;

INSERT INTO it_employees (emp_id, emp_name, dept_id, salary)
VALUES (7, 'Bob Wilson', 103, 60000);
-- Question: What error message do you receive? Why?
-- Answer: The insertion fails with a CHECK OPTION violation,
-- because the new record's dept_id = 103 does not satisfy the view condition (dept_id = 101).


-- PART 5
CREATE MATERIALIZED VIEW dept_summary_mv AS
SELECT  d.dept_id, d.dept_name,
    COUNT(DISTINCT e.emp_id) AS total_employees,
    COALESCE(SUM(e.salary), 0) AS total_salaries,
    COUNT(DISTINCT p.project_id) AS total_projects,
    COALESCE(SUM(p.budget), 0) AS total_project_budget
FROM departments d
LEFT JOIN employees e ON d.dept_id = e.dept_id
LEFT JOIN projects p ON d.dept_id = p.dept_id
GROUP BY d.dept_id, d.dept_name
WITH DATA;

INSERT INTO employees (emp_id, emp_name, dept_id, salary)
VALUES (8, 'Charlie Brown', 101, 54000);

SELECT * FROM dept_summary_mv ORDER BY total_employees DESC;

REFRESH MATERIALIZED VIEW dept_summary_mv;

SELECT * FROM dept_summary_mv ORDER BY total_employees DESC;
-- Question: What's the difference before and after refresh?
-- Answer: Before refresh, the new employee is not included.
-- After refresh, the materialized view updates its stored data and includes the new record.

CREATE UNIQUE INDEX idx_dept_summary_mv_dept_id
ON dept_summary_mv (dept_id);

REFRESH MATERIALIZED VIEW CONCURRENTLY dept_summary_mv;
-- Question: What's the advantage of CONCURRENTLY option?
-- Answer: It allows refreshing the materialized view without locking it,
-- so users can still query the view during the refresh.

CREATE MATERIALIZED VIEW project_stats_mv AS
SELECT  p.project_name, p.budget, d.dept_name, COUNT(e.emp_id) AS employee_count
FROM projects p
LEFT JOIN departments d ON p.dept_id = d.dept_id
LEFT JOIN employees e ON d.dept_id = e.dept_id
GROUP BY p.project_name, p.budget, d.dept_name
WITH NO DATA;

SELECT * FROM project_stats_mv;
-- Question: What error do you get? How do you fix it?
-- Answer: Error: Materialized view "project_stats_mv" has not been populated yet.
-- To fix it, run: REFRESH MATERIALIZED VIEW project_stats_mv;


-- PART 6
CREATE ROLE analyst;
CREATE ROLE data_viewer WITH LOGIN PASSWORD 'viewer123';
CREATE ROLE report_user WITH LOGIN PASSWORD 'report456';

SELECT rolname FROM pg_roles WHERE rolname NOT LIKE 'pg_%';

CREATE ROLE db_creator WITH LOGIN CREATEDB PASSWORD 'creator789';
CREATE ROLE user_manager WITH LOGIN CREATEROLE PASSWORD 'manager101';
CREATE ROLE admin_user WITH LOGIN SUPERUSER PASSWORD 'admin999';

GRANT SELECT ON employees, departments, projects TO analyst;
GRANT ALL PRIVILEGES ON employee_details TO data_viewer;
GRANT SELECT, INSERT ON employees TO report_user;

CREATE ROLE hr_team;
CREATE ROLE finance_team;
CREATE ROLE it_team;

CREATE ROLE hr_user1 WITH LOGIN PASSWORD 'hr001';
CREATE ROLE hr_user2 WITH LOGIN PASSWORD 'hr002';
CREATE ROLE finance_user1 WITH LOGIN PASSWORD 'fin001';

GRANT hr_team TO hr_user1;
GRANT hr_team TO hr_user2;
GRANT finance_team TO finance_user1;

GRANT SELECT, UPDATE ON employees TO hr_team;
GRANT SELECT ON dept_statistics TO finance_team;

REVOKE UPDATE ON employees FROM hr_team;
REVOKE hr_team FROM hr_user2;
REVOKE ALL PRIVILEGES ON employee_details FROM data_viewer;

ALTER ROLE analyst WITH LOGIN PASSWORD 'analyst123';
ALTER ROLE user_manager WITH SUPERUSER;
ALTER ROLE analyst WITH PASSWORD NULL;
ALTER ROLE data_viewer WITH CONNECTION LIMIT 5;


-- PART 7
CREATE ROLE read_only;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO read_only;

CREATE ROLE junior_analyst WITH LOGIN PASSWORD 'junior123';
CREATE ROLE senior_analyst WITH LOGIN PASSWORD 'senior123';

GRANT read_only TO junior_analyst;
GRANT read_only TO senior_analyst;

GRANT INSERT, UPDATE ON employees TO senior_analyst;

CREATE ROLE project_manager WITH LOGIN PASSWORD 'pm123';

ALTER VIEW dept_statistics OWNER TO project_manager;
ALTER TABLE projects OWNER TO project_manager;

SELECT tablename, tableowner
FROM pg_tables
WHERE schemaname = 'public';

CREATE ROLE temp_owner WITH LOGIN;
CREATE TABLE temp_table (id INT);
ALTER TABLE temp_table OWNER TO temp_owner;
REASSIGN OWNED BY temp_owner TO postgres;
DROP OWNED BY temp_owner;
DROP ROLE temp_owner;

CREATE VIEW hr_employee_view AS
SELECT * FROM employees WHERE dept_id = 102;

GRANT SELECT ON hr_employee_view TO hr_team;

CREATE VIEW finance_employee_view AS
SELECT emp_id, emp_name, salary FROM employees;

GRANT SELECT ON finance_employee_view TO finance_team;


-- PART 8
CREATE VIEW dept_dashboard AS
SELECT d.dept_name, d.location,
    COUNT(DISTINCT e.emp_id) AS employee_count,
    ROUND(COALESCE(AVG(e.salary), 0), 2) AS avg_salary,
    COUNT(DISTINCT p.project_id) AS active_projects,
    COALESCE(SUM(p.budget), 0) AS total_budget,
    ROUND(
        CASE
            WHEN COUNT(DISTINCT e.emp_id) = 0 THEN 0
            ELSE COALESCE(SUM(p.budget), 0) / COUNT(DISTINCT e.emp_id)
        END,
    2) AS budget_per_employee
FROM departments d
LEFT JOIN employees e ON d.dept_id = e.dept_id
LEFT JOIN projects p ON d.dept_id = p.dept_id
GROUP BY d.dept_name, d.location;

ALTER TABLE projects ADD COLUMN created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP;

CREATE VIEW high_budget_projects AS
SELECT p.project_name, p.budget, d.dept_name, p.created_date,
    CASE
        WHEN p.budget > 150000 THEN 'Critical Review Required'
        WHEN p.budget > 100000 THEN 'Management Approval Needed'
        ELSE 'Standard Process'
    END AS approval_status
FROM projects p
LEFT JOIN departments d ON p.dept_id = d.dept_id;

CREATE ROLE viewer_role;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO viewer_role;
GRANT SELECT ON ALL VIEWS IN SCHEMA public TO viewer_role;

CREATE ROLE entry_role;
GRANT viewer_role TO entry_role;
GRANT INSERT ON employees, projects TO entry_role;

CREATE ROLE analyst_role;
GRANT entry_role TO analyst_role;
GRANT UPDATE ON employees, projects TO analyst_role;

CREATE ROLE manager_role;
GRANT analyst_role TO manager_role;
GRANT DELETE ON employees, projects TO manager_role;

CREATE ROLE alice WITH LOGIN PASSWORD 'alice123';
CREATE ROLE bob WITH LOGIN PASSWORD 'bob123';
CREATE ROLE charlie WITH LOGIN PASSWORD 'charlie123';

GRANT viewer_role TO alice;
GRANT analyst_role TO bob;
GRANT manager_role TO charlie;
