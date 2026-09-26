# PRD: Centralize Laravel Audit Trail and Production Validation

> **Portfolio sanitization notice:** Model names, table names, routes, schema fields, and business-module identifiers are generalized. No production data, credentials, or internal URLs are included.

## Problem

A legacy Laravel application recorded audit actors inconsistently. Models did not share one reliable audit lifecycle, some authenticated writes used the wrong user attribute, and direct bulk updates bypassed model events.

These gaps could store a system fallback instead of the authenticated user, omit update actors, or create different audit behavior across modules. Unit tests alone did not prove that a real authorized request persisted the correct actor in the database.

## Goal

- Centralize audit ownership in a reusable model lifecycle.
- Record the authenticated user's canonical login identifier during supported create and update operations.
- Preserve a fixed system actor for jobs and unauthenticated processes.
- Prevent request input from controlling audit fields.
- Preserve schema-specific behavior for models that cannot use the common contract directly.
- Require authenticated route and database validation before declaring production readiness.

## Target Users

- Application users whose changes require traceability
- Administrators and auditors reviewing record history
- Developers maintaining Laravel models and write paths

## Functional Requirements

- Creating a compatible record stores both creation and update actors from the authenticated session.
- Updating a compatible record preserves the creation actor and refreshes only the update actor.
- Background or guest-context writes use a fixed non-null system actor.
- Client input cannot override creation or update actor fields.
- Compatible models inherit the shared audit lifecycle through the common base model.
- A schema-specific ledger model uses mapped audit fields without changing its existing timestamp behavior.
- Audited update paths persist through lifecycle-aware model operations so model events execute.
- Models without compatible audit fields remain excluded until their schemas are handled separately.
- Unauthorized write attempts do not change business data or audit fields.

## Technical Rules

- Implement audit callbacks through a reusable trait owned by the shared base model.
- Derive audit identity server-side from the authenticated session's canonical login identifier.
- Use a fixed system actor only when no authenticated identity exists.
- Do not use direct query-builder bulk updates for writes that require per-record audit events.
- Preserve custom timestamp and field mappings for schema-specific models.
- Migrate only models whose tables satisfy the shared audit-field contract.
- Keep unrelated schema mismatches, route defects, and incompatible models in separately scoped remediation work.
- Require database assertions in addition to HTTP success messages or redirects.
- Repository changes must pass whitespace validation.

## Acceptance Criteria

- An authenticated create stores the current user's canonical identifier in both audit-actor fields.
- An authenticated update preserves the creation actor and changes the update actor to the current user.
- A background or guest write stores the fixed system actor.
- Submitted audit-field values are ignored or rejected according to the existing validation policy.
- The specialized ledger model writes its mapped audit fields while preserving native timestamp behavior.
- Audited write paths execute model events and persist both the business change and correct audit actor.
- An unauthorized user receives the existing denial response and causes no database mutation.
- The focused audit suite covers create, update, shared inheritance, mapped fields, and system fallback with nine passing tests.
- Production validation remains incomplete until one representative authenticated create-and-edit flow verifies persisted audit fields in the database.

## Out of Scope

- Database migrations for incompatible legacy models
- Repair of unrelated table or model mismatches
- Repair of unrelated route naming defects
- Audit-history user interface redesign
- Replacement of the authentication system
- Automatic auditing for intentionally non-model bulk operations
