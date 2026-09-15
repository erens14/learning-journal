# 📝 Learning Note: Receivable Tax Flags and Grand-Total Recalculation

**Goal:** Correct receivable tax settings and derive financial totals from line items using one documented formula.

**Core Principle:** **Recalculate; do not patch isolated totals.** Tax flags, tax amounts, and final balances must represent the same business rule.

**Business Workflow Chain:** `Receivable` → `Receivable Items` → `Tax Configuration` → `Final Balance`.

---

## 📌 Context & Domain Parameters

| Parameter | Placeholder | Purpose |
| --- | --- | --- |
| Receivable ID | `[receivable_id]` | Target financial document |
| Withholding rate | `[withholding_rate]` | Approved deduction rate |
| Indirect-tax rate | `[indirect_tax_rate]` | Approved addition rate |
| Withholding enabled | `[withholding_enabled]` | Business-rule flag |
| Indirect tax enabled | `[indirect_tax_enabled]` | Business-rule flag |

---

## 🔒 Integrity Rules

- Subtotal equals the sum of active receivable items.
- Each tax amount uses the approved base and rounding policy.
- Final total follows one explicit formula.
- Flags and stored amounts cannot contradict each other.

---

## 🔄 Execution Workflow

1. Inspect header flags, stored totals, and active line items.
2. Calculate subtotal and taxes from approved rates.
3. Update flags and all dependent totals together.
4. Recalculate the same formula in a verification query.
5. Commit only when stored and calculated values match exactly.

---

## 🛠 Generalized SQL Pattern

```sql
-- Pre-check current header and source line totals.
SELECT receivable_id, subtotal, withholding_tax, indirect_tax, final_total,
       withholding_enabled, indirect_tax_enabled, status
FROM receivables
WHERE receivable_id = [receivable_id];

SELECT item_id, line_total, status
FROM receivable_items
WHERE receivable_id = [receivable_id]
  AND status = 1;

START TRANSACTION;

SELECT COALESCE(SUM(line_total), 0)
INTO @calculated_subtotal
FROM receivable_items
WHERE receivable_id = [receivable_id]
  AND status = 1;

SET @calculated_withholding := ROUND(
    @calculated_subtotal * [withholding_rate] * [withholding_enabled],
    2
);

SET @calculated_indirect_tax := ROUND(
    @calculated_subtotal * [indirect_tax_rate] * [indirect_tax_enabled],
    2
);

SET @calculated_final_total :=
    @calculated_subtotal
    + @calculated_indirect_tax
    - @calculated_withholding;

UPDATE receivables
SET subtotal = @calculated_subtotal,
    withholding_tax = @calculated_withholding,
    indirect_tax = @calculated_indirect_tax,
    final_total = @calculated_final_total,
    withholding_enabled = [withholding_enabled],
    indirect_tax_enabled = [indirect_tax_enabled],
    updated_at = NOW()
WHERE receivable_id = [receivable_id]
  AND status = 1;

-- Post-check stored values against independently calculated values.
SELECT
    receivable_id,
    subtotal,
    withholding_tax,
    indirect_tax,
    final_total,
    subtotal + indirect_tax - withholding_tax AS verified_final_total
FROM receivables
WHERE receivable_id = [receivable_id];

ROLLBACK;
-- Replace ROLLBACK with COMMIT only after finance rules and values match.
```

---

## ✅ Verification Checklist

- Active item sum equals stored subtotal.
- Rounding matches the approved currency policy.
- Disabled tax flags produce zero related tax amounts.
- Stored final total equals recalculated final total.

---

## 🧠 Lesson Learned

Financial correction must preserve formula lineage. Updating one visible total without recalculating its components creates hidden inconsistencies across reports and payment workflows.
