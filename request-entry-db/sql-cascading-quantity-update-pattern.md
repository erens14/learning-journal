# 📝 Learning Note: Cascading Quantity Updates

**Goal:** Correct quantities across allocation, line-item, and header levels without leaving conflicting totals.

**Core Principle:** **Recalculate from the lowest trusted level.** Update the child record, then derive parent totals from stored children instead of repeating handwritten totals.

**Business Workflow Chain:** `Fulfillment Header` → `Fulfillment Line` → `Item Allocation`.

---

## 📌 Context & Domain Parameters

| Parameter | Placeholder | Purpose |
| --- | --- | --- |
| Fulfillment ID | `[fulfillment_id]` | Target workflow header |
| Line ID | `[line_id]` | Parent line being reconciled |
| Allocation ID | `[allocation_id]` | Lowest-level record to correct |
| Old quantity | `[old_quantity]` | Current-state guard |
| New quantity | `[new_quantity]` | Approved corrected value |

---

## 🔒 Integrity Rules

- Target allocation must exist exactly once and still contain the expected old quantity.
- Line quantity must equal the sum of active allocations.
- Header quantity must equal the sum of active lines.
- No record outside the selected fulfillment can change.

---

## 🔄 Execution Workflow

1. Inspect header, line, and allocation values.
2. Record expected row counts and calculated totals.
3. Update the allocation with identifier and old-value guards.
4. Recalculate the line and header from active child records.
5. Verify totals, then choose `COMMIT` or `ROLLBACK`.

---

## 🛠 Generalized SQL Pattern

```sql
-- Pre-check: inspect only fields required for reconciliation.
SELECT allocation_id, line_id, allocated_quantity, status
FROM fulfillment_allocations
WHERE allocation_id = [allocation_id]
  AND line_id = [line_id];

SELECT line_id, fulfillment_id, shipped_quantity, status
FROM fulfillment_lines
WHERE line_id = [line_id]
  AND fulfillment_id = [fulfillment_id];

START TRANSACTION;

UPDATE fulfillment_allocations
SET allocated_quantity = [new_quantity]
WHERE allocation_id = [allocation_id]
  AND line_id = [line_id]
  AND allocated_quantity = [old_quantity]
  AND status = 1;

SELECT ROW_COUNT() AS allocation_rows_updated;

UPDATE fulfillment_lines
SET shipped_quantity = (
    SELECT COALESCE(SUM(allocated_quantity), 0)
    FROM fulfillment_allocations
    WHERE line_id = [line_id]
      AND status = 1
)
WHERE line_id = [line_id]
  AND fulfillment_id = [fulfillment_id]
  AND status = 1;

UPDATE fulfillment_headers
SET total_shipped_quantity = (
    SELECT COALESCE(SUM(shipped_quantity), 0)
    FROM fulfillment_lines
    WHERE fulfillment_id = [fulfillment_id]
      AND status = 1
)
WHERE fulfillment_id = [fulfillment_id]
  AND status = 1;

-- Post-check: child sum, line total, and header total must agree.
SELECT
    h.fulfillment_id,
    h.total_shipped_quantity,
    SUM(l.shipped_quantity) AS calculated_header_quantity
FROM fulfillment_headers h
JOIN fulfillment_lines l ON l.fulfillment_id = h.fulfillment_id
WHERE h.fulfillment_id = [fulfillment_id]
  AND l.status = 1
GROUP BY h.fulfillment_id, h.total_shipped_quantity;

-- Safe default for a portfolio example.
ROLLBACK;
-- Replace ROLLBACK with COMMIT only after every check matches expectation.
```

---

## ✅ Verification Checklist

- Guarded allocation update affects exactly one row.
- Child, line, and header quantities reconcile.
- Active-status filters exclude voided records.
- Unrelated fulfillment records remain unchanged.

---

## 🧠 Lesson Learned

Repeated manual totals create drift. Deriving each summary from its active children makes the correction auditable and reduces arithmetic mistakes.
