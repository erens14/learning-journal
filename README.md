# Learning Journal: QA, Security, Networking

This repository is my public learning portfolio for QA engineering, regression testing, database integrity, cybersecurity analysis, Laravel fundamentals, and CCNA networking foundations.

It is organized as a working knowledge base: each note turns a real testing scenario, technical article, course topic, or implementation pattern into structured takeaways that can be reviewed later.

## Recruiter Quick Scan

Start here if you want a fast view of my practical thinking:

| Area | Why it matters | Sample notes |
| --- | --- | --- |
| QA engineering | Shows how I test workflows, edge cases, regressions, and business rules. | [Sorting workflow validation](qa/verifying-sorting-functionality.md), [financial journal integrity test cases](qa/test-cases/financial-journal-integrity-test-cases.md) |
| Data integrity | Shows care with SQL changes, transaction safety, and parent-child data consistency. | [Cascading quantity update pattern](request-entry-db/sql-cascading-quantity-update-pattern.md), [transaction rollback pattern](request-entry-db/sql-transaction-rollback-pattern.md) |
| Cybersecurity analysis | Shows security awareness and ability to summarize attack chains clearly. | [Morris Worm case study](article-summary/2026-08-18-morris-worm-failed-experiment-broke-internet.md), [phishing-resistant authentication](article-summary/2026-06-27-phishing-resistant-authentication.md) |
| Networking fundamentals | Shows structured CCNA study and technical foundation building. | [Network fundamentals](ccna-udemy-notes/01-network-fundamentals/01-network-fundamentals.md), [subnetting notes](ccna-udemy-notes/06-subnetting/README.md) |
| Laravel learning | Shows web development fundamentals and backend learning progression. | [Laravel installation](laravel/01-install.md), [Laravel CRUD app](laravel/10-crud-app.md) |

## Repository Map

| Folder | Focus |
| --- | --- |
| [qa](qa/README.md) | QA lessons learned, regression risks, workflow validation, and test cases. |
| [request-entry-db](request-entry-db/README.md) | SQL data correction patterns and transaction-safe database updates. |
| [article-summary](article-summary/README.md) | Cybersecurity article and video summaries with personal reflections. |
| [ccna-udemy-notes](ccna-udemy-notes/README.md) | CCNA networking notes organized by topic. |
| [laravel](laravel/README.md) | Laravel learning notes from setup through CRUD and Docker. |
| [implementation-plan-web](implementation-plan-web/README.md) | Web implementation lessons from UI, architecture, and refactoring work. |
| [templates](templates/README.md) | Reusable note templates that keep documentation consistent. |
| [glossary.md](glossary.md) | CCNA terminology reference. |

## Learning Areas

![Quality Assurance](https://img.shields.io/badge/Focus-Quality_Assurance-blue?style=flat-square)
![Cyber Security](https://img.shields.io/badge/Focus-Cyber_Security-red?style=flat-square)
![Computer Networking](https://img.shields.io/badge/Focus-Computer_Networking-green?style=flat-square)
![Laravel](https://img.shields.io/badge/Focus-Laravel-orange?style=flat-square)

## What This Shows

- Ability to break down bugs into user impact, system impact, data impact, and business impact.
- Habit of validating workflows beyond the happy path.
- Awareness of database consistency, rollback safety, and cross-module dependencies.
- Interest in cybersecurity, threat behavior, identity, and secure system design.
- Ongoing technical growth through networking and web development fundamentals.

## Naming Convention

File names use lowercase letters and hyphens for readable GitHub URLs:

```text
verifying-sorting-functionality.md
requirement-gathering-reveals-more-than-bugs.md
phishing-resistant-authentication.md
```

When multiple sources cover the same foundational topic, the source name may be appended:

```text
phishing-resistant-authentication-nist.md
phishing-resistant-authentication-microsoft.md
```

## Learning Philosophy

> "Learning becomes valuable when knowledge is transformed into understanding."

Every note reflects my understanding at the time of writing. Older notes may be updated, corrected, or expanded as my experience grows.

## Disclaimer

This repository is a personal, non-exhaustive learning journal for educational use. Notes are written in generalized terms and avoid confidential project details.
