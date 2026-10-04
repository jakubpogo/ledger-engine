CREATE KEYSPACE IF NOT EXISTS ledger_core
WITH replication = {'class': 'SimpleStrategy', 'replication_factor': 1};

USE ledger_core;

-- 1. Deduplication store: records requests by idempotency key to prevent duplicate processing
CREATE TABLE IF NOT EXISTS idempotency_records (
    idempotency_key text,
    account_id uuid,
    status text, -- 'PENDING', 'PROCESSED', 'REJECTED'
    response_code int,
    created_at timestamp,
    PRIMARY KEY (idempotency_key)
);

--2. Immutable double-entry ledger (append only)
-- Partitioned by account + month to eliminate unbounded partition bloat and allow for efficient queries by account and time range
CREATE TABLE IF NOT EXISTS ledger_entries (
    account_id uuid,
    year_month text, -- format: YYYY-MM
    entry_id timeuuid,
    amount bigint, --stored in minor units (pence), strictly positive (>0)
    direction text, -- 'DEBIT' or 'CREDIT'
    counterparty text,
    balance_after bigint,
    created_at timestamp,
    PRIMARY KEY ((account_id, year_month), entry_id)
) WITH CLUSTERING ORDER BY (entry_id DESC);

-- 3. Read projection: latest state per account, for O(1) reads of current balance
CREATE TABLE IF NOT EXISTS account_snapshots (
    account_id uuid,
    current_balance bigint,
    last_entry_id timeuuid,
    updated_at timestamp,
    PRIMARY KEY (account_id)
);