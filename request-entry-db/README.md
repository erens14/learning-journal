# Database Integrity Patterns

This folder documents SQL update and correction patterns used for safe data maintenance in relational business workflows.

## Best Starting Points

| Note | Recruiter signal |
| --- | --- |
| [Cascading quantity update pattern](sql-cascading-quantity-update-pattern.md) | Shows parent-child update sequencing and transaction-safe thinking. |
| [Transaction rollback pattern](sql-transaction-rollback-pattern.md) | Shows awareness of rollback, inspection, and controlled correction flow. |
| [Dispatch order unlinking pattern](sql-dispatch-order-unlinking-pattern.md) | Shows workflow dependency cleanup and quantity reallocation logic. |
| [Tax flag and grand total adjustment pattern](tax-flag-and-grand-total-adjustment-pattern.md) | Shows financial data adjustment awareness. |
| [SPS product update pattern](update-sps-product.md) | Shows cross-table product specification update logic. |

## Main Principles

- Inspect related records before modifying data.
- Update child/detail records before parent/summary records when totals depend on details.
- Use explicit transactions for multi-table changes.
- Preserve business workflow consistency across linked tables.
