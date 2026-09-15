# 📝 Learning Note: Business Reversal and SQL Transaction Rollback

**Goal:** Reverse a committed multi-table adjustment while preserving quantities, generated documents, and audit state.

**Core Principle:** **Business reversal and SQL rollback solve different problems.** `ROLLBACK` cancels uncommitted statements; a committed workflow needs explicit compensating updates inside a new transaction.

**Business Workflow Chain:** `Adjustment` → `Adjustment Items` → `Base Order` → `Generated Fulfillment`.

---

## 📌 Context & Domain Parameters

| Parameter | Placeholder | Purpose |
| --- | --- | --- |
| Adjustment ID | `[adjustment_id]` | Committed adjustment being reversed |
| Base order ID | `[base_order_id]` | Order receiving restored quantity |
| Generated fulfillment ID | `[generated_fulfillment_id]` | Artifact created by the adjustment |
| Reversal quantity | `[reversal_quantity]` | Approved amount to restore |
| Current user | `[current_user]` | Sanitized audit actor placeholder |

---

## 🔒 Integrity Rules

- Adjustment must still be active and eligible for reversal.
- Restored quantity must equal the original committed adjustment effect.
- Generated documents are voided with status changes, not physically deleted.
- Header and detail states change together with audit fields.

---

## 🔄 Execution Workflow

1. Inspect adjustment, items, base order, and generated records.
2. Reconstruct the original effect from stored adjustment items.
3. Restore base-order quantity and void generated artifacts.
4. Mark adjustment details and header reversed.
5. Verify all invariants before committing the compensating transaction.

---

## 🛠 Generalized SQL Pattern

```sql
-- Pre-check the committed business effect.
SELECT adjustment_id, order_id, quantity_delta, generated_fulfillment_id, status
FROM adjustment_items
WHERE adjustment_id = [adjustment_id];

SELECT order_id, available_quantity, status
FROM base_orders
WHERE order_id = [base_order_id];

START TRANSACTION;

UPDATE base_orders
SET available_quantity = available_quantity + [reversal_quantity],
    updated_at = NOW(),
    updated_by = '[current_user]'
WHERE order_id = [base_order_id]
  AND status = 1;

UPDATE fulfillment_items
SET status = 0,
    updated_at = NOW(),
    updated_by = '[current_user]'
WHERE fulfillment_id = [generated_fulfillment_id]
  AND status = 1;

UPDATE fulfillment_headers
SET status = 0,
    updated_at = NOW(),
    updated_by = '[current_user]'
WHERE fulfillment_id = [generated_fulfillment_id]
  AND status = 1;

UPDATE adjustment_items
SET status = 0,
    updated_at = NOW(),
    updated_by = '[current_user]'
WHERE adjustment_id = [adjustment_id]
  AND status = 1;

UPDATE adjustments
SET status = 0,
    reversal_reason = '[sanitized_reason]',
    updated_at = NOW(),
    updated_by = '[current_user]'
WHERE adjustment_id = [adjustment_id]
  AND status = 1;

-- Post-check restored quantity and complete reversal state.
SELECT order_id, available_quantity
FROM base_orders
WHERE order_id = [base_order_id];

SELECT adjustment_id, status
FROM adjustments
WHERE adjustment_id = [adjustment_id];

SELECT fulfillment_id, status
FROM fulfillment_headers
WHERE fulfillment_id = [generated_fulfillment_id];

ROLLBACK;
-- Replace ROLLBACK with COMMIT only after the compensating result is verified.
```

---

## ✅ Verification Checklist

- Restored quantity matches original adjustment effect.
- Generated header and detail records share the voided state.
- Adjustment header and items share the reversed state.
- Audit fields identify the approved actor and time.

---

## 🧠 Lesson Learned

A committed transaction cannot be undone with a later `ROLLBACK`. Reliable reversals model the opposite business effect explicitly and apply it atomically.
