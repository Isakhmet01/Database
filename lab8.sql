-- PART 1:
CREATE TABLE departments (
    dept_id INT PRIMARY KEY,
    dept_name VARCHAR(50),
    location VARCHAR(50)
);

CREATE TABLE employees (
    emp_id INT PRIMARY KEY,
    emp_name VARCHAR(100),
    dept_id INT,
    salary DECIMAL(10,2),
    FOREIGN KEY (dept_id) REFERENCES departments(dept_id)
);

CREATE TABLE projects (
    proj_id INT PRIMARY KEY,
    proj_name VARCHAR(100),
    budget DECIMAL(12,2),
    dept_id INT,
    FOREIGN KEY (dept_id) REFERENCES departments(dept_id)
);

INSERT INTO departments VALUES
(101, 'IT', 'Building A'),
(102, 'HR', 'Building B'),
(103, 'Operations', 'Building C');

INSERT INTO employees VALUES
(1, 'John Smith', 101, 50000),
(2, 'Jane Doe', 101, 55000),
(3, 'Mike Johnson', 102, 48000),
(4, 'Sarah Williams', 102, 52000),
(5, 'Tom Brown', 103, 60000);

INSERT INTO projects VALUES
(201, 'Website Redesign', 75000, 101),
(202, 'Database Migration', 120000, 101),
(203, 'HR System Upgrade', 50000, 102);


--PART 2:
CREATE INDEX emp_salary_idx ON employees(salary);

SELECT indexname, indexdef
FROM pg_indexes
WHERE tablename = 'employees';

-- Question: How many indexes exist on the employees table?
-- Answer: employees table has 2 indexes (PRIMARY KEY + emp_salary_idx).

CREATE INDEX emp_dept_idx ON employees(dept_id);
SELECT * FROM employees WHERE dept_id = 101;

-- Question: Why is it beneficial to index foreign key columns?
-- Answer: Because it speeds up JOIN operations and WHERE filtering on foreign keys.

SELECT
    tablename,
    indexname,
    indexdef
FROM pg_indexes
WHERE schemaname = 'public'
ORDER BY tablename, indexname;

-- Question: Which indexes were created automatically?
-- Answer: PRIMARY KEY indexes were created automatically.


--PART 3:
CREATE INDEX emp_dept_salary_idx ON employees(dept_id, salary);

SELECT emp_name, salary
FROM employees
WHERE dept_id = 101 AND salary > 52000;

-- Question: Would this index be useful for a query that only filters by salary?
-- Answer: No, because multicolumn indexes work left-to-right, and salary is the second column.

CREATE INDEX emp_salary_dept_idx ON employees(salary, dept_id);

SELECT * FROM employees WHERE dept_id = 102 AND salary > 50000;
SELECT * FROM employees WHERE salary > 50000 AND dept_id = 102;

-- Question: Does the order of columns in a multicolumn index matter?
-- Answer: Yes, the index is only efficient when filtering starts from the first column.


--PART 4:
ALTER TABLE employees ADD COLUMN email VARCHAR(100);

UPDATE employees SET email = 'john.smith@company.com' WHERE emp_id = 1;
UPDATE employees SET email = 'jane.doe@company.com' WHERE emp_id = 2;
UPDATE employees SET email = 'mike.johnson@company.com' WHERE emp_id = 3;
UPDATE employees SET email = 'sarah.williams@company.com' WHERE emp_id = 4;
UPDATE employees SET email = 'tom.brown@company.com' WHERE emp_id = 5;

CREATE UNIQUE INDEX emp_email_unique_idx ON employees(email);

INSERT INTO employees (emp_id, emp_name, dept_id, salary, email)
VALUES (6, 'New Employee', 101, 55000, 'john.smith@company.com');

-- Question: What error message did you receive?
-- Answer: Unique violation error because email must be unique.

ALTER TABLE employees ADD COLUMN phone VARCHAR(20) UNIQUE;

SELECT indexname, indexdef
FROM pg_indexes
WHERE tablename = 'employees' AND indexname LIKE '%phone%';

-- Question: Did PostgreSQL automatically create an index? What type of index?
-- Answer: Yes, PostgreSQL created an automatic UNIQUE B-tree index.


--PART 5:
CREATE INDEX emp_salary_desc_idx ON employees(salary DESC);

SELECT emp_name, salary
FROM employees
ORDER BY salary DESC;

-- Question: How does this index help with ORDER BY queries?
-- Answer: It allows PostgreSQL to avoid sorting and use the pre-ordered index.

CREATE INDEX proj_budget_nulls_first_idx ON projects(budget NULLS FIRST);

SELECT proj_name, budget
FROM projects
ORDER BY budget NULLS FIRST;


--PART 6:
CREATE INDEX emp_name_lower_idx ON employees(LOWER(emp_name));

SELECT * FROM employees WHERE LOWER(emp_name) = 'john smith';

-- Question: Without this index, how would PostgreSQL search for names case-insensitively?
-- Answer: It would perform a full table scan because LOWER() prevents use of a normal index.

ALTER TABLE employees ADD COLUMN hire_date DATE;

UPDATE employees SET hire_date = '2020-01-15' WHERE emp_id = 1;
UPDATE employees SET hire_date = '2019-06-20' WHERE emp_id = 2;
UPDATE employees SET hire_date = '2021-03-10' WHERE emp_id = 3;
UPDATE employees SET hire_date = '2020-11-05' WHERE emp_id = 4;
UPDATE employees SET hire_date = '2018-08-25' WHERE emp_id = 5;

CREATE INDEX emp_hire_year_idx ON employees(EXTRACT(YEAR FROM hire_date));

SELECT emp_name, hire_date
FROM employees
WHERE EXTRACT(YEAR FROM hire_date) = 2020;


--PART 7:
ALTER INDEX emp_salary_idx RENAME TO employees_salary_index;

SELECT indexname FROM pg_indexes WHERE tablename = 'employees';

DROP INDEX emp_salary_dept_idx;

-- Question: Why might you want to drop an index?
-- Answer: To reduce storage use and improve write performance if the index is unused.

REINDEX INDEX employees_salary_index;


--PART 8:
 SELECT e.emp_name, e.salary, d.dept_name
 FROM employees e
 JOIN departments d ON e.dept_id = d.dept_id
 WHERE e.salary > 50000
 ORDER BY e.salary DESC;

CREATE INDEX emp_salary_filter_idx ON employees(salary) WHERE salary > 50000;

-- JOIN index already created earlier (emp_dept_idx)
-- ORDER BY index already exists (emp_salary_desc_idx)

CREATE INDEX proj_high_budget_idx ON projects(budget)
WHERE budget > 80000;

SELECT proj_name, budget
FROM projects
WHERE budget > 80000;

-- Question: What's the advantage of a partial index compared to a regular index?
-- Answer: It is smaller and faster because it indexes only relevant rows.

EXPLAIN SELECT * FROM employees WHERE salary > 52000;

-- Question: Does the output show an Index Scan or Seq Scan?
-- Answer: Index Scan indicates index usage; Seq Scan means the index was not used.


--PART 9:
CREATE INDEX dept_name_hash_idx ON departments USING HASH (dept_name);

SELECT * FROM departments WHERE dept_name = 'IT';

-- Question: When should you use a HASH index instead of a B-tree index?
-- Answer: When you need equality (=) comparison only.

CREATE INDEX proj_name_btree_idx ON projects(proj_name);

CREATE INDEX proj_name_hash_idx ON projects USING HASH (proj_name);

SELECT * FROM projects WHERE proj_name = 'Website Redesign';

SELECT * FROM projects WHERE proj_name > 'Database';


--PART 10:
SELECT
    schemaname,
    tablename,
    indexname,
    pg_size_pretty(pg_relation_size(indexname::regclass)) AS index_size
FROM pg_indexes
WHERE schemaname = 'public'
ORDER BY tablename, indexname;

-- Question: Which index is the largest? Why?
-- Answer: The largest index is the one on the biggest or most frequently indexed column.

DROP INDEX IF EXISTS proj_name_hash_idx;

CREATE VIEW index_documentation AS
SELECT
    tablename,
    indexname,
    indexdef,
    'Improves salary-based queries' AS purpose
FROM pg_indexes
WHERE schemaname = 'public'
  AND indexname LIKE '%salary%';

SELECT * FROM index_documentation;

--SUMMARY QUESTIONS:
-- Question 1: What is the default index type in PostgreSQL?
-- Answer: B-tree
-- Question 2: Name three scenarios where you should create an index:
-- Answer: Frequent WHERE filtering, JOIN on foreign keys, ORDER BY sorting.
-- Question 3: Name two scenarios where you should NOT create an index:
-- Answer: Small tables, columns that are frequently updated.
-- Question 4: What happens to indexes when you INSERT, UPDATE, or DELETE data?
-- Answer: Indexes are updated too, which slows down write operations.
-- Question 5: How can you check if a query is using an index?
-- Answer: Use EXPLAIN to see Index Scan or Seq Scan.


