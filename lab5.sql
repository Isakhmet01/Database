-- Part 1
CREATE TABLE employees (
    employee_id INTEGER,
    first_name TEXT,
    last_name TEXT,
    age INTEGER CHECK (age BETWEEN 18 AND 65),
    salary NUMERIC CHECK (salary > 0)
);

INSERT INTO employees VALUES (1, 'John', 'Smith', 30, 5000);
INSERT INTO employees VALUES (2, 'Anna', 'Lee', 45, 7200);
INSERT INTO employees VALUES (3, 'Tom', 'Ray', 17, 3000);  -- age too low
INSERT INTO employees VALUES (5, 'Leo', 'King', 35, -100); -- invalid salary

CREATE TABLE products_catalog (
    product_id INTEGER,
    product_name TEXT,
    regular_price NUMERIC,
    discount_price NUMERIC,
    CONSTRAINT valid_discount CHECK (
        regular_price > 0
        AND discount_price > 0
        AND discount_price < regular_price
    )
);

INSERT INTO products_catalog VALUES (1, 'Laptop', 1200, 999);
INSERT INTO products_catalog VALUES (2, 'Phone', 800, 650);
INSERT INTO products_catalog VALUES (3, 'TV', 0, 200);         -- invalid regular_price
INSERT INTO products_catalog VALUES (4, 'Camera', 1000, 1500); -- discount higher than regular

CREATE TABLE bookings (
    booking_id INTEGER,
    check_in_date DATE,
    check_out_date DATE,
    num_guests INTEGER CHECK (num_guests BETWEEN 1 AND 10),
    CHECK (check_out_date > check_in_date)
);

INSERT INTO bookings VALUES (1, '2025-10-10', '2025-10-15', 2);
INSERT INTO bookings VALUES (2, '2025-11-01', '2025-11-05', 4);
INSERT INTO bookings VALUES (3, '2025-12-01', '2025-11-30', 3);  -- checkout before checkin
INSERT INTO bookings VALUES (4, '2025-10-20', '2025-10-25', 15); -- too many guests


-- Part 2
CREATE TABLE customers (
    customer_id INTEGER NOT NULL,
    email TEXT NOT NULL,
    phone TEXT,
    registration_date DATE NOT NULL
);

INSERT INTO customers VALUES (1, 'john@gmail.com', '87001234567', '2025-01-15');
INSERT INTO customers VALUES (2, 'anna@mail.com', NULL, '2025-02-20');
INSERT INTO customers VALUES (3, NULL, '87001112233', '2025-03-01');       --violates NOT NULL on "email"
INSERT INTO customers VALUES (4, 'mike@gmail.com', '87009998877', NULL);   --violates NOT NULL on "registration_date"

CREATE TABLE inventory (
    item_id INTEGER NOT NULL,
    item_name TEXT NOT NULL,
    quantity INTEGER NOT NULL CHECK (quantity >= 0),
    unit_price NUMERIC NOT NULL CHECK (unit_price > 0),
    last_updated TIMESTAMP NOT NULL
);

INSERT INTO inventory VALUES (1, 'Laptop', 10, 1200, '2025-10-10 10:00:00');
INSERT INTO inventory VALUES (2, 'Phone', 50, 800, '2025-10-11 09:30:00');
INSERT INTO inventory VALUES (3, 'Tablet', NULL, 500, '2025-10-12 14:00:00');   --violates NOT NULL on "quantity"
INSERT INTO inventory VALUES (4, 'Headphones', 5, -100, '2025-10-12 14:00:00'); --violates CHECK (unit_price > 0)


-- Part 3
CREATE TABLE users (
    user_id INTEGER,
    username TEXT UNIQUE,
    email TEXT UNIQUE,
    created_at TIMESTAMP
);

INSERT INTO users VALUES (1, 'john_smith', 'john@gmail.com', '2025-10-01 09:00:00');
INSERT INTO users VALUES (2, 'anna_lee', 'anna@mail.com', '2025-10-02 10:30:00');
INSERT INTO users VALUES (3, 'john_smith', 'newjohn@mail.com', '2025-10-03 11:00:00');  --violates UNIQUE constraint on "username"
INSERT INTO users VALUES (4, 'kate_miller', 'john@gmail.com', '2025-10-04 12:00:00');   --violates UNIQUE constraint on "email"

CREATE TABLE course_enrollments (
    enrollment_id INTEGER,
    student_id INTEGER,
    course_code TEXT,
    semester TEXT,
    UNIQUE (student_id, course_code, semester)
);

INSERT INTO course_enrollments VALUES (1, 1001, 'CS101', 'Fall 2025');
INSERT INTO course_enrollments VALUES (2, 1001, 'CS102', 'Fall 2025');
INSERT INTO course_enrollments VALUES (3, 1002, 'CS101', 'Fall 2025');
INSERT INTO course_enrollments VALUES (4, 1001, 'CS101', 'Fall 2025');  --violates multi-column UNIQUE constraint (student_id, course_code, semester)

ALTER TABLE users
ADD CONSTRAINT unique_username UNIQUE (username);

ALTER TABLE users
ADD CONSTRAINT unique_email UNIQUE (email);

INSERT INTO users VALUES (5, 'anna_lee', 'new_anna@mail.com', '2025-10-05 15:00:00');  --violates unique_username
INSERT INTO users VALUES (6, 'new_user', 'john@gmail.com', '2025-10-06 15:00:00');     --violates unique_email


-- Part 4
CREATE TABLE departments (
    dept_id INTEGER PRIMARY KEY,
    dept_name TEXT NOT NULL,
    location TEXT
);

INSERT INTO departments VALUES (1, 'IT', 'Almaty');
INSERT INTO departments VALUES (2, 'Finance', 'Astana');
INSERT INTO departments VALUES (2, 'Marketing', 'Atyrau');   --violates PRIMARY KEY (duplicate dept_id)
INSERT INTO departments VALUES (NULL, 'Support', 'Aktobe');  --violates PRIMARY KEY (dept_id cannot be NULL)

CREATE TABLE student_courses (
    student_id INTEGER,
    course_id INTEGER,
    enrollment_date DATE,
    grade TEXT,
    PRIMARY KEY (student_id, course_id)
);

INSERT INTO student_courses VALUES (1001, 501, '2025-09-01', 'A');
INSERT INTO student_courses VALUES (1001, 502, '2025-09-01', 'B');
INSERT INTO student_courses VALUES (1001, 501, '2025-09-01', 'A');  --violates composite PRIMARY KEY (student_id, course_id)
INSERT INTO student_courses VALUES (NULL, 503, '2025-09-02', 'B');  --violates PRIMARY KEY (student_id cannot be NULL)

-- Task 4.3: Comparison Exercise
-- 1. Difference between UNIQUE and PRIMARY KEY:
--    PRIMARY KEY ensures values are unique and also disallows NULL values,
--    while UNIQUE enforces uniqueness but allows NULL values.
--
-- 2. Difference between Single-column and Composite PRIMARY KEY:
--    A single-column PRIMARY KEY is used for individual identifiers (e.g., dept_id),
--    whereas a composite PRIMARY KEY combines multiple columns
--    to create a unique pair (e.g., student_id + course_id).
--
-- 3. Number of PRIMARY KEYs and UNIQUE constraints:
--    A table can have only one PRIMARY KEY,
--    but it can contain multiple UNIQUE constraints.


-- Part 5
CREATE TABLE departments (
    dept_id INTEGER PRIMARY KEY,
    dept_name TEXT NOT NULL,
    location TEXT
);

CREATE TABLE employees_dept (
    emp_id INTEGER PRIMARY KEY,
    emp_name TEXT NOT NULL,
    dept_id INTEGER REFERENCES departments(dept_id),
    hire_date DATE
);

INSERT INTO departments VALUES (1, 'IT', 'Almaty');
INSERT INTO departments VALUES (2, 'Finance', 'Astana');
INSERT INTO departments VALUES (3, 'HR', 'Shymkent');

INSERT INTO employees_dept VALUES (101, 'John Smith', 1, '2025-01-10');
INSERT INTO employees_dept VALUES (102, 'Anna Lee', 2, '2025-02-15');
INSERT INTO employees_dept VALUES (103, 'Kate Miller', 5, '2025-03-01');  --violates FOREIGN KEY (dept_id 5 does not exist)

CREATE TABLE authors (
    author_id INTEGER PRIMARY KEY,
    author_name TEXT NOT NULL,
    country TEXT
);

CREATE TABLE publishers (
    publisher_id INTEGER PRIMARY KEY,
    publisher_name TEXT NOT NULL,
    city TEXT
);

CREATE TABLE books (
    book_id INTEGER PRIMARY KEY,
    title TEXT NOT NULL,
    author_id INTEGER REFERENCES authors(author_id),
    publisher_id INTEGER REFERENCES publishers(publisher_id),
    publication_year INTEGER,
    isbn TEXT UNIQUE
);

INSERT INTO authors VALUES (1, 'J.K. Rowling', 'UK');
INSERT INTO authors VALUES (2, 'George Orwell', 'UK');

INSERT INTO publishers VALUES (1, 'Penguin Books', 'London');
INSERT INTO publishers VALUES (2, 'Bloomsbury', 'Oxford');

INSERT INTO books VALUES (1, '1984', 2, 1, 1949, '9780451524935');
INSERT INTO books VALUES (2, 'Harry Potter', 1, 2, 1997, '9780747532743');
INSERT INTO books VALUES (3, 'Unknown Book', 5, 1, 2020, '9780000000001');  -- ERROR: violates FOREIGN KEY (author_id 5 does not exist)

CREATE TABLE categories (
    category_id INTEGER PRIMARY KEY,
    category_name TEXT NOT NULL
);

CREATE TABLE products_fk (
    product_id INTEGER PRIMARY KEY,
    product_name TEXT NOT NULL,
    category_id INTEGER REFERENCES categories(category_id) ON DELETE RESTRICT
);

CREATE TABLE orders (
    order_id INTEGER PRIMARY KEY,
    order_date DATE NOT NULL
);

CREATE TABLE order_items (
    item_id INTEGER PRIMARY KEY,
    order_id INTEGER REFERENCES orders(order_id) ON DELETE CASCADE,
    product_id INTEGER REFERENCES products_fk(product_id),
    quantity INTEGER CHECK (quantity > 0)
);

INSERT INTO categories VALUES (1, 'Electronics');
INSERT INTO categories VALUES (2, 'Clothes');

INSERT INTO products_fk VALUES (1, 'Laptop', 1);
INSERT INTO products_fk VALUES (2, 'T-Shirt', 2);

INSERT INTO orders VALUES (1001, '2025-10-10');
INSERT INTO orders VALUES (1002, '2025-10-11');

INSERT INTO order_items VALUES (1, 1001, 1, 2);
INSERT INTO order_items VALUES (2, 1001, 2, 1);
INSERT INTO order_items VALUES (3, 1003, 1, 3);  --violates FOREIGN KEY (order_id 1003 does not exist)

DELETE FROM categories WHERE category_id = 1;   --RESTRICT prevents deleting category with linked products
DELETE FROM orders WHERE order_id = 1001;       --CASCADE: related order_items will be automatically deleted


-- Part 6
CREATE TABLE customers (
    customer_id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    email TEXT UNIQUE NOT NULL,
    phone TEXT,
    registration_date DATE NOT NULL
);

CREATE TABLE products (
    product_id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    description TEXT,
    price NUMERIC CHECK (price >= 0) NOT NULL,
    stock_quantity INTEGER CHECK (stock_quantity >= 0) NOT NULL
);

CREATE TABLE orders (
    order_id SERIAL PRIMARY KEY,
    customer_id INTEGER REFERENCES customers(customer_id) ON DELETE CASCADE,
    order_date DATE NOT NULL,
    total_amount NUMERIC CHECK (total_amount >= 0) NOT NULL,
    status TEXT CHECK (status IN ('pending', 'processing', 'shipped', 'delivered', 'cancelled')) NOT NULL
);

CREATE TABLE order_details (
    order_detail_id SERIAL PRIMARY KEY,
    order_id INTEGER REFERENCES orders(order_id) ON DELETE CASCADE,
    product_id INTEGER REFERENCES products(product_id),
    quantity INTEGER CHECK (quantity > 0) NOT NULL,
    unit_price NUMERIC CHECK (unit_price >= 0) NOT NULL
);

INSERT INTO customers (name, email, phone, registration_date) VALUES
('John Smith', 'john@gmail.com', '87001234567', '2025-01-15'),
('Anna Lee', 'anna@mail.com', '87009998877', '2025-02-20'),
('Kate Brown', 'kate@yahoo.com', NULL, '2025-03-05'),
('Mike Green', 'mike@gmail.com', '87005556677', '2025-04-10'),
('Lisa White', 'lisa@mail.com', NULL, '2025-05-01');

INSERT INTO products (name, description, price, stock_quantity) VALUES
('Laptop', 'High-performance laptop', 1200, 10),
('Phone', 'Latest smartphone', 800, 20),
('Headphones', 'Wireless headphones', 150, 30),
('Monitor', '24-inch LED display', 200, 15),
('Mouse', 'Wireless mouse', 50, 25);

INSERT INTO orders (customer_id, order_date, total_amount, status) VALUES
(1, '2025-06-01', 2000, 'pending'),
(2, '2025-06-02', 800, 'processing'),
(3, '2025-06-03', 350, 'shipped'),
(4, '2025-06-04', 1250, 'delivered'),
(5, '2025-06-05', 500, 'cancelled');

INSERT INTO order_details (order_id, product_id, quantity, unit_price) VALUES
(1, 1, 1, 1200),
(1, 2, 1, 800),
(2, 3, 2, 150),
(3, 4, 1, 200),
(4, 5, 2, 50),
(5, 2, 1, 800);

-- Testing constraint violations
INSERT INTO customers (name, email, phone, registration_date)
VALUES ('Duplicate Email', 'john@gmail.com', '87009998877', '2025-06-10');  --violates UNIQUE constraint on "email"

INSERT INTO products (name, description, price, stock_quantity)
VALUES ('Invalid Product', 'Negative price', -500, 10);  --violates CHECK (price >= 0)

INSERT INTO orders (customer_id, order_date, total_amount, status)
VALUES (10, '2025-06-15', 900, 'pending');  --violates FOREIGN KEY (customer_id 10 does not exist)

INSERT INTO orders (customer_id, order_date, total_amount, status)
VALUES (2, '2025-06-15', 1000, 'unknown');  --violates CHECK (status IN ...)

INSERT INTO order_details (order_id, product_id, quantity, unit_price)
VALUES (1, 2, 0, 800);  --violates CHECK (quantity > 0)

DELETE FROM customers WHERE customer_id = 1;  --CASCADE: deletes related orders and order_details automatically
