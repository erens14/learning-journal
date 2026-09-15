# 📝 Learning Note: Cross-Table Product Reference Correction

**Goal:** Replace an incorrect product reference across an order line and its dependent fulfillment records without changing unrelated transactions.

**Core Principle:** **Resolve stable keys first, then update every dependent reference with old-state guards.** Product names are discovery aids, not safe update keys.

**Business Workflow Chain:** `Product Master` → `Order Line` → `Fulfillment Record`.

---

## 📌 Context & Domain Parameters

| Parameter | Placeholder | Purpose |
| --- | --- | --- |
| Order ID | `[order_id]` | Parent transaction containing incorrect reference |
| Order line ID | `[order_line_id]` | Specific line to correct |
| Fulfillment ID | `[fulfillment_id]` | Dependent record using same product |
| Old product ID | `[old_product_id]` | Current-state guard |
| New product ID | `[new_product_id]` | Approved replacement reference |

---

## 🔒 Integrity Rules

- Old and new product IDs must resolve to active, distinct master records.
- Target line and fulfillment record must belong to the same order workflow.
- Both records must currently reference the old product.
- Each update must affect exactly one expected row.

---

## 🔄 Execution Workflow

1. Resolve old and new products by stable code and confirm uniqueness.
2. Join order line and fulfillment record to confirm shared ownership.
3. Update both references inside one transaction using old-product guards.
4. Re-query joined records and product codes.
5. Commit only when both references match the approved product.

---

## 🛠 Generalized SQL Pattern

```sql
-- Pre-check product identities using stable codes.
SELECT product_id, product_code, status
FROM products
WHERE product_code IN ('[old_product_code]', '[new_product_code]');

-- Confirm both dependent records belong to the target workflow.
SELECT
    ol.order_line_id,
    ol.order_id,
    ol.product_id AS line_product_id,
    f.fulfillment_id,
    f.product_id AS fulfillment_product_id
FROM order_lines ol
JOIN fulfillments f ON f.order_line_id = ol.order_line_id
WHERE ol.order_id = [order_id]
  AND ol.order_line_id = [order_line_id]
  AND f.fulfillment_id = [fulfillment_id];

START TRANSACTION;

UPDATE order_lines
SET product_id = [new_product_id],
    updated_at = NOW()
WHERE order_id = [order_id]
  AND order_line_id = [order_line_id]
  AND product_id = [old_product_id]
  AND status = 1;

SELECT ROW_COUNT() AS order_line_rows_updated;

UPDATE fulfillments
SET product_id = [new_product_id],
    updated_at = NOW()
WHERE fulfillment_id = [fulfillment_id]
  AND order_line_id = [order_line_id]
  AND product_id = [old_product_id]
  AND status = 1;

SELECT ROW_COUNT() AS fulfillment_rows_updated;

-- Post-check both references and resolved product code.
SELECT
    ol.order_line_id,
    p1.product_code AS order_line_product,
    f.fulfillment_id,
    p2.product_code AS fulfillment_product
FROM order_lines ol
JOIN products p1 ON p1.product_id = ol.product_id
JOIN fulfillments f ON f.order_line_id = ol.order_line_id
JOIN products p2 ON p2.product_id = f.product_id
WHERE ol.order_line_id = [order_line_id]
  AND f.fulfillment_id = [fulfillment_id];

ROLLBACK;
-- Replace ROLLBACK with COMMIT only when both guarded updates affect one row.
```

---

## ✅ Verification Checklist

- Product codes resolve to one active record each.
- Order line and fulfillment remain linked to the same workflow.
- Both product references change from expected old ID to approved new ID.
- Unrelated lines and fulfillments remain unchanged.

---

## 🧠 Lesson Learned

Cross-table reference repair succeeds only when identity and ownership are proven first. Stable keys and old-state guards prevent a targeted correction from becoming a broad data rewrite.
