# 📝 Learning Note: Accounts Receivable Tax Flag & Grand Total Adjustment Pattern

**Goal:** Pattern for updating tax printing configurations (`pph_print`, `ppn_print`) and recalculating final payable amounts on receivable records while verifying associated line items and source vehicle orders.

---

## 📌 Context & Domain Parameters

This pattern handles scenarios where a receivable record requires manual adjustments to its tax printing flags (e.g., enabling PPh tax deduction and disabling PPN tax) along with updated grand totals and net final totals.

| Parameter Name | Example / Placeholder | Role in Adjustment |
| --- | --- | --- |
| **Receivable Code** | `'REC/2026/XXX-001'` | Target main receivable document code |
| **Receivable ID** | `[receivable_id]` | Primary key for target receivable record |
| **Vehicle Order ID** | `[vehicle_order_id]` | Linked source vehicle order reference |
| **PPh Print Flag** | `1` | Enable PPh (Income Tax) print flag |
| **PPN Print Flag** | `0` | Disable PPN (VAT) print flag |
| **Grand Total** | `4550000` | Base total amount before tax deduction |
| **Grand Total Final** | `4550000 - 91000` | Net final amount after PPh deduction |

---

## 🔄 Workflow Logic

1. **Pre-Check Verification:** Query the primary receivable record, its line details, and the linked vehicle order to inspect current financial figures and tax flags.
2. **Update Receivable Tax Flags & Totals:** Modify `pph_print` and `ppn_print` flags while recalculating `grand_total` and `grand_total_final` in an atomic transaction.
3. **Post-Check Verification:** Re-query the updated receivable record to confirm the new totals and tax statuses before issuing `COMMIT`.

---

## 🛠 Complete SQL Execution Script

```sql
START TRANSACTION;

-- ====================================================================
-- 1. PRE-CHECK DATA VALIDITY
-- ====================================================================
-- Inspect target receivable header record
SELECT * 
FROM receivable 
WHERE receivable_no = 'REC/2026/XXX-001';

-- Inspect related receivable line details
SELECT * 
FROM receivable_detail 
WHERE receivable_id = [receivable_id];

-- Inspect associated source vehicle order
SELECT * 
FROM vehicle_order 
WHERE vehicle_order_id = [vehicle_order_id];

-- ====================================================================
-- 2. UPDATE RECEIVABLE TAX FLAGS & GRAND TOTALS
-- ====================================================================
UPDATE receivable
SET pph_print = 1,
    ppn_print = 0,
    grand_total = 4550000,
    grand_total_final = 4550000 - 91000,
    updated_at = NOW(),
    updated_by = [current_user_id]
WHERE receivable_id = [receivable_id];

-- ====================================================================
-- 3. POST-CHECK VERIFICATION
-- ====================================================================
-- Re-verify receivable header record after update
SELECT 
    receivable_id,
    receivable_no,
    pph_print,
    ppn_print,
    grand_total,
    grand_total_final,
    updated_at,
    updated_by
FROM receivable 
WHERE receivable_id = [receivable_id];

-- Commit transaction if affected rows match expectation; otherwise execute ROLLBACK
COMMIT;
-- ROLLBACK;

```
