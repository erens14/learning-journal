# QA Engineering Notes

This folder contains QA lessons learned from workflow testing, regression checks, business-rule validation, data integrity issues, and user-facing defects.

## Best Starting Points

| Note | Recruiter signal |
| --- | --- |
| [Verifying sorting functionality](verifying-sorting-functionality.md) | Tests reporting behavior across sorting, filtering, pagination, and export expectations. |
| [Requirement gathering reveals more than bugs](requirement-gathering-reveals-more-than-bugs.md) | Shows ability to connect QA work with requirement clarity. |
| [Validation consistency between create and edit](validation-consistency-between-create-and-edit.md) | Shows regression thinking across similar workflows. |
| [Verifying cross-module data synchronization](verifying-cross-module-data-synchronization.md) | Shows integration testing and data-flow awareness. |
| [Multi-tier approval and automated ledger posting](multi-tier-approval-and-automated-ledger-posting.md) | Shows business-process testing and accounting workflow awareness. |

## Test Case Portfolio

See [test-cases](test-cases/) for structured execution matrices, including:

- [Financial journal integrity](test-cases/financial-journal-integrity-test-cases.md)
- [Authentication, registration, logout security](test-cases/auth-registration-logout-security-test-cases.md)
- [RBAC authorization and relational data integrity](test-cases/rbac-consignment-integrity-test-cases.md)
- [Master data lifecycle](test-cases/master-data-test-cases.md)

## Common Themes

- Regression testing after bug fixes and deployments.
- Edge-case validation for data, permissions, and UI behavior.
- User impact, system impact, data impact, and business impact analysis.
- Cross-module testing where one workflow depends on another module.
