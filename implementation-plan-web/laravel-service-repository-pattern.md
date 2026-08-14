# 📓 Lessons Learned: Standardizing Laravel Master Modules via Service-Repository Pattern

**Topic :** Software Architecture, Codebase Standardization & Refactoring  
**Context :** Standardizing and refactoring the **Master Vehicle Module** to align with enterprise architectural standards used across other master entities (Driver, Vehicle Category, Bank, Customer).

## 💡 Executive Summary

The primary takeaway from this implementation is the necessity of **architectural consistency** across enterprise applications. By establishing a strict **Separation of Concerns** between Controller, Service, Repository, and Model layers, the codebase becomes significantly more maintainable, testable, and resilient against data corruption.

## 🏗️ Architectural Layer Breakdown

### 1. Model Layer (Data Definition & Casting)

* **Custom Conventions:** Explicitly declare `$table`, `$primaryKey`, and custom `$timestamps` (`created` & `updated`) when working with legacy or custom database schemas.
* **Type Safety via Casting:** Always utilize `$casts` for numeric values (`liter_muat`, `liter_kosong`) and `status` flags to ensure strict return types from Eloquent and prevent type-coercion bugs.
* **Explicit Relationships:** Explicitly define `belongsTo` relations (`VehicleCategory` & `Driver`) to enable seamless eager loading.

### 2. Repository Layer (Data Access Isolation)

* **Single Responsibility:** Restrict Repositories strictly to data retrieval and persistence, keeping them free from business rules.
* **Preventing N+1 Queries:** Always enforce eager loading (`with(['category', 'driver'])`) in base queries such as `getDataTablesQuery()` or `findById()`.
* **Reusability:** Encapsulate common query logic (e.g., `searchByNopol()`) into dedicated methods to eliminate code duplication across different entry points.
* **Soft Delete Abstraction:** Standardize data deletion states (e.g., `status = 0` for soft deletes, `status = 1` for active records) within the repository to ensure consistent lifecycle management.

### 3. Service Layer (Business Logic & Orchestration)

* **Atomic DB Transactions:** Wrap all mutation operations (`store`, `update`, `delete`, `restore`) inside `DB::transaction()` blocks to maintain data integrity if an execution fails midway.
* **Automated Audit Logging:** Handle metadata auto-filling (`createdby`, `updatedby`) and normalize empty string inputs to `null` before persistence.
* **Data Presentation Formatting:** Process Yajra DataTables integration at the Service level to format output data (mapping relation names, action buttons, and numeric values) before passing it to the UI.

### 4. Controller Layer (Thin Controllers)

* **Dependency Injection:** Inject `VehicleService` via the controller constructor.
* **Delegation:** Keep controllers lean—their sole responsibility is accepting HTTP Requests, invoking the Service layer, and returning JSON or View responses.

### 5. View Layer (Component-Driven UI)

* **Blade Components:** Leverage reusable UI components (`components.buttons.button-show`, `button-basic-edit`) to maintain visual and functional consistency across modules.
* **User Experience (UX):**
  * Implement **AJAX submissions** with loading indicators for responsive, seamless form handling without page reloads.
  * Integrate **SweetAlert2** modals for destructive action confirmations (Delete/Restore).
* **Document Generation:** Isolate print templates (`pdf.blade.php`) with styling tailored specifically for DomPDF rendering.

## 🛡️ Pitfalls Avoided & Solutions Applied

| Problem / Potential Issue | Applied Architectural Solution |
| :--- | :--- |
| **N+1 Query Bottleneck** on listing pages | Implemented explicit eager loading (`with()`) in the Repository query layer. |
| **Data Inconsistency** on partial database writes | Enclosed all multi-step mutation methods within `DB::transaction()`. |
| **Duplicate DataTables Code** across controllers | Centralized Yajra DataTables configuration within `VehicleService`. |
| **Accidental Soft Delete Bypass** | Restricted default search methods to records with `status = 1`. |

## 🧪 Verification & Quality Control

* **Static Analysis & Linting:** Run PHP Linter to verify zero syntax errors, type mismatches, or unimported namespaces.
* **CRUD Lifecycle Testing:** Verify Create, Read, Update, Soft Delete, and Restore operations via DataTables AJAX.
* **Document Export Validation:** Confirm DomPDF output renders layout and tables accurately.
