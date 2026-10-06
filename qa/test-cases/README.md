# QA Test Cases

This folder contains structured test-case matrices for feature workflows, authorization, financial integrity, redirects, master data, and cash approval processes.

## Reading the Results

Each matrix includes activity, evidence basis, and result scope. PASS and FAIL describe recorded checks, not current application behavior or a new execution. Execution dates were not collected for these records; unknown dates, build identifiers, and tester details are omitted. NOT RUN and design-only cases are planned coverage.

Original application screenshots and confidential artifacts are excluded under NDA. Public evidence uses written observations, existing test IDs, and explicitly labeled reconstructions. See the [NDA-safe evidence standard](../../portfolio-standards.md#nda-safe-portfolio-evidence).

For mixed initial and retest results, read the document's status history or execution notes. The [financial journal matrix](financial-journal-integrity-test-cases.md#status-history) preserves the original failure separately from its related retest. UI-only checks do not establish server-side authorization.

## Contents

| Test case set | Focus |
| --- | --- |
| [Authentication, registration, logout security](auth-registration-logout-security-test-cases.md) | Session, identity, and basic account security workflows. |
| [BKK cash feature](bkk-cash-feature-test-cases.md) | Cash outflow approval and GL integration checks. |
| [Bon Sangu redirect routing](bon-sangu-redirect-routing-test-cases.md) | Post-save redirect and route precision. |
| [Financial journal integrity](financial-journal-integrity-test-cases.md) | Double-entry accounting and journal correctness. |
| [Master data lifecycle](master-data-test-cases.md) | Create, read, update, delete, and validation flow. |
| [Overpaid deletion journal integrity](overpaid-deletion-journal-integrity-test-cases.md) | Reversal logic and financial consistency. |
| [Receivable overpayment journal and balance synchronization](receivable-overpayment-journal-and-balance-synchronization-test-cases.md) | Bank-entry uniqueness, overpaid allocation, remaining balance, and PPh consistency. |
| [RBAC consignment integrity](rbac-consignment-integrity-test-cases.md) | Role permissions and relational data integrity. |
| [SPS Report Initial Totals](sps-report-initial-totals-test-cases.md) | Initial totals in SPS connected reports issues. |
| [Side navigation to top navigation](side-nav-to-top-nav-test-cases.md) | Navigation, authorization, responsive layout, accessibility, and route regression checks. |
