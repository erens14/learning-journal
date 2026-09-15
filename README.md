# QA Engineering Portfolio and Learning Journal

QA-focused portfolio demonstrating test design, regression thinking, data-integrity validation, and security-aware quality practices. Content is based on sanitized, generalized scenarios; it contains no confidential project data.

## Start Here

Read these QA evidence documents first:

1. [Financial journal integrity test cases](qa/test-cases/financial-journal-integrity-test-cases.md) — double-entry accuracy, tax synchronization, and rounding-risk regression testing.
2. [Cross-module data synchronization](qa/verifying-cross-module-data-synchronization.md) — end-to-end workflow validation beyond successful record creation.
3. [RBAC authorization and relational data integrity](qa/test-cases/rbac-consignment-integrity-test-cases.md) — authorization boundaries and relational-data safeguards.

## Professional Profile

| Focus | Evidence |
| --- | --- |
| QA engineering | Functional, integration, regression, negative, and precision testing of business workflows. |
| Data integrity | SQL-safe correction patterns, transaction safety, and parent-child consistency checks. |
| Security-aware QA | Authentication, role-based access, input validation, and attack-chain analysis. |
| Technical foundation | Laravel fundamentals, Google Apps Script reliability testing, and CCNA networking study. |

See [skills and tools](skills-and-tools.md) for an evidence-based capability matrix. Connect through [GitHub](https://github.com/erens14).

## Featured Project

[Automated expense tracker](projects/README.md#automated-expense-tracker) documents a Google Forms, Sheets, Apps Script, and Discord-notification automation project, including reliability risks found during QA review.

## Portfolio Evidence

| Area | What it demonstrates | Start point |
| --- | --- | --- |
| QA engineering | Workflow, business-rule, reporting, deployment, and regression validation. | [QA notes](qa/README.md) |
| Test design | Executable test matrices for financial integrity, authentication, RBAC, and master data. | [Test-case portfolio](qa/test-cases/README.md) |
| Database integrity | Transaction-safe SQL maintenance and linked-record consistency. | [Database patterns](request-entry-db/README.md) |
| Security analysis | Attack-chain analysis linked to practical QA controls. | [Cybersecurity summaries](article-summary/README.md) |
| Implementation thinking | Maintainability, architecture, UI, and verification tradeoffs. | [Web implementation lessons](implementation-plan-web/README.md) |

## Study Library

The following sections support the portfolio but are primarily learning records:

- [CCNA networking notes](ccna-udemy-notes/README.md)
- [Laravel learning notes](laravel/README.md)
- [Templates](templates/README.md)
- [Glossary](glossary.md)

## Quality and Documentation Standards

- New portfolio notes follow [portfolio standards](portfolio-standards.md): context, risk, approach, evidence, outcome, and learning.
- Security summaries identify their source and publication date when known; analysis is separated from source facts.
- Public material is sanitized. Names, IDs, values, schemas, and internal references are generalized or removed.
- Local Markdown links are verified with `powershell -ExecutionPolicy Bypass -NoProfile -File scripts/validate-markdown-links.ps1`.

## Repository Map

| Folder | Purpose |
| --- | --- |
| [projects](projects/README.md) | Shipped or externally hosted implementation work. |
| [qa](qa/README.md) | Detailed QA lessons and test cases. |
| [request-entry-db](request-entry-db/README.md) | Data-maintenance and transaction-safety patterns. |
| [article-summary](article-summary/README.md) | Security research and personal analysis. |
| [ccna-udemy-notes](ccna-udemy-notes/README.md) | Networking study notes. |
| [laravel](laravel/README.md) | Laravel learning progression. |
| [implementation-plan-web](implementation-plan-web/README.md) | Implementation and architecture lessons. |

## Disclaimer

Personal portfolio and learning journal. Notes reflect understanding at time of writing and may be updated as knowledge grows.
