# Learning Note: Business Reversal and SQL Transaction Rollback

**Goal:** Reverse a committed multi-table adjustment while preserving quantities, generated documents, and audit state.

**Core Principle:** **Business reversal and SQL rollback solve different problems.** `ROLLBACK` cancels uncommitted statements; a committed workflow needs explicit compensating updates inside a new transaction.

**Business Workflow Chain:** `Adjustment` → `Adjustment Items` → `Base Order` → `Generated Fulfillment`.

---

## Context & Domain Parameters

| Parameter | Placeholder | Purpose |
| --- | --- | --- |
| Adjustment ID | `[adjustment_id]` | Committed adjustment being reversed |
| Base order ID | `[base_order_id]` | Order receiving restored quantity |
| Generated fulfillment ID | `[generated_fulfillment_id]` | Artifact created by the adjustment |
| Reversal quantity | `[reversal_quantity]` | Approved amount to restore |
| Current user | `[current_user]` | Sanitized audit actor placeholder |

---

## Integrity Rules

- Adjustment must still be active and eligible for reversal.
- Restored quantity must equal the original committed adjustment effect.
- Generated documents are voided with status changes, not physically deleted.
- Header and detail states change together with audit fields.

---

## Execution Workflow

1. Inspect adjustment, items, base order, and generated records.
2. Start a transaction, claim the active adjustment header, and lock its related rows.
3. Reconstruct and validate the complete effect from those locked adjustment items before restoring quantity.
4. Restore the stored effect and void its generated records only when that claim succeeds.
5. Verify all invariants before committing the compensating transaction.

---

## Generalized SQL Pattern

All affected tables must use a transactional engine such as InnoDB, and every statement must use the same database connection.

This is a MySQL-oriented, single-adjustment/single-order illustration with placeholders, not a production reversal procedure. It assumes `quantity_delta` is the positive amount to restore and the supplied order and fulfillment identify the entire original effect. Resolve those relationships and expected detail counts from stored records before use. Reject mixed-order or mixed-fulfillment adjustments rather than applying this simplified pattern to them.

The conditional header update is the claim: it locks the active header until transaction completion. A replay after commit claims zero rows and cannot restore quantity again. All writers that change this adjustment or its item set must coordinate through the same header lock; otherwise the stored effect can change outside this protocol. Inspect and lock the related item, order, and fulfillment rows inside the transaction before calculating the approved effect; the pre-checks below are discovery only.

The caller must capture and check affected-row counts immediately after each update, including the expected fulfillment and adjustment detail counts. Roll back on zero or unexpected counts, SQL errors, deadlocks, or failed post-checks. Retry a deadlocked transaction from the beginning. Do not continue to commit after a failed statement: MySQL does not automatically roll back the entire transaction for every error. Audit the reason, actor, and stored original effect. No SQL was executed for this note.

```sql
-- Pre-check the committed business effect.
SELECT adjustment_id, order_id, quantity_delta, generated_fulfillment_id, status
FROM adjustment_items
WHERE adjustment_id = [adjustment_id];

SELECT order_id, available_quantity, status
FROM base_orders
WHERE order_id = [base_order_id];

START TRANSACTION;

-- Claim eligibility first. Concurrent claims serialize on this header row.
UPDATE adjustments
SET status = 0,
    reversal_reason = '[sanitized_reason]',
    updated_at = NOW(),
    updated_by = '[current_user]'
WHERE adjustment_id = [adjustment_id]
  AND status = 1;
SET @claimed_reversal = ROW_COUNT();

-- A replay claims zero rows, so every dependent update below is a no-op.
-- Lock the source effect and related state before calculating restoration.
SELECT adjustment_id, order_id, quantity_delta, generated_fulfillment_id, status
FROM adjustment_items
WHERE adjustment_id = [adjustment_id]
  AND @claimed_reversal = 1
FOR UPDATE;

SELECT order_id, available_quantity, status
FROM base_orders
WHERE order_id = [base_order_id]
  AND @claimed_reversal = 1
FOR UPDATE;

SELECT fulfillment_id, status
FROM fulfillment_headers
WHERE fulfillment_id = [generated_fulfillment_id]
  AND @claimed_reversal = 1
FOR UPDATE;

SELECT fulfillment_id, status
FROM fulfillment_items
WHERE fulfillment_id = [generated_fulfillment_id]
  AND @claimed_reversal = 1
FOR UPDATE;

UPDATE base_orders
SET available_quantity = available_quantity + [reversal_quantity],
    updated_at = NOW(),
    updated_by = '[current_user]'
WHERE order_id = [base_order_id]
  AND status = 1
  AND @claimed_reversal = 1
  AND [reversal_quantity] > 0
  AND [reversal_quantity] = (
      SELECT SUM(quantity_delta)
      FROM adjustment_items
      WHERE adjustment_id = [adjustment_id]
        AND order_id = [base_order_id]
        AND generated_fulfillment_id = [generated_fulfillment_id]
        AND status = 1
  );
SET @restored_orders = ROW_COUNT();

UPDATE fulfillment_items
SET status = 0,
    updated_at = NOW(),
    updated_by = '[current_user]'
WHERE fulfillment_id = [generated_fulfillment_id]
  AND status = 1
  AND @claimed_reversal = 1
  AND @restored_orders = 1;
SET @voided_fulfillment_items = ROW_COUNT();

UPDATE fulfillment_headers
SET status = 0,
    updated_at = NOW(),
    updated_by = '[current_user]'
WHERE fulfillment_id = [generated_fulfillment_id]
  AND status = 1
  AND @claimed_reversal = 1
  AND @restored_orders = 1;
SET @voided_fulfillment_headers = ROW_COUNT();

UPDATE adjustment_items
SET status = 0,
    updated_at = NOW(),
    updated_by = '[current_user]'
WHERE adjustment_id = [adjustment_id]
  AND status = 1
  AND @claimed_reversal = 1
  AND @restored_orders = 1;

SET @voided_adjustment_items = ROW_COUNT();

SELECT @claimed_reversal AS claimed_headers,
       @restored_orders AS restored_orders,
       @voided_fulfillment_headers AS voided_fulfillment_headers,
       @voided_fulfillment_items AS voided_fulfillment_items,
       @voided_adjustment_items AS voided_adjustment_items;

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
-- Keep ROLLBACK unless the caller verifies every required transition and count.
```

---

## Verification Checklist

- First execution claims exactly one active header and restores exactly one base order; committed replay restores none.
- Restored quantity matches the complete stored adjustment effect under transaction locks.
- Expected affected-row counts and every linked state are checked; any mismatch or exception rolls back the whole attempt.
- Generated header and detail records share the voided state.
- Adjustment header and items share the reversed state.
- Audit fields identify the approved actor and time.

---

## Lesson Learned

A committed transaction cannot be undone with a later `ROLLBACK`. Reliable reversals model the opposite business effect explicitly and apply it atomically.
