# Nathan Erens Anderson — Cybersecurity Portfolio and Learning Journal

I am transitioning from quality assurance into an entry-level cybersecurity role. My QA work provides a foundation in access-control checks, investigation, data integrity, and clear evidence reporting. This portfolio combines sanitized examples of that work with cybersecurity reading and networking study.

**Target role:** Entry-level cybersecurity

**Current foundation:** QA testing, business-workflow analysis, and security-focused self-study

**Profile:** [GitHub](https://github.com/erens14) · LinkedIn: [Add public profile URL] · Résumé: [Add public résumé link] · Professional email: [Add contact email]

## Start Here

These three case studies show skills I bring from QA into cybersecurity. Each identifies my contribution, the available evidence, and what still needs verification.

1. **[Access-control boundaries and data integrity](qa/access-control-boundaries-and-data-integrity.md)** — Compared edit permissions between roles and documented a linked-record modification failure. Three recorded checks passed; one failed. Direct-request authorization remains unverified.
2. **[Investigating a failed report stream](qa/unhandled-eventsource-mime-type-mismatch-and-export-latency.md)** — Used browser Network and Console observations to distinguish a rejected event stream from a slow export. Findings are documented; the authentication root cause and a successful retest remain unconfirmed.
3. **[Receivable overpayment investigation and retest](qa/receivable-overpayment-journal-and-balance-synchronization.md)** — Checked a payment across journal entries, balances, and tax values. Six scenarios passed retesting; two additional regression scenarios remain unexecuted.

These are QA case studies with transferable security skills. They do not represent SOC investigations or penetration-testing engagements.

## Professional Profile

| Focus | Evidence and scope |
| --- | --- |
| Access-control testing | Documented authentication, role-based UI checks, and selected restricted-route scenarios. Coverage is limited to the recorded steps. |
| Investigation and reporting | Expected-versus-observed comparisons, browser diagnostics, defect documentation, and scoped retesting. |
| Data integrity | Financial consistency checks, linked-record safeguards, and generalized transaction-safety patterns. |
| Security and networking study | Source-based security summaries and CCNA notes covering addressing, routing, and troubleshooting. |

See [skills and tools](skills-and-tools.md) for the distinction between applied QA evidence and study material.

## Cybersecurity Learning

- [Phishing-resistant authentication](article-summary/2026-06-27-phishing-resistant-authentication.md): source-based study of identity protection.
- [Cybersecurity article and video summaries](article-summary/README.md): security concepts, attack-chain summaries, and personal analysis.
- [CCNA networking notes](ccna-udemy-notes/README.md): networking foundations that support security learning; these notes do not claim certification.

## Featured Project

[Automated expense tracker](projects/README.md#automated-expense-tracker) documents a Google Forms, Sheets, Apps Script, and Discord-notification automation project, including reliability risks found during QA review.

## Portfolio Evidence

| Area | What it demonstrates | Start point |
| --- | --- | --- |
| QA engineering | Workflow, business-rule, reporting, deployment, and regression validation. | [QA notes](qa/README.md) |
| Test design | Executable test matrices for financial integrity, authentication, RBAC, and master data. | [Test-case portfolio](qa/test-cases/README.md) |
| Database integrity | Transaction-safe SQL maintenance and linked-record consistency. | [Database patterns](request-entry-db/README.md) |
| Security study | Source-based attack-chain summaries and personal reflections on QA controls. | [Cybersecurity summaries](article-summary/README.md) |
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
| [article-summary](article-summary/README.md) | Source-based security study and personal analysis. |
| [ccna-udemy-notes](ccna-udemy-notes/README.md) | Networking study notes. |
| [laravel](laravel/README.md) | Laravel learning progression. |
| [implementation-plan-web](implementation-plan-web/README.md) | Implementation and architecture lessons. |

## Disclaimer

Personal portfolio and learning journal. Notes reflect understanding at time of writing and may be updated as knowledge grows.
