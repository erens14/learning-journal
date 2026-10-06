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

## Featured Case Studies

Start with a short summary of the problem, personal contribution, approach, recorded outcome, security relevance, and evidence link. Separate testing and documentation from implementation ownership. Explain which skills transfer to cybersecurity without relabeling QA defects as security incidents.

## Execution Context and Status History

- Every QA note and test matrix includes a compact execution context: activity, evidence basis, and result scope. Include an environment only when it is documented and safe to disclose; distinguish planned conditions from actual execution.
- Execution dates were not collected for the existing QA records. Dates, build identifiers, and tester details are optional supporting metadata, not required portfolio fields. Omit unknown fields instead of repeating empty values or `Not recorded` rows.
- Do not infer execution dates from commits, document edits, or fictional transaction dates. Use `initial finding` and `confirmed retest` to describe a supported sequence without inventing timestamps.
- Identify whether evidence is a historical execution note, explicit tester confirmation, fictional reconstruction, or unexecuted test design.
- Preserve original FAIL results. Record a confirmed retest separately and link it to the original finding; do not overwrite history or imply unrelated failures were fixed.
- PASS applies only to the recorded steps and observations. A UI restriction does not prove direct-request authorization; an expected result alone is not execution evidence.
- Keep proposed checks NOT RUN unless execution is confirmed. For older design-only matrices without status columns, state explicitly that no execution result is recorded.
- Never invent build labels, dates, tester identities, improvement percentages, or successful fixes. Public reconstruction demonstrates reasoning; it is not a newly executed test.

## NDA-Safe Portfolio Evidence

Original application screenshots and confidential development artifacts are excluded from this portfolio. A screenshot is not required for a useful QA case study.

Use a short text reconstruction based on the existing note:

1. Identify the tested condition and a fictional record or role only when it helps explain the finding.
2. State the expected behavior and the observation already recorded in the source note.
3. Give the checkpoint a portfolio evidence ID, or link an existing test ID. These are public reference labels, not internal ticket identifiers.
4. Preserve the outcome boundary: observed issue, confirmed retest, or proposed check. Keep proposed checks separate from recorded results.

Label reconstructed tables and examples explicitly. Fictional values illustrate the described behavior; they are not raw captures, newly executed results, or independent proof of a production outcome. Existing confirmed PASS/FAIL results can be summarized without publishing confidential artifacts.

Do not fabricate screenshots, logs, HTTP responses, SQL output, or before/after captures. Do not copy internal tickets, HAR files, database exports, proprietary source snippets, or application screenshots into a public evidence folder. Use general descriptions and fictional examples instead.

## Evidence and Sources

- Link every portfolio claim to local supporting evidence or a public repository/demo.
- Security summaries name the source, URL, and publication date when known.
- Clearly label personal analysis; do not present it as a sourced fact.
- Prefer exact test IDs, expected results, and observed outcomes over generic claims.

## Confidentiality

- Remove company names, customer data, credentials, tokens, internal URLs, ticket IDs, and production identifiers.
- Generalize values and schemas when the original detail is sensitive.
- Keep original application captures and NDA-restricted artifacts out of the repository; reconstruction is preferred to redaction.
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
