# 📝 Learning Note: Cascading Quantity Updates (Bottom-to-Top Edit Pattern)

**Goal:** Safely adjust shipped quantities across hierarchical logistics documents without corrupting data integrity or causing child-parent discrepancies.

**Core Principle:** **"Bottom-to-Top Edit Pattern"** — Always update child/line-item detail records first before applying summarized changes to parent/header records.

**Business Workflow Chain:** `Create Fulfillment Order` $\rightarrow$ `Create Shipment Manifest` $\rightarrow$ `Create Shipment Line Item` $\rightarrow$ `Create Item Allocations / Order Links`.

---

## 📌 Context & Domain Parameters

| Parameter Name | Example / Placeholder | Role in Workflow |
| --- | --- | --- |
| **Manifest ID** | `[manifest_id]` | Master shipment record |
| **Shipment Item ID** | `[shipment_item_id]` | Parent line-item record |
| **Detail Item ID** | `[detail_item_id]` | Child allocation/item detail record |

---

## 🔄 Execution Workflow

### Step 1: Initial Data Inspection

- Identify the target **Manifest ID** and **Shipment Item ID**.
- Verify if the shipment line item links to child allocation details (`shipment_item_details`) or source order links (`shipment_order_links`).

### Step 2: Conditional Workflow Validation

- **Condition A (Linked to `shipment_item_details`):**
  - Quantity on child detail records must be updated first before modifying the parent summary line.
- **Condition B (Linked to `shipment_order_links`):**
  - Re-verify input quantities against the source order document. Once confirmed, apply the same child-to-parent update logic.

### Step 3: Data Modification (Bottom-to-Top Edit)

- Execute quantity updates sequentially starting from the lowest child detail table up to the parent header record inside an explicit database transaction block.

---

## 🛠 Complete SQL Execution Script

```sql
-- ==============================================================================
-- STEP 1: DATA INSPECTION & DEPENDENCY CHECK
-- Check master manifest, shipment line item, and associated child allocations.
-- ==============================================================================
SELECT * 
FROM shipment_manifests 
WHERE manifest_id = [manifest_id];

SELECT * 
FROM shipment_line_items 
WHERE shipment_item_id = [shipment_item_id];

SELECT * 
FROM shipment_item_details 
WHERE shipment_item_id = [shipment_item_id];

-- ==============================================================================
-- STEP 2 & 3: BOTTOM-TO-TOP QUANTITY UPDATE
-- Sequentially update quantities from lowest child level up to parent summary.
-- ==============================================================================
START TRANSACTION;

-- 1. Update child detail level first (Bottom)
UPDATE shipment_item_details
SET shipped_qty = [new_quantity]
WHERE shipment_item_id = [shipment_item_id];

-- 2. Update parent summary line after child details are updated (Top)
UPDATE shipment_line_items
SET total_shipped_qty = [new_quantity]
WHERE shipment_item_id = [shipment_item_id];

COMMIT;
```
