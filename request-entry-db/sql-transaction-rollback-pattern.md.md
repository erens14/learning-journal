# 📝 Learning Note: Multi-Table Transaction Rollback & Data Adjustment Pattern

**Goal:** Pattern for manually reverting/canceling (soft-delete) complex transaction adjustments while keeping data consistency across related base orders and generated fulfillment items.

---

## 📌 Context & Domain Parameters

This pattern handles scenario where an adjustment document needs to be voided, requiring:

1. Reverting allocated quantities back to the original base order.
2. Resetting pending flags on the source document.
3. Soft-deleting any newly generated fulfillment sub-documents.
4. Soft-deleting the parent adjustment document itself.

| Parameter Name | Example / Placeholder | Role in Rollback |
| --- | --- | --- |
| **Adjustment Code** | `ADJ-2026-0001` | Target main document to be voided |
| **Adjustment ID** | `[adjustment_id]` | Primary key for target adjustment |
| **Base Order ID** | `[base_order_id]` | Target order to refund/restore quantity |
| **Source Fulfillment ID** | `[source_fulfillment_id]` | Original document needing status reset |
| **Generated Fulfillment ID** | `[generated_fulfillment_id]` | New document created by adjustment (to be voided) |

---

## 🔄 Workflow Logic

1. **Pre-Check Verification:** Validate records exist and inspect current quantities before executing state changes.
2. **Revert Base Order Quantity (`sign = '-'`):** Add back the deducted quantity to `allocated_qty` and log `updated_by`.
3. **Reset Source State:** Set `pending_qty` to `0` on the original source document line.
4. **Void Generated Artifacts (`sign = '+'`):** If the adjustment generated new fulfillment entries, set `status = 0` (soft delete) for both detail and header rows.
5. **Void Adjustment Record:** Close the transaction adjustment by setting `status = 0` on both detail and header level.

---

## 🛠 Complete SQL Execution Script

```sql
START TRANSACTION;

-- ====================================================================
-- 1. PRE-CHECK DATA VALIDITY
-- ====================================================================
SELECT * 
FROM transaction_adjustment_details 
WHERE adjustment_id = [adjustment_id];

SELECT * 
FROM base_orders 
WHERE order_id = [base_order_id];

-- ====================================================================
-- 2. REVERT BASE ORDER ALLOCATIONS (For negative adjustment entries)
-- ====================================================================
-- Inspect target details first
SELECT * 
FROM transaction_adjustment_details 
WHERE adjustment_id = [adjustment_id] 
  AND sign = '-';

-- Restore quantity back to base order
UPDATE base_orders
SET allocated_qty = allocated_qty + adjusted_qty,
    updated_at = NOW(),
    updated_by = [current_user_id]
WHERE order_id = [base_order_id];

-- ====================================================================
-- 3. RESET SOURCE FULFILLMENT PENDING QUANTITY
-- ====================================================================
SELECT * 
FROM fulfillment_details 
WHERE fulfillment_id = [source_fulfillment_id];

UPDATE fulfillment_details
SET pending_qty = 0
WHERE fulfillment_id = [source_fulfillment_id];

-- ====================================================================
-- 4. SOFT DELETE GENERATED FULFILLMENTS (For positive adjustment entries)
-- ====================================================================
-- Find generated fulfillment entries created during adjustment
SELECT * 
FROM transaction_adjustment_details 
WHERE adjustment_id = [adjustment_id] 
  AND sign = '+' 
  AND fulfillment_id IS NOT NULL;

-- Soft delete generated detail rows
UPDATE fulfillment_details
SET `status` = 0
WHERE fulfillment_id = [generated_fulfillment_id];

-- Soft delete generated header rows
UPDATE fulfillments
SET `status` = 0
WHERE fulfillment_id = [generated_fulfillment_id];

-- ====================================================================
-- 5. SOFT DELETE ADJUSTMENT HEADER & DETAILS
-- ====================================================================
-- Soft delete adjustment details
UPDATE transaction_adjustment_details
SET `status` = 0
WHERE adjustment_id = [adjustment_id];

-- Soft delete adjustment header
UPDATE transaction_adjustments
SET `status` = 0,
    updated_at = NOW(),
    updated_by = [current_user_id]
WHERE adjustment_id = [adjustment_id];

-- Verification check
SELECT * 
FROM transaction_adjustments 
WHERE adjustment_id = [adjustment_id];

COMMIT;
```
