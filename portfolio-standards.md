# Portfolio Documentation Standards

## Purpose

Keep portfolio pages recruiter-readable, technically credible, and safe to publish.

## New Portfolio Notes

Use this order:

1. Context and user/business risk.
2. Scope and test approach.
3. Observed behavior and verified outcome.
4. Evidence links to test cases, issue-safe notes, repository, or demo.
5. Learning and next validation step.

Separate observation, hypothesis, and verified root cause. Do not state an implementation fix was made unless evidence supports it.

## Evidence and Sources

- Link every portfolio claim to local supporting evidence or a public repository/demo.
- Security summaries name the source, URL, and publication date when known.
- Clearly label personal analysis; do not present it as a sourced fact.
- Prefer exact test IDs, expected results, and observed outcomes over generic claims.

## Confidentiality

- Remove company names, customer data, credentials, tokens, internal URLs, ticket IDs, and production identifiers.
- Generalize values and schemas when the original detail is sensitive.
- Do not publish SQL that can modify a real environment without placeholders and a safety warning.

## Style

- New portfolio pages use direct professional headings without decorative emoji.
- Lead with result and risk; avoid diary-style chronology unless it clarifies a decision.
- Keep long technical study notes in their existing locations; surface the strongest work through root and QA indexes instead of duplicating it.

## Before Publishing

Run local-link validation:

```powershell
powershell -ExecutionPolicy Bypass -NoProfile -File scripts/validate-markdown-links.ps1
```

Confirm every external link, contact detail, project description, and capability claim remains current.
