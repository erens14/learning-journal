# QA Engineering Notes

This folder contains sanitized QA lessons from workflow testing, regression checks, data-integrity validation, integrations, and user-facing defects.

## Featured Evidence

| Note | What it demonstrates |
| --- | --- |
| [Verifying sorting functionality](verifying-sorting-functionality.md) | Reporting validation across sorting, filters, pagination, exports, and data visibility. |
| [Requirement gathering reveals more than bugs](requirement-gathering-reveals-more-than-bugs.md) | Requirement analysis as part of quality assurance. |
| [Validation consistency between create and edit](validation-consistency-between-create-and-edit.md) | Regression coverage across related workflows. |
| [Verifying cross-module data synchronization](verifying-cross-module-data-synchronization.md) | End-to-end data availability across dependent modules. |
| [Multi-tier approval and automated ledger posting](multi-tier-approval-and-automated-ledger-posting.md) | Business-process and accounting-workflow testing. |

## Test Case Portfolio

Browse the complete [test-case portfolio](test-cases/README.md) for execution matrices. Recommended examples:

- [Financial journal integrity](test-cases/financial-journal-integrity-test-cases.md)
- [Receivable overpayment journal and balance synchronization](test-cases/receivable-overpayment-journal-and-balance-synchronization-test-cases.md)
- [Authentication, registration, and logout security](test-cases/auth-registration-logout-security-test-cases.md)
- [RBAC authorization and relational data integrity](test-cases/rbac-consignment-integrity-test-cases.md)
- [Master data lifecycle](test-cases/master-data-test-cases.md)

## Lesson Library

Every lesson appears once under its primary topic.

### Business Rules and Regression

| Note | Focus |
| --- | --- |
| [Balancing business-rule enforcement and regression testing](balancing-business-rule-enforcement-and-regression-testing.md) | Preserving required controls during feature changes. |
| [Business-rule regression causing unrestricted data editing](business-rule-regression-causing-unrestricted-data-editing.md) | Detecting permission and edit-control regressions. |
| [Form design and save behavior consistency](form-design-and-save-behavior-consistency.md) | Aligning input behavior with persistence outcomes. |
| [Multi-tier approval and automated ledger posting](multi-tier-approval-and-automated-ledger-posting.md) | Approval states, posting rules, and workflow coverage. |
| [Requirement gathering reveals more than bugs](requirement-gathering-reveals-more-than-bugs.md) | Turning requirement gaps into testable expectations. |
| [Retesting and regression validation](retesting-and-regression-validation.md) | Confirming fixes without breaking surrounding behavior. |
| [Validation consistency between create and edit](validation-consistency-between-create-and-edit.md) | Matching validation rules across related forms. |
| [Verifying business rules and data locking](verifying-business-rules-and-data-locking.md) | State-based controls and prohibited changes. |
| [Verifying feature availability beyond menu accessibility](verifying-feature-availability-beyond-menu-accessibility.md) | Verifying usable access beyond navigation visibility. |
| [Verifying UI changes and regression after deployment](verifying-ui-changes-and-regression-after-deployment.md) | Post-deployment visual and workflow validation. |

### Data Integrity and Financial Workflows

| Note | Focus |
| --- | --- |
| [Cumulative rounding discrepancies in partial-payment calculations](cumulative-rounding-discrepancies-in-partial-payment-remain-calculation.md) | Precision and settlement balance validation. |
| [Data label and transaction-state inconsistency](data-label-and-overpaid-transaction-inconsistency.md) | Consistent labels and transaction states. |
| [Master-data dependency and soft-delete validation](master-data-dependency-and-soft-delete-validation.md) | Linked-record safety and lifecycle controls. |
| [Out-of-sync status between stock issue and stockcard](out-of-sync-status-between-stock-issue-and-stockcard.md) | Cross-module inventory-state consistency. |
| [Soft-deletion filtering in multi-entity reporting queries](soft-deletion-filtering-in-multi-entity-reporting-queries.md) | Preventing inactive records from appearing in reports. |
| [Tax deduction toggle and credit allocation engine](tax-deduction-toggle-and-credit-allocation-engine.md) | Tax, allocation, and multi-invoice integrity. |
| [Unhandled tax journaling and missing overpayment entity creation](unhandled-tax-journaling-and-overpayment-entity-creation.md) | Financial posting and missing-entity detection. |
| [Receivable overpayment journal and balance synchronization](receivable-overpayment-journal-and-balance-synchronization.md) | Bank-entry uniqueness, overpaid classification, remaining balance, and PPh consistency. |
| [Verifying related transaction visibility](verifying-related-transaction-visibility.md) | Visibility of linked financial records. |

### Reporting, Interface, and Validation

| Note | Focus |
| --- | --- |
| [Data parsing and mapping failure on bulk-file import](data-parsing-and-mapping-failure-on-bulk-file-import.md) | File-import validation and field mapping. |
| [Export failures and filter-isolation faults in reporting modules](export-failures-and-filter-isolation-faults-in-reporting-modules.md) | Export reliability and filter boundaries. |
| [Post-save redirect routing and entity-ID misassignment](post-save-redirect-routing-and-id-misassignment.md) | Redirect correctness and record identity. |
| [Report testing beyond data display](report-testing-beyond-data-display.md) | Report logic beyond visible rows. |
| [EventSource MIME mismatch and export performance bottlenecks](unhandled-eventsource-mime-type-mismatch-and-export-latency.md) | Real-time updates and large-export behavior. |
| [Unhandled text-input-length validation](unhandled-text-input-length-validation.md) | Cross-layer boundary validation. |
| [Unresponsive UI grid components](unresponsive-ui-grid-components.md) | Event handling and grid interaction. |
| [Verifying sorting functionality](verifying-sorting-functionality.md) | Sorting, filters, pagination, and exports. |

### Integrations and Access Control

| Note | Focus |
| --- | --- |
| [Monthly form routing with dynamic formulas and formatting](google-sheets-automation.md) | Google Forms, Sheets, formulas, and localization. |
| [Robust Discord webhooks in Google Apps Script](implementing-robust-discord-webhooks-in-google-apps-script.md) | Trigger behavior, input handling, and external notification reliability. |
| [Testing transaction references and role-based authorization](testing-transaction-references-and-role-based-authorization.md) | Relational references and permission boundaries. |
| [Verifying cross-module data synchronization](verifying-cross-module-data-synchronization.md) | Data propagation and dependent-module availability. |
