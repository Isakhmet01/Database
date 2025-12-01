CREATE TABLE accounts (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    balance DECIMAL(10, 2) DEFAULT 0.00
);

CREATE TABLE products (
    id SERIAL PRIMARY KEY,
    shop VARCHAR(100) NOT NULL,
    product VARCHAR(100) NOT NULL,
    price DECIMAL(10, 2) NOT NULL
);

INSERT INTO accounts (name, balance) VALUES
('Alice', 1000.00),
('Bob', 500.00),
('Wally', 750.00);

INSERT INTO products (shop, product, price) VALUES
('Joe''s Shop', 'Coke', 2.50),
('Joe''s Shop', 'Pepsi', 3.00);

-- TASK 3:
-- 3.2
BEGIN;
UPDATE accounts SET balance = balance - 100.00
WHERE name = 'Alice';
UPDATE accounts SET balance = balance + 100.00
WHERE name = 'Bob';
COMMIT;

-- a) Alice = 900.00, Bob = 600.00
-- b) Because both UPDATE statements must succeed together. If only one succeeds, money is lost.
-- c) Alice’s balance would decrease but Bob’s balance would not increase, causing data inconsistency.

-- 3.3
BEGIN;
UPDATE accounts SET balance = balance - 500.00
WHERE name = 'Alice';

SELECT * FROM accounts WHERE name = 'Alice';

ROLLBACK;

SELECT * FROM accounts WHERE name = 'Alice';

-- a) After the UPDATE but before the ROLLBACK, Alice’s balance was 500.00.
-- b) After the ROLLBACK, Alice’s balance returned to 1000.00.
-- c) ROLLBACK is used when the wrong amount or wrong account was updated, or any incorrect operation occurs.

-- 3.4
BEGIN;
UPDATE accounts SET balance = balance - 100.00
WHERE name = 'Alice';

SAVEPOINT my_savepoint;

UPDATE accounts SET balance = balance + 100.00
WHERE name = 'Bob';

ROLLBACK TO my_savepoint;

UPDATE accounts SET balance = balance + 100.00
WHERE name = 'Wally';

COMMIT;

-- a) Alice = 900.00, Bob = 500.00, Wally = 850.00
-- b) Bob’s account was credited temporarily, but after ROLLBACK TO it was undone and not included in the final state.
-- c) SAVEPOINT allows undoing only part of a transaction without restarting the entire transaction.

-- 3.5
-- Terminal 1
BEGIN TRANSACTION ISOLATION LEVEL READ COMMITTED;
SELECT * FROM products WHERE shop = 'Joe''s Shop';
SELECT * FROM products WHERE shop = 'Joe''s Shop';
COMMIT;

-- Terminal 2
BEGIN;
DELETE FROM products WHERE shop = 'Joe''s Shop';
INSERT INTO products (shop, product, price)
VALUES ('Joe''s Shop', 'Fanta', 3.50);
COMMIT;

-- a) In Scenario A, Terminal 1 sees Coke + Pepsi first, and after Terminal 2 commits, it sees only Fanta.
-- b) In Scenario B, Terminal 1 sees only Coke + Pepsi both times; it does not see the new inserted product.
-- c) READ COMMITTED allows seeing newly committed changes, while SERIALIZABLE prevents that and behaves as if transactions run sequentially.

-- 3.6
-- Terminal 1
BEGIN TRANSACTION ISOLATION LEVEL REPEATABLE READ;
SELECT MAX(price), MIN(price) FROM products
WHERE shop = 'Joe''s Shop';

SELECT MAX(price), MIN(price) FROM products
WHERE shop = 'Joe''s Shop';
COMMIT;

-- Terminal 2
BEGIN;
INSERT INTO products (shop, product, price)
VALUES ('Joe''s Shop', 'Sprite', 4.00);
COMMIT;

-- a) Terminal 1 does NOT see the new product inserted by Terminal 2.
-- b) A phantom read is when new rows appear between two reads within the same transaction.
-- c) The SERIALIZABLE isolation level prevents phantom reads.

-- 3.7
-- Terminal 1
BEGIN TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SELECT * FROM products WHERE shop = 'Joe''s Shop';
SELECT * FROM products WHERE shop = 'Joe''s Shop';
SELECT * FROM products WHERE shop = 'Joe''s Shop';
COMMIT;

-- Terminal 2
BEGIN;
UPDATE products SET price = 99.99
WHERE product = 'Fanta';

ROLLBACK;

-- a) Yes, Terminal 1 saw the price 99.99 even though it was never committed. This is dangerous.
-- b) A dirty read is reading data that has not been committed and may later be rolled back.
-- c) READ UNCOMMITTED should be avoided because it can show invalid or temporary data, causing inconsistencies.


-- TASK 4:
-- 4.1
BEGIN;

DO $$
DECLARE
    bob_balance NUMERIC;
BEGIN
    SELECT balance INTO bob_balance FROM accounts WHERE name = 'Bob';

    IF bob_balance < 200 THEN
        RAISE EXCEPTION 'Insufficient funds';
    END IF;
END $$;

UPDATE accounts SET balance = balance - 200 WHERE name = 'Bob';
UPDATE accounts SET balance = balance + 200 WHERE name = 'Wally';

COMMIT;

-- 4.2
BEGIN;

INSERT INTO products (shop, product, price)
VALUES ('TestShop', 'TestItem', 10.00);

SAVEPOINT sp1;

UPDATE products SET price = 20.00
WHERE product = 'TestItem';

SAVEPOINT sp2;

DELETE FROM products WHERE product = 'TestItem';

ROLLBACK TO sp1;

COMMIT;

SELECT * FROM products WHERE product = 'TestItem';

-- 4.3
-- terminal-1
BEGIN TRANSACTION ISOLATION LEVEL READ COMMITTED;

UPDATE accounts
SET balance = balance - 300
WHERE name = 'Alice';

SELECT * FROM accounts WHERE name = 'Alice';

COMMIT;

-- terminal-2
BEGIN TRANSACTION ISOLATION LEVEL READ COMMITTED;

UPDATE accounts
SET balance = balance - 300
WHERE name = 'Alice';

SELECT * FROM accounts WHERE name = 'Alice';

COMMIT;

-- serializable version
BEGIN TRANSACTION ISOLATION LEVEL SERIALIZABLE;
UPDATE accounts SET balance = balance - 300 WHERE name = 'Alice';
SELECT * FROM accounts WHERE name = 'Alice';
COMMIT;

BEGIN TRANSACTION ISOLATION LEVEL SERIALIZABLE;
UPDATE accounts SET balance = balance - 300 WHERE name = 'Alice';
SELECT * FROM accounts WHERE name = 'Alice';
COMMIT;

-- 4.4
SELECT MAX(price) FROM sells WHERE shop = 'Sally';
SELECT MIN(price) FROM sells WHERE shop = 'Sally';

UPDATE sells SET price = price + 10 WHERE shop = 'Joe';

SELECT MAX(price) FROM sells WHERE shop = 'Sally';
SELECT MIN(price) FROM sells WHERE shop = 'Sally';

BEGIN TRANSACTION ISOLATION LEVEL REPEATABLE READ;
SELECT MAX(price) FROM sells WHERE shop = 'Sally';
SELECT MIN(price) FROM sells WHERE shop = 'Sally';

BEGIN;
UPDATE sells SET price = price + 10 WHERE shop = 'Joe';
COMMIT;

SELECT MAX(price) FROM sells WHERE shop = 'Sally';
SELECT MIN(price) FROM sells WHERE shop = 'Sally';
COMMIT;

-- TASK 5:
-- 1. ACID:
-- Atomicity: A money transfer either completes fully or not at all.
-- Consistency: Database rules (constraints) remain valid after the transaction.
-- Isolation: Concurrent transactions do not affect each other’s intermediate states.
-- Durability: After COMMIT, changes persist even if the system crashes.

-- 2. COMMIT makes changes permanent; ROLLBACK undoes all changes in the transaction.

-- 3. SAVEPOINT is used when you want to undo only part of a transaction instead of rolling back the entire transaction.

-- 4. READ UNCOMMITTED: allows dirty reads.
--    READ COMMITTED: prevents dirty reads but allows non-repeatable reads and phantoms.
--    REPEATABLE READ: prevents dirty and non-repeatable reads but allows phantoms.
--    SERIALIZABLE: prevents all anomalies and ensures full isolation.

-- 5. A dirty read is reading uncommitted data from another transaction.
--    Allowed only in READ UNCOMMITTED.

-- 6. A non-repeatable read occurs when a row changes between two reads.
--    Example: Transaction A reads a balance; Transaction B updates it; A reads again and sees a different value.

-- 7. A phantom read occurs when new rows appear between two reads.
--    Prevented only by SERIALIZABLE.

-- 8. READ COMMITTED is faster and more scalable, making it better for high-traffic applications than SERIALIZABLE.

-- 9. Transactions ensure consistency by isolating operations so concurrent actions do not interfere or corrupt shared data.

-- 10. Uncommitted changes are lost if the database system crashes; only committed data is durable.

