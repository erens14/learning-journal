# 📝 Learning Note: Cross-Table Product Specification Update Pattern

**Goal:** Pattern for safely updating product specifications (`product_id`) across primary order details (`sps_detail`) and linked fulfillment records (`direct_order`) while ensuring data integrity via condition safeguards and atomic transactions.

---

## 📌 Context & Domain Parameters

This pattern handles scenarios where a user requests a correction for an incorrectly assigned product size/specification across multiple main documents and their corresponding sub-order lines.

| Parameter Name | Example / Placeholder | Role in Transaction |
| --- | --- | --- |
| **Target SPS Numbers** | `'SPS/2026/XXX-001'`, `'SPS/2026/XXX-002'` | Target main documents requiring item update |
| **Old Product Name** | `'[NAMA_PRODUK_LAMA]'` | Source product specification to be replaced |
| **New Product Name** | `'[NAMA_PRODUK_BARU]'` | Target correct product specification |

---

## 🔄 Workflow Logic

1. **Pre-Check Verification:** Inspect existing SPS details, direct orders, and verify both source and target `product_id` values before executing state changes.
2. **Update Primary Order Details (`sps_detail`):** Reassign `product_id` to the new product ID for target SPS numbers, restricted by the old `product_id` as a safeguard.
3. **Update Linked Direct Orders (`direct_order`):** Reassign `product_id` on associated direct order records using the same safeguard filters.
4. **Post-Check & Verification:** Re-query both tables to verify the product updates were applied cleanly before issuing `COMMIT`.

---

## 🛠 Complete SQL Execution Script

```sql
START TRANSACTION;

-- ====================================================================
-- 1. PRE-CHECK DATA VALIDITY
-- ====================================================================
-- Inspect target SPS & SPS Detail records
SELECT 
    s.sps_id,
    s.sps_no,
    sd.sps_detail_id,
    sd.product_id,
    p.name AS product_name
FROM sps s
JOIN sps_detail sd ON s.sps_id = sd.sps_id
JOIN product p ON sd.product_id = p.product_id
WHERE s.sps_no IN (
    'SPS/2026/XXX-001',
    'SPS/2026/XXX-002'
);

-- Inspect target Direct Order records
SELECT 
    do.direct_order_id,
    do.sps_id,
    do.product_id,
    p.name AS product_name
FROM direct_order do
JOIN sps s ON do.sps_id = s.sps_id
JOIN product p ON do.product_id = p.product_id
WHERE s.sps_no IN (
    'SPS/2026/XXX-001',
    'SPS/2026/XXX-002'
);

-- Verify source & target product IDs
SELECT product_id, `name` 
FROM product 
WHERE `name` IN ('[NAMA_PRODUK_LAMA]', '[NAMA_PRODUK_BARU]');

-- ====================================================================
-- 2. UPDATE PRIMARY ORDER DETAILS (sps_detail)
-- ====================================================================
UPDATE sps_detail sd
JOIN sps s ON sd.sps_id = s.sps_id
SET sd.product_id = (
    SELECT product_id 
    FROM product 
    WHERE `name` = '[NAMA_PRODUK_BARU]' 
    LIMIT 1
)
WHERE s.sps_no IN (
    'SPS/2026/XXX-001',
    'SPS/2026/XXX-002'
)
-- Safeguard: Only update lines matching the old product ID
AND sd.product_id = (
    SELECT product_id 
    FROM product 
    WHERE `name` = '[NAMA_PRODUK_LAMA]' 
    LIMIT 1
);

-- ====================================================================
-- 3. UPDATE LINKED DIRECT ORDERS (direct_order)
-- ====================================================================
UPDATE direct_order do
JOIN sps s ON do.sps_id = s.sps_id
SET do.product_id = (
    SELECT product_id 
    FROM product 
    WHERE `name` = '[NAMA_PRODUK_BARU]' 
    LIMIT 1
)
WHERE s.sps_no IN (
    'SPS/2026/XXX-001',
    'SPS/2026/XXX-002'
)
-- Safeguard: Only update lines matching the old product ID
AND do.product_id = (
    SELECT product_id 
    FROM product 
    WHERE `name` = '[NAMA_PRODUK_LAMA]' 
    LIMIT 1
);

-- ====================================================================
-- 4. POST-CHECK VERIFICATION
-- ====================================================================
-- Re-verify SPS Details after update
SELECT 
    s.sps_no,
    sd.sps_detail_id,
    sd.product_id,
    p.name AS product_name
FROM sps s
JOIN sps_detail sd ON s.sps_id = sd.sps_id
JOIN product p ON sd.product_id = p.product_id
WHERE s.sps_no IN (
    'SPS/2026/XXX-001',
    'SPS/2026/XXX-002'
);

-- Re-verify Direct Orders after update
SELECT 
    s.sps_no,
    do.direct_order_id,
    do.product_id,
    p.name AS product_name
FROM direct_order do
JOIN sps s ON do.sps_id = s.sps_id
JOIN product p ON do.product_id = p.product_id
WHERE s.sps_no IN (
    'SPS/2026/XXX-001',
    'SPS/2026/XXX-002'
);

-- Commit transaction if affected rows match expectation; otherwise execute ROLLBACK
COMMIT;
-- ROLLBACK;

```