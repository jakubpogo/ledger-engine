# ledger-engine

An event-driven transaction ledger and state engine written in Go, using Apache Kafka, Apache Cassandra, and React.

## Goals

- **Zero Overdrafts**: Guarantee balance invariants under concurrent debit load.
- **Strict Idempotency**: Deduplicate incoming payment requests via header keys.
- **Append-Only Storage**: Model transactions as immutable ledger entries.
- **Integer Arithmetic**: Process monetary amounts strictly in minor units (pence).

## Target Architecture

- `cmd/gateway`: Stateless HTTP ingestion service publishing to Kafka.
- `cmd/ledger`: Worker consuming keyed events and persisting to Cassandra.
- `web/`: React frontend displaying a live balance feed and transaction history.
- `schema/`: CQL migrations for append-only transaction logs and balance projections.

## Roadmap

- [x] Docker Compose setup for Kafka (KRaft) and Cassandra
- [x] Base Cassandra schema definitions
- [ ] Ingestion gateway with idempotency checks
- [ ] Ledger worker with balance invariant enforcement
- [ ] Real-time React dashboard
- [ ] Concurrent stress test suite
