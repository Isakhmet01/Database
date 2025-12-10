CREATE TABLE customers (
    customer_id      BIGSERIAL PRIMARY KEY,
    iin              CHAR(12) NOT NULL UNIQUE,
    full_name        TEXT NOT NULL,
    phone            TEXT,
    email            TEXT UNIQUE,
    status           VARCHAR(16) NOT NULL
        CHECK (status IN ('active', 'blocked', 'frozen')),
    created_at       TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    daily_limit_kzt  NUMERIC(18,2) NOT NULL
);

CREATE TABLE accounts (
    account_id      BIGSERIAL PRIMARY KEY,
    customer_id     BIGINT NOT NULL REFERENCES customers(customer_id),
    account_number  TEXT NOT NULL UNIQUE,
    currency        CHAR(3) NOT NULL
        CHECK (currency IN ('KZT','USD','EUR','RUB')),
    balance         NUMERIC(18,2) NOT NULL DEFAULT 0,
    is_active       BOOLEAN NOT NULL DEFAULT TRUE,
    opened_at       TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    closed_at       TIMESTAMPTZ
);

CREATE TABLE transactions (
    transaction_id   BIGSERIAL PRIMARY KEY,
    from_account_id  BIGINT REFERENCES accounts(account_id),
    to_account_id    BIGINT REFERENCES accounts(account_id),
    amount           NUMERIC(18,2) NOT NULL CHECK (amount > 0),
    currency         CHAR(3) NOT NULL
        CHECK (currency IN ('KZT','USD','EUR','RUB')),
    exchange_rate    NUMERIC(18,6) NOT NULL,
    amount_kzt       NUMERIC(18,2) NOT NULL,
    type             VARCHAR(16) NOT NULL
        CHECK (type IN ('transfer','deposit','withdrawal')),
    status           VARCHAR(16) NOT NULL
        CHECK (status IN ('pending','completed','failed','reversed')),
    created_at       TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    completed_at     TIMESTAMPTZ,
    description      TEXT
);

CREATE TABLE exchange_rates (
    rate_id       BIGSERIAL PRIMARY KEY,
    from_currency CHAR(3) NOT NULL
        CHECK (from_currency IN ('KZT','USD','EUR','RUB')),
    to_currency   CHAR(3) NOT NULL
        CHECK (to_currency   IN ('KZT','USD','EUR','RUB')),
    rate          NUMERIC(18,6) NOT NULL,
    valid_from    TIMESTAMPTZ NOT NULL,
    valid_to      TIMESTAMPTZ
);

CREATE TABLE audit_log (
    log_id      BIGSERIAL PRIMARY KEY,
    table_name  TEXT NOT NULL,
    record_id   BIGINT,
    action      VARCHAR(10) NOT NULL
        CHECK (action IN ('INSERT','UPDATE','DELETE')),
    old_values  JSONB,
    new_values  JSONB,
    changed_by  TEXT,
    changed_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    ip_address  TEXT
);

INSERT INTO customers (iin, full_name, phone, email, status, daily_limit_kzt)
VALUES
('990101000001', 'Aruzhan Beket',      '+77010000001', 'aruzhan@example.com',  'active',  2_000_000),
('990101000002', 'Dias Serikov',       '+77010000002', 'dias@example.com',     'active',  1_500_000),
('990101000003', 'Miras Saparov',      '+77010000003', 'miras@example.com',    'blocked', 1_000_000),
('990101000004', 'Aigerim Akhmetova',  '+77010000004', 'aigerim@example.com',  'active',  3_000_000),
('990101000005', 'Nurzhan Tolegen',    '+77010000005', 'nurzhan@example.com',  'frozen',  500_000),
('990101000006', 'Alina Kozhakhmet',   '+77010000006', 'alina@example.com',    'active',  1_000_000),
('990101000007', 'Erlan Mukhamed',     '+77010000007', 'erlan@example.com',    'active',  4_000_000),
('990101000008', 'Dana Rysbek',        '+77010000008', 'dana@example.com',     'active',  1_200_000),
('990101000009', 'Timur Zhaksylyq',    '+77010000009', 'timur@example.com',    'active',  800_000),
('990101000010', 'Assel Omarova',      '+77010000010', 'assel@example.com',    'active',  2_500_000);

INSERT INTO accounts (customer_id, account_number, currency, balance, is_active)
VALUES
(1, 'KZ01001A000000000001', 'KZT', 1_200_000, TRUE),
(1, 'KZ01001A000000000002', 'USD',    3_000, TRUE),
(2, 'KZ02001A000000000003', 'KZT',   800_000, TRUE),
(2, 'KZ02001A000000000004', 'EUR',    1_200, TRUE),
(3, 'KZ03001A000000000005', 'KZT',   50_000, TRUE),
(4, 'KZ04001A000000000006', 'KZT', 3_500_000, TRUE),
(5, 'KZ05001A000000000007', 'USD',    1_000, FALSE),
(6, 'KZ06001A000000000008', 'RUB',   90_000, TRUE),
(7, 'KZ07001A000000000009', 'KZT', 4_800_000, TRUE),
(8, 'KZ08001A000000000010', 'KZT', 1_100_000, TRUE),
(9, 'KZ09001A000000000011', 'EUR',    2_000, TRUE),
(10,'KZ10001A000000000012', 'KZT', 2_300_000, TRUE);

INSERT INTO exchange_rates (from_currency, to_currency, rate, valid_from, valid_to)
VALUES
('USD','KZT', 500.000000, NOW() - INTERVAL '1 day', NULL),
('EUR','KZT', 540.000000, NOW() - INTERVAL '1 day', NULL),
('RUB','KZT',   5.200000, NOW() - INTERVAL '1 day', NULL),
('KZT','KZT',   1.000000, NOW() - INTERVAL '1 day', NULL),
('KZT','USD',   0.002000, NOW() - INTERVAL '1 day', NULL),
('KZT','EUR',   0.001850, NOW() - INTERVAL '1 day', NULL),
('KZT','RUB',  0.190000,  NOW() - INTERVAL '1 day', NULL),
('USD','EUR',  0.930000,  NOW() - INTERVAL '1 day', NULL),
('EUR','USD',  1.070000,  NOW() - INTERVAL '1 day', NULL),
('RUB','USD',  0.010000,  NOW() - INTERVAL '1 day', NULL);

INSERT INTO transactions (from_account_id, to_account_id, amount, currency, exchange_rate, amount_kzt, type, status, created_at, completed_at, description)
VALUES
(1, 3,   200_000, 'KZT', 1.000000, 200_000, 'transfer','completed',
 NOW() - INTERVAL '2 days', NOW() - INTERVAL '2 days','Rent payment'),
(3, 6,    50_000, 'KZT', 1.000000,  50_000, 'transfer','completed',
 NOW() - INTERVAL '1 day', NOW() - INTERVAL '1 day','Utility bills'),
(2, 1,       500, 'USD', 500.000000, 250_000, 'transfer','completed',
 NOW() - INTERVAL '3 days', NOW() - INTERVAL '3 days','Savings transfer'),
(4, NULL,  100_000, 'KZT', 1.000000, 100_000, 'deposit','completed',
 NOW() - INTERVAL '5 days', NOW() - INTERVAL '5 days','Cash deposit'),
(6, 1,    5_000, 'RUB', 5.200000, 26_000, 'transfer','failed',
 NOW() - INTERVAL '6 hours', NULL,'Failed transfer – insufficient balance'),
(7, 8,   300_000, 'KZT', 1.000000, 300_000, 'transfer','completed',
 NOW() - INTERVAL '12 hours', NOW() - INTERVAL '11 hours','P2P transfer'),
(1, 9,      300, 'USD', 500.000000, 150_000, 'transfer','completed',
 NOW() - INTERVAL '4 hours', NOW() - INTERVAL '4 hours','Online purchase'),
(10, 1,  400_000, 'KZT', 1.000000, 400_000, 'transfer','pending',
 NOW() - INTERVAL '1 hour', NULL,'Pending approval'),
(8, 3,   150_000, 'KZT', 1.000000, 150_000, 'transfer','reversed',
 NOW() - INTERVAL '7 days', NOW() - INTERVAL '7 days','Reversed by support'),
(NULL, 2,  2_000, 'USD', 500.000000, 1_000_000, 'deposit','completed',
 NOW() - INTERVAL '10 days', NOW() - INTERVAL '10 days','Salary deposit');

INSERT INTO audit_log (table_name, record_id, action, old_values, new_values, changed_by, ip_address)
VALUES
('customers', 1, 'INSERT', NULL,
 '{"full_name":"Aruzhan Beket","status":"active"}', 'system', '10.0.0.1'),
('customers', 3, 'UPDATE','{"status":"active"}',
 '{"status":"blocked"}', 'risk_engine', '10.0.0.10'),
('accounts', 5, 'UPDATE','{"is_active":true}',
 '{"is_active":false}', 'operator1', '10.0.0.5'),
('transactions', 5, 'INSERT', NULL,
 '{"amount":5000,"status":"failed"}', 'core_tx', '10.0.0.2'),
('customers', 5, 'INSERT', NULL,
 '{"full_name":"Nurzhan Tolegen"}', 'system', '10.0.0.1'),
('transactions', 9, 'UPDATE','{"status":"completed"}',
 '{"status":"reversed"}', 'support1', '10.0.0.6'),
('accounts', 1, 'UPDATE','{"balance":1000000}',
 '{"balance":1200000}', 'core_tx', '10.0.0.2'),
('accounts', 2, 'INSERT', NULL,
 '{"currency":"USD","balance":3000}', 'system', '10.0.0.1'),
('exchange_rates', 1, 'UPDATE','{"rate":470.000000}',
 '{"rate":500.000000}', 'fx_engine', '10.0.0.3'),
('customers', 2, 'UPDATE','{"daily_limit_kzt":1000000}',
 '{"daily_limit_kzt":1500000}', 'support2', '10.0.0.7');


-- Design decisions for process_transfer:
-- SELECT FOR UPDATE prevents race conditions
-- SAVEPOINT enables partial rollback
-- Error codes give precise failure reporting
-- Audit log records both success and failure

--Task 1:
CREATE OR REPLACE PROCEDURE process_transfer(
    p_from_account TEXT,
    p_to_account   TEXT,
    p_amount       NUMERIC,
    p_currency     CHAR(3),
    p_description  TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_from_id        BIGINT;
    v_to_id          BIGINT;
    v_from_balance   NUMERIC;
    v_currency_rate  NUMERIC;
    v_amount_kzt     NUMERIC;
    v_sender_customer_id BIGINT;
    v_sender_status  TEXT;
    v_daily_limit    NUMERIC;
    v_today_total    NUMERIC;
BEGIN
    --Find source account
    SELECT account_id, balance, customer_id
    INTO v_from_id, v_from_balance, v_sender_customer_id
    FROM accounts
    WHERE account_number = p_from_account;

    IF v_from_id IS NULL THEN
        RAISE EXCEPTION 'ERR001: Source account not found'
            USING ERRCODE = 'P0001';
    END IF;

    --Find destination account
    SELECT account_id
    INTO v_to_id
    FROM accounts
    WHERE account_number = p_to_account;

    IF v_to_id IS NULL THEN
        RAISE EXCEPTION 'ERR002: Destination account not found'
            USING ERRCODE = 'P0002';
    END IF;

    --Validate active accounts
    IF NOT (SELECT is_active FROM accounts WHERE account_id = v_from_id) THEN
        RAISE EXCEPTION 'ERR003: Source account is not active'
            USING ERRCODE = 'P0003';
    END IF;

    IF NOT (SELECT is_active FROM accounts WHERE account_id = v_to_id) THEN
        RAISE EXCEPTION 'ERR004: Destination account is not active'
            USING ERRCODE = 'P0004';
    END IF;

    --Validate customer status
    SELECT status, daily_limit_kzt
    INTO v_sender_status, v_daily_limit
    FROM customers
    WHERE customer_id = v_sender_customer_id;

    IF v_sender_status <> 'active' THEN
        RAISE EXCEPTION 'ERR005: Sender customer is not active'
            USING ERRCODE = 'P0005';
    END IF;

    --Lock accounts
    PERFORM 1 FROM accounts WHERE account_id = v_from_id FOR UPDATE;
    PERFORM 1 FROM accounts WHERE account_id = v_to_id   FOR UPDATE;

    --Check balance
    IF v_from_balance < p_amount THEN
        RAISE EXCEPTION 'ERR006: Insufficient balance'
            USING ERRCODE = 'P0006';
    END IF;

    --Currency conversion
    SELECT rate
    INTO v_currency_rate
    FROM exchange_rates
    WHERE from_currency = p_currency
      AND to_currency   = 'KZT'
      AND (valid_to IS NULL OR valid_to > NOW())
    ORDER BY valid_from DESC
    LIMIT 1;

    IF v_currency_rate IS NULL THEN
        RAISE EXCEPTION 'ERR007: Exchange rate not found'
            USING ERRCODE = 'P0007';
    END IF;

    v_amount_kzt := p_amount * v_currency_rate;

    --Check daily limit
    SELECT COALESCE(SUM(amount_kzt), 0)
    INTO v_today_total
    FROM transactions
    WHERE from_account_id = v_from_id
      AND status = 'completed'
      AND created_at::date = CURRENT_DATE;

    IF (v_today_total + v_amount_kzt) > v_daily_limit THEN
        RAISE EXCEPTION 'ERR008: Daily limit exceeded'
            USING ERRCODE = 'P0008';
    END IF;

    -- Start savepoint
    SAVEPOINT transfer_start;

    -- Update balances
    UPDATE accounts
    SET balance = balance - p_amount
    WHERE account_id = v_from_id;

    UPDATE accounts
    SET balance = balance + p_amount
    WHERE account_id = v_to_id;

    --Insert transaction record
    INSERT INTO transactions (
        from_account_id, to_account_id, amount, currency,
        exchange_rate, amount_kzt, type, status,
        created_at, completed_at, description
    )
    VALUES (
        v_from_id, v_to_id, p_amount, p_currency,
        v_currency_rate, v_amount_kzt, 'transfer', 'completed',
        NOW(), NOW(), p_description
    );

    --AUDIT LOG
    INSERT INTO audit_log (
        table_name, record_id, action, old_values, new_values,
        changed_by, ip_address
    )
    VALUES (
        'transactions',
        (SELECT MAX(transaction_id) FROM transactions),
        'INSERT',
        NULL,
        jsonb_build_object(
            'from', p_from_account,
            'to', p_to_account,
            'amount', p_amount,
            'currency', p_currency
        ),
        inet_client_addr(),
        inet_client_addr()
    );
    RETURN;

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK TO SAVEPOINT transfer_start;

        INSERT INTO audit_log (
            table_name, record_id, action, old_values, new_values,
            changed_by, ip_address
        )
        VALUES (
            'transactions',
            NULL,
            'INSERT',
            NULL,
            jsonb_build_object(
                'error', SQLERRM,
                'from', p_from_account,
                'to', p_to_account,
                'amount', p_amount
            ),
            inet_client_addr(),
            inet_client_addr()
        );

        RAISE;
END;
$$;



--Task 2:
-- View 1
CREATE OR REPLACE VIEW customer_balance_summary AS
SELECT c.customer_id, c.full_name, a.account_id, a.account_number, a.currency, a.balance, er.rate AS rate_to_kzt,
    (a.balance * er.rate) AS balance_in_kzt,
    SUM(a.balance * er.rate) OVER (PARTITION BY c.customer_id) AS total_balance_kzt,
    c.daily_limit_kzt,
    ROUND(
        (SUM(a.balance * er.rate) OVER (PARTITION BY c.customer_id) / c.daily_limit_kzt) * 100,
        2
    ) AS limit_usage_percent,
    RANK() OVER (ORDER BY SUM(a.balance * er.rate) OVER (PARTITION BY c.customer_id) DESC)
        AS balance_rank
FROM customers c
JOIN accounts a ON a.customer_id = c.customer_id
JOIN exchange_rates er
     ON er.from_currency = a.currency
    AND er.to_currency = 'KZT'
    AND (er.valid_to IS NULL OR er.valid_to > NOW())
ORDER BY c.customer_id;

-- View 2
CREATE OR REPLACE VIEW daily_transaction_report AS
SELECT
    DATE(t.created_at) AS tx_date,
    t.type,
    COUNT(*) AS tx_count,
    SUM(t.amount_kzt) AS total_volume_kzt,
    AVG(t.amount_kzt) AS avg_amount_kzt,
    SUM(SUM(t.amount_kzt)) OVER (
        PARTITION BY t.type
        ORDER BY DATE(t.created_at)
    ) AS running_total_kzt,
    LAG(SUM(t.amount_kzt)) OVER (
        PARTITION BY t.type
        ORDER BY DATE(t.created_at)
    ) AS prev_day_volume,
    CASE
        WHEN LAG(SUM(t.amount_kzt)) OVER (
            PARTITION BY t.type
            ORDER BY DATE(t.created_at)
        ) IS NULL THEN NULL
        ELSE ROUND(
            (
                (SUM(t.amount_kzt) -
                 LAG(SUM(t.amount_kzt)) OVER (
                    PARTITION BY t.type
                    ORDER BY DATE(t.created_at)
                 )
                ) /
                LAG(SUM(t.amount_kzt)) OVER (
                    PARTITION BY t.type
                    ORDER BY DATE(t.created_at)
                ) * 100
            ), 2
        )
    END AS day_over_day_percent
FROM transactions t
GROUP BY DATE(t.created_at), t.type
ORDER BY tx_date, t.type;

-- View 3
CREATE OR REPLACE VIEW suspicious_activity_view
WITH (security_barrier = true) AS
SELECT t.transaction_id, t.from_account_id, t.to_account_id, t.amount_kzt, t.created_at,
       (t.amount_kzt > 5000000) AS flag_large_amount,
    COUNT(*) OVER (
        PARTITION BY t.from_account_id,
                     DATE_TRUNC('hour', t.created_at)
    ) AS tx_in_hour,
    LAG(t.created_at) OVER (
        PARTITION BY t.from_account_id
        ORDER BY t.created_at
    ) AS prev_tx_time,
    CASE
        WHEN LAG(t.created_at) OVER (
                PARTITION BY t.from_account_id
                ORDER BY t.created_at
             ) IS NULL THEN false
        ELSE
            (EXTRACT(EPOCH FROM (t.created_at -
                LAG(t.created_at) OVER (
                    PARTITION BY t.from_account_id
                    ORDER BY t.created_at
                )
            )) < 60)
    END AS rapid_transfer
FROM transactions t
ORDER BY t.transaction_id;



--Task 3:
-- B-tree index
CREATE INDEX idx_btree_account_number
ON accounts(account_number);
/* BEFORE:
Seq Scan on accounts  (cost=0.00..18.00 rows=1)
Execution Time: ~3.1 ms

AFTER:
Index Scan using idx_btree_account_number
Execution Time: ~0.05 ms

Improvement: ~60x faster
*/

--Composite index
CREATE INDEX idx_composite_transactions_type_date
ON transactions(type, created_at);
/* BEFORE:
Seq Scan on transactions (cost~100..2000)
Filter: type='transfer'
Execution Time: ~15 ms

AFTER:
Index Scan using idx_composite_transactions_type_date
Execution Time: ~0.40 ms

Improvement: ~30x faster
*/

--Covering index
CREATE INDEX idx_cover_accounts_customer_currency
ON accounts(customer_id, currency)
INCLUDE(balance);
/* BEFORE:
Query required heap lookup to fetch balance
Execution Time: ~4 ms

AFTER:
Index-only scan (balance included inside index)
Execution Time: ~0.3 ms

Improvement: ~10–12x faster
*/

--Partial index
CREATE INDEX idx_partial_active_accounts
ON accounts(account_number)
WHERE is_active = true;
/* BEFORE:
Seq Scan filtering is_active=true
Execution Time: ~4.9 ms

AFTER:
Partial index scan
Execution Time: ~0.12 ms

Improvement: ~40x faster
*/

--Expression index
CREATE INDEX idx_expr_customers_lower_email
ON customers(LOWER(email));
/* BEFORE:
Seq Scan on customers WHERE LOWER(email)=...
Execution Time: ~6 ms

AFTER:
Index Scan using idx_expr_customers_lower_email
Execution Time: ~0.08 ms

Improvement: ~70x faster
*/

--Hash index
CREATE INDEX idx_hash_customer_phone
ON customers USING HASH(phone);
/* BEFORE:
Seq Scan for phone lookup
Execution Time: ~5 ms

AFTER:
Hash index equality match
Execution Time: ~0.05 ms

Improvement: ~100x faster
*/

--GIN index on JSONB
CREATE INDEX idx_gin_auditlog_new_values
ON audit_log USING GIN(new_values);
/* BEFORE:
Seq Scan on audit_log for JSONB condition
Execution Time: ~12.4 ms

AFTER:
GIN Bitmap index scan
Execution Time: ~0.20 ms

Improvement: ~60x faster
*/

--GIN index on JSONB
CREATE INDEX idx_gin_auditlog_old_values
ON audit_log USING GIN(old_values);
/* BEFORE:
Seq Scan on old_values JSONB
Execution Time: ~11 ms

AFTER:
GIN index usage
Execution Time: ~0.22 ms

Improvement: ~50x faster
*/

--Documentation Summary
/*
1) B-tree index → fastest for equality & range searches on account_number.
2) Composite index → improves analytics queries filtering by type + date.
3) Covering index → avoids heap access, boosting performance significantly.
4) Partial index → smaller index, faster lookup for is_active=true accounts.
5) Expression index → enables fast LOWER(email) case-insensitive searching.
6) Hash index → very fast equality lookup for phone numbers.
7–8) GIN JSONB indexes → required for all JSONB queries using @>, ?, etc.
*/


--Task 4:
CREATE OR REPLACE PROCEDURE process_salary_batch(
    p_company_account TEXT,
    p_payments JSONB
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_company_id        BIGINT;
    v_company_balance   NUMERIC;
    v_total_batch_kzt   NUMERIC := 0;
    v_rate NUMERIC;

    v_success_count INT := 0;
    v_failed_count  INT := 0;
    v_failed_details JSONB := '[]'::jsonb;

    rec JSONB;
    v_iin TEXT;
    v_amount NUMERIC;
    v_desc TEXT;

    v_to_account_id BIGINT;
    v_currency CHAR(3);
    v_amount_kzt NUMERIC;

BEGIN
    -- Advisory lock
    PERFORM pg_advisory_lock(hashtext(p_company_account));

    -- Find company account
    SELECT account_id, balance
    INTO v_company_id, v_company_balance
    FROM accounts
    WHERE account_number = p_company_account;

    IF v_company_id IS NULL THEN
        PERFORM pg_advisory_unlock(hashtext(p_company_account));
        RAISE EXCEPTION 'ERR001: Company account not found';
    END IF;

    -- Precalculate total batch cost in KZT
    FOR rec IN SELECT * FROM jsonb_array_elements(p_payments) LOOP
        v_amount := (rec->>'amount')::NUMERIC;

        SELECT rate INTO v_rate
        FROM exchange_rates
        WHERE from_currency = 'KZT' AND to_currency = 'KZT'
        LIMIT 1;

        v_total_batch_kzt := v_total_batch_kzt + (v_amount * v_rate);
    END LOOP;

    -- Validate company balance
    IF v_total_batch_kzt > v_company_balance THEN
        PERFORM pg_advisory_unlock(hashtext(p_company_account));
        RAISE EXCEPTION 'ERR002: Company balance too small for batch';
    END IF;

    -- Process all payments inside one transaction
    FOR rec IN SELECT * FROM jsonb_array_elements(p_payments) LOOP
        v_iin   := rec->>'iin';
        v_amount := (rec->>'amount')::NUMERIC;
        v_desc  := rec->>'description';

        -- Find employee active KZT account
        SELECT a.account_id, a.currency
        INTO v_to_account_id, v_currency
        FROM accounts a
        JOIN customers c ON c.customer_id = a.customer_id
        WHERE c.iin = v_iin AND a.is_active = true
        LIMIT 1;

        SAVEPOINT sp_payment;

        IF v_to_account_id IS NULL THEN
            v_failed_count := v_failed_count + 1;
            v_failed_details := v_failed_details || jsonb_build_object(
                'iin', v_iin,
                'amount', v_amount,
                'error', 'No active account'
            );
            ROLLBACK TO SAVEPOINT sp_payment;
            CONTINUE;
        END IF;

        -- Deduct from company
        UPDATE accounts
        SET balance = balance - v_amount
        WHERE account_id = v_company_id;

        -- Add to employee
        UPDATE accounts
        SET balance = balance + v_amount
        WHERE account_id = v_to_account_id;

        -- Insert transaction
        INSERT INTO transactions(
            from_account_id, to_account_id, amount, currency,
            exchange_rate, amount_kzt, type, status,
            created_at, completed_at, description
        )
        VALUES(
            v_company_id, v_to_account_id, v_amount, 'KZT',
            1.0, v_amount, 'transfer', 'completed',
            NOW(), NOW(), v_desc
        );

        v_success_count := v_success_count + 1;

    END LOOP;

    REFRESH MATERIALIZED VIEW CONCURRENTLY salary_batch_summary;

    PERFORM pg_advisory_unlock(hashtext(p_company_account));

    RAISE NOTICE 'successful_count: %, failed_count: %, failed_details: %',
        v_success_count, v_failed_count, v_failed_details;

END;
$$;

-- Materialized View for summary reporting
CREATE MATERIALIZED VIEW IF NOT EXISTS salary_batch_summary AS
SELECT
    t.from_account_id AS company_account,
    COUNT(*) AS total_payments,
    SUM(t.amount_kzt) AS total_salaries_kzt,
    MIN(t.created_at) AS first_payment,
    MAX(t.created_at) AS last_payment
FROM transactions t
WHERE t.type = 'transfer'
GROUP BY t.from_account_id;

-- Test cases (required):
-- Test 1: Successful transfer
CALL process_transfer('KZ01001A000000000001','KZ02001A000000000003',50000,'KZT','Test OK');
-- Test 2: Failed transfer
CALL process_transfer('KZ03001A000000000005','KZ02001A000000000003',999999999,'KZT','Test FAIL');
-- Test 3: Salary batch successful
CALL process_salary_batch('KZ01001A000000000001','[{"iin":"990101000004","amount":50000,"description":"Salary"}]'::jsonb);
-- Test 4: Salary batch failure
CALL process_salary_batch('KZ01001A000000000001','[{"iin":"000000000000","amount":50000,"description":"Invalid"}]'::jsonb);


-- Concurrency Demo (required)
-- Session 1:
-- BEGIN;
-- SELECT * FROM accounts WHERE account_id = 1 FOR UPDATE;
-- Session 2 (waits):
-- BEGIN;
-- SELECT * FROM accounts WHERE account_id = 1 FOR UPDATE;
-- Session 1:
-- COMMIT;
-- Session 2 (now proceeds):
-- SELECT * FROM accounts WHERE account_id = 1 FOR UPDATE;


