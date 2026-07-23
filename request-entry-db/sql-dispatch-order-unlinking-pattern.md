# 📝 Learning Note: Detaching Orders from Dispatch Schedules & Reallocating Quantities

**Goal:** Pattern for unlinking an order line/item from an assigned shipment/expedition schedule, resetting its pickup assignment, and recalculating the physical stock quantity on the core fulfillment document.

---

## 📌 Context & Domain Parameters

When a dispatch item or order line is cancelled from a scheduled shipment run, system integrity requires:

1. Releasing the link between the order and the logistics dispatch schedule.
2. Resetting the pickup status so the order can be reassigned to future runs.
3. Restoring or adjusting physical inventory quantities (`actual_quantity` and `package_count`) on the main fulfillment order.

| Parameter Name | Example / Placeholder | Role in Workflow |
| --- | --- | --- |
| **Schedule ID** | `[schedule_id]` | Target shipment schedule |
| **Fulfillment Order ID** | `[fulfillment_order_id]` | Primary key for target order line |
| **Fulfillment Order Code** | `[fulfillment_order_code]` | Human-readable document code (e.g., `FO-2026-0012`) |

---

## 🔄 Execution Workflow

### Step 1: Initial Data Inspection

- Identify the **Schedule ID** for the affected dispatch run.
- Inspect `shipment_schedules` and `dispatch_item_mappings` to verify current schedule details.
- Query `dispatch_item_pickups` using `[fulfillment_order_id]` to confirm assignment status.
- Inspect `fulfillment_orders` to check current physical quantities before updating.

### Step 2: Unlink Assignment & Reset Pickup Status

- Access `dispatch_item_pickups` for the specific order.
- Set `status = 0` to unbind the order line from the current dispatch run.

### Step 3: Reallocate Physical Quantities

- Access `fulfillment_orders` using `[fulfillment_order_code]`.
- Recalculate remaining physical inventory by accumulating existing balance with restored quantities.
- Update `actual_quantity` and `actual_package_count`.
- Wrap modification steps inside an explicit transaction (`START TRANSACTION` and `COMMIT`).

---

## 🛠 Complete SQL Execution Script

```sql
-- ==============================================================================
-- STEP 1: INITIAL DATA INSPECTION
-- Inspect shipment schedules, item mappings, and assigned fulfillment lines.
-- ==============================================================================
SELECT * 
FROM dispatch_item_mappings 
WHERE dispatch_schedule_id = [schedule_id];

SELECT * 
FROM shipment_schedules 
WHERE schedule_id = [schedule_id];

SELECT * 
FROM dispatch_item_pickups 
WHERE schedule_id = [schedule_id];

-- ==============================================================================
-- STEP 2: UNLINK ASSIGNMENT / RESET PICKUP STATUS
-- Reset status to 0 (Unbound / Available for future dispatch)
-- ==============================================================================
START TRANSACTION;

UPDATE dispatch_item_pickups
SET `status` = 0
WHERE fulfillment_order_id = [fulfillment_order_id];

COMMIT;

-- ==============================================================================
-- STEP 3: INSPECTION & QUANTITY REALLOCATION
-- Restore cancelled quantities back to the main fulfillment record.
-- ==============================================================================

-- 3a. Inspect current fulfillment order state
SELECT * 
FROM fulfillment_orders 
WHERE fulfillment_order_code = '[fulfillment_order_code]';

-- 3b. Reallocate actual quantities and package counts
START TRANSACTION;

-- Restore total item quantity (Remaining Qty + Cancelled Qty)
UPDATE fulfillment_orders
SET actual_quantity = [remaining_qty + cancelled_qty]
WHERE fulfillment_order_code = '[fulfillment_order_code]';

-- Restore total package/unit count (Remaining Package Count + Cancelled Package Count)
UPDATE fulfillment_orders
SET actual_package_count = [remaining_packages + cancelled_packages]
WHERE fulfillment_order_code = '[fulfillment_order_code]';

COMMIT;
```
