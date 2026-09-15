# Database Integrity Patterns

This folder contains generalized SQL patterns derived from data-maintenance experience. Each lesson focuses on investigation, bounded updates, transaction safety, verification, and rollback decisions.

All schemas, identifiers, quantities, financial values, users, and document references are fictional placeholders. These examples are learning material, not production runbooks.

## Best Starting Points

| Note | Recruiter signal |
| --- | --- |
| [Dependency discovery before data correction](sql-dependency-discovery-before-data-correction.md) | Maps foreign keys and affected records before any write. |
| [Cascading quantity update pattern](sql-cascading-quantity-update-pattern.md) | Reconciles detail and summary quantities from child to parent. |
| [Dispatch order unlinking pattern](sql-dispatch-order-unlinking-pattern.md) | Releases an assignment and restores availability atomically. |
| [Transaction reversal and rollback pattern](sql-transaction-rollback-pattern.md) | Distinguishes committed business reversal from SQL rollback. |
| [Tax flag and grand-total adjustment pattern](tax-flag-and-grand-total-adjustment-pattern.md) | Recalculates financial totals from explicit inputs and formulas. |
| [Cross-table product reference correction](update-sps-product.md) | Updates one reference consistently across dependent records. |

## Main Principles

- Inspect target records and dependencies before writing.
- State invariants and expected affected-row counts before execution.
- Use restrictive `WHERE` clauses with both identifiers and current-state guards.
- Keep related writes inside one transaction.
- Re-query totals, relationships, and statuses before choosing `COMMIT`.
- Use `ROLLBACK` when any result differs from the expected state.
