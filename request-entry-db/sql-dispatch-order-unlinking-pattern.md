# 📝 Learning Note: Detaching a Dispatch Assignment and Restoring Availability

**Goal:** Remove one fulfillment order from a dispatch schedule and restore its available quantity without double-counting the released allocation.

**Core Principle:** **Release the relationship and restore its effect in one transaction.** Both changes represent one business action.

**Business Workflow Chain:** `Dispatch Schedule` → `Dispatch Assignment` → `Fulfillment Order Availability`.

---

## 📌 Context & Domain Parameters

| Parameter | Placeholder | Purpose |
| --- | --- | --- |
| Schedule ID | `[schedule_id]` | Schedule currently holding the assignment |
| Assignment ID | `[assignment_id]` | Relationship to release |
| Order ID | `[order_id]` | Fulfillment order receiving restored availability |
| Released quantity | `[released_quantity]` | Quantity returned to the order |
| Released packages | `[released_packages]` | Package count returned to the order |

---

## 🔒 Integrity Rules

- Assignment must be active and belong to both target schedule and order.
- Release must affect exactly one assignment.
- Availability is restored only when the assignment release succeeds.
- Re-running the same correction must not restore quantities twice.

---

## 🔄 Execution Workflow

1. Join the schedule, assignment, and order to confirm ownership and current values.
2. Save the expected released quantity and package count.
3. Deactivate the assignment using current-state guards.
4. Restore order availability only after one assignment row changes.
5. Verify relationship status and totals before finalizing.

---

## 🛠 Generalized SQL Pattern

```sql
-- Pre-check ownership, status, and current availability.
SELECT
    a.assignment_id,
    a.schedule_id,
    a.order_id,
    a.assigned_quantity,
    a.assigned_packages,
    a.status,
    o.available_quantity,
    o.available_packages
FROM dispatch_assignments a
JOIN fulfillment_orders o ON o.order_id = a.order_id
WHERE a.assignment_id = [assignment_id]
  AND a.schedule_id = [schedule_id]
  AND a.order_id = [order_id];

START TRANSACTION;

UPDATE dispatch_assignments
SET status = 0,
    updated_at = NOW()
WHERE assignment_id = [assignment_id]
  AND schedule_id = [schedule_id]
  AND order_id = [order_id]
  AND status = 1;

SET @released_assignment_rows := ROW_COUNT();

UPDATE fulfillment_orders
SET available_quantity = available_quantity + [released_quantity],
    available_packages = available_packages + [released_packages],
    updated_at = NOW()
WHERE order_id = [order_id]
  AND status = 1
  AND @released_assignment_rows = 1;

-- Post-check assignment state and restored availability.
SELECT assignment_id, status
FROM dispatch_assignments
WHERE assignment_id = [assignment_id];

SELECT order_id, available_quantity, available_packages
FROM fulfillment_orders
WHERE order_id = [order_id];

ROLLBACK;
-- Replace ROLLBACK with COMMIT only when one assignment was released
-- and restored availability equals the approved expected values.
```

---

## ✅ Verification Checklist

- Assignment update affects exactly one active row.
- Order availability increases by the released values once.
- No other schedule or order changes.
- Re-running the guarded update affects zero rows.

---

## 🧠 Lesson Learned

Unlinking a record is incomplete when its consumed quantity remains allocated. Relationship state and inventory effect must be reversed atomically and verified together.
