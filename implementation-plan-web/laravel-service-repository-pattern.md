# PRD: Standardize a Laravel Master Module with the Service-Repository Pattern

> **Portfolio sanitization notice:** Entity names, class names, database fields, routes, and business identifiers are generalized. No production records, internal URLs, or confidential schema details are included.

## Problem

A legacy master-data module mixed HTTP handling, business rules, data access, table formatting, and persistence behavior. This increased duplication, allowed inconsistent soft-delete handling, created partial-write risk, and made related-record loading vulnerable to N+1 queries.

The module needed to follow the same layered architecture used by comparable master-data features without changing its public behavior.

## Goal

- Separate HTTP, business, and data-access responsibilities.
- Keep controllers thin and move workflow orchestration into a service.
- Isolate queries and persistence in a repository.
- Protect multi-step mutations with database transactions.
- Preserve CRUD, soft-delete, restore, table listing, and document-export behavior.
- Reuse shared interface components and existing authorization rules.

## Target Users

- Operational users maintaining master records
- Administrators restoring inactive records
- Developers maintaining Laravel master-data modules

## Functional Requirements

- Authorized users can create, view, update, soft-delete, and restore a master record.
- Listing and detail views display related category and assigned-party information without missing labels.
- Default active-record searches exclude soft-deleted records.
- Restore operations return an inactive record to the active dataset.
- Empty optional inputs are stored as `null` according to the existing data contract.
- Create and update operations populate the existing audit metadata from the authenticated session.
- Table responses contain formatted relation labels, numerical values, and permitted action controls.
- Destructive actions require user confirmation through the existing interface pattern.
- The existing printable document remains available with its expected data and layout.

## Technical Rules

- The model explicitly defines legacy table, primary-key, timestamp, casting, and relationship conventions.
- The repository contains only retrieval and persistence logic.
- Repository queries eager-load required relationships and centralize reusable searches.
- The service owns business rules, input normalization, table-response formatting, and workflow orchestration.
- Create, update, soft-delete, and restore operations execute inside database transactions.
- The controller receives the service through dependency injection and only coordinates requests and responses.
- Views reuse shared buttons, confirmation dialogs, and loading-state components.
- Printable-document styling remains isolated from interactive page templates.
- Existing routes, request contracts, permissions, and database schemas remain unchanged.

## Acceptance Criteria

- Authorized users can complete the full create, read, update, soft-delete, and restore lifecycle.
- A failed multi-step mutation rolls back every write and leaves no partial record state.
- Listing and detail pages display required related labels without per-row lazy-loading queries.
- Soft-deleted records are absent from the default active list and return after restore.
- Optional blank inputs persist as `null` where defined by the existing data contract.
- Audit metadata reflects the authenticated user after create and update operations.
- Table responses preserve existing columns, formatting, and authorized action controls.
- Controllers delegate business and persistence operations to the service.
- Repository methods contain no presentation formatting or workflow decisions.
- PHP syntax validation, CRUD regression tests, and printable-document rendering complete without errors.

## Out of Scope

- Refactoring every master-data module in the application
- Database schema or route changes
- Replacement of soft delete with permanent deletion
- Authentication or authorization redesign
- Introduction of a new frontend framework
- Redesign of the printable document beyond compatibility fixes
