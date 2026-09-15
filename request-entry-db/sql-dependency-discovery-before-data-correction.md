# 📝 Learning Note: Dependency Discovery Before Data Correction

**Goal:** Identify every table and record that depends on a target entity before planning a manual correction.

**Core Principle:** **Map first, mutate later.** A valid row-level change can still break a workflow when a related table, summary, journal, or status is missed.

**Business Workflow Chain:** `Target Record` → `Direct Foreign Keys` → `Dependent Transactions` → `Summary / Reporting State`.

---

## 📌 Context & Domain Parameters

| Parameter | Placeholder | Purpose |
| --- | --- | --- |
| Schema | `[schema_name]` | Database being inspected |
| Parent table | `[parent_table]` | Table containing the target record |
| Parent key | `[parent_key]` | Referenced primary or unique key |
| Target ID | `[target_id]` | Fictional record used for impact analysis |

---

## 🔍 Discovery Workflow

1. Confirm target table structure and candidate key.
2. Query metadata for foreign keys referencing the parent table.
3. Inspect affected rows in every dependent table using the target ID.
4. Identify derived totals, statuses, journals, and reports not enforced by foreign keys.
5. Record expected relationships and row counts before designing an update.

---

## 🛠 Generalized SQL Pattern

```sql
-- 1. Inspect table structure without returning business data.
DESCRIBE [parent_table];

-- 2. Find declared foreign-key dependencies in MySQL.
SELECT
    TABLE_NAME AS dependent_table,
    COLUMN_NAME AS dependent_column,
    REFERENCED_TABLE_NAME AS parent_table,
    REFERENCED_COLUMN_NAME AS parent_column
FROM information_schema.KEY_COLUMN_USAGE
WHERE TABLE_SCHEMA = '[schema_name]'
  AND REFERENCED_TABLE_NAME = '[parent_table]'
  AND REFERENCED_COLUMN_NAME = '[parent_key]'
ORDER BY TABLE_NAME, COLUMN_NAME;

-- 3. Inspect only fields needed to verify the target relationship.
SELECT child_id, parent_id, status
FROM [dependent_table]
WHERE parent_id = [target_id];

-- 4. Count affected records before preparing any write.
SELECT COUNT(*) AS dependent_record_count
FROM [dependent_table]
WHERE parent_id = [target_id];
```

---

## ✅ Verification Checklist

- Foreign-key results are supplemented with application-level relationships.
- Each dependent table has an expected row count and current-state snapshot.
- Reporting, journal, audit, and cached-summary effects are documented.
- No update begins until the complete dependency map is reviewed.

---

## 🧠 Lesson Learned

Database metadata reveals declared relationships, not every business dependency. Safe correction planning combines foreign-key discovery with targeted record inspection and workflow knowledge.
