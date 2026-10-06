# Case Study — Investigating a Failed Report Stream and Slow Export

**Area:** Browser Diagnostics, Authentication Boundaries, and Availability

**Scope:** A report using Server-Sent Events (SSE) and a separate spreadsheet export

## At a Glance

| Item | Summary |
| --- | --- |
| Problem | A report remained blank while an export for a long date range took approximately 30 seconds. |
| My contribution | Inspected browser Network and Console observations, compared the UI and export behavior, and documented the findings. |
| Approach | Separate the stream failure from export latency, then distinguish observations from possible causes. |
| Recorded outcome | Findings documented; no confirmed authentication root cause, implemented fix, or successful retest is recorded. |
| Security relevance | Authentication-boundary investigation, availability assessment, and careful evidence reporting. |
| Evidence | Sanitized observations below; original internal responses and screenshots are not published. |

## Context

The report used an SSE connection for its web display and a separate path for spreadsheet exports. The recorded test used a date range exceeding one year. The original note described an export target below 10 seconds, but did not include an approved SLA, dataset size, or benchmark method. Treat that target as unverified context.

## Execution Context

| Field | Value |
| --- | --- |
| Activity | Browser diagnostics and report/export comparison |
| Evidence basis | Recorded Network, Console, and export observations summarized without original captures |
| Result scope | Stream rejection and approximate export latency were recorded; root cause, correction, and successful retest remain unconfirmed. |

Original application screenshots and confidential development artifacts are excluded under the [NDA-safe evidence standard](../portfolio-standards.md#nda-safe-portfolio-evidence). Reconstructed examples illustrate the written record; they are not independent execution proof.

## Finding and Evidence

> **Portfolio evidence notice:** This is a sanitized account of previously documented QA observations, not a newly executed security lab. Module details are generalized; no credentials, production URLs, or original internal screenshots are included.

| Evidence ID | Recorded observation | Evidence boundary |
| --- | --- | --- |
| SSE-E01 | The web report remained blank. Browser Network inspection showed a JSON response indicating unauthorized access. | The exact HTTP status and full request context were not retained in the public note. |
| SSE-E02 | The browser rejected an `application/json` response where an event stream was expected. | Establishes a response-format mismatch for the stream; it does not establish why authentication or authorization failed. |
| SSE-E03 | The spreadsheet export completed and reportedly matched the selected filters after approximately 30 seconds. | A reported timing observation; no repeated benchmark, resource profile, or row-count evidence is available. |

The recorded browser diagnostic was:

```text
EventSource's response has a MIME type ("application/json") that is not "text/event-stream". Aborting the connection.
```

**Suspected causes:** Missing or expired credentials, an authorization decision, or incorrect routing/middleware could explain the stream response. Query execution, file generation, or transfer time could contribute to export latency. None is confirmed by the published evidence.

**Evidence limits:** The available observations do not establish failed token propagation, browser main-thread blocking, repeated reconnect loops, worker exhaustion, or a database indexing defect.

## Impact

The blank report prevented users from viewing results. The export delay increased waiting time. Repeated export submissions could add load, but duplicate requests and resource saturation were not measured.

## Testing and Outcome

**Evidence type:** Sanitized recorded QA observations, summarized without original application captures.

**Checks documented:** Report display, browser Network and Console inspection, and export completion against the selected filters.

**Outcome:** Open investigation in the public record. No implementation correction or successful retest is documented. This is not evidence of an intrusion or a confirmed exploitable vulnerability.

## Proposed Verification

1. In an authorized test environment, record the response status, content type, session state, and matching server-side diagnostic evidence without publishing credentials.
2. Compare valid, expired, and unauthorized sessions. Confirm that rejected requests disclose no protected report data.
3. For an accepted stream, verify HTTP 200 and `text/event-stream`. Preserve appropriate authentication and authorization failures; do not relabel a rejected JSON response as an event stream.
4. Verify a visible client error state and recovery through the application's established session flow. Native `EventSource.onerror` does not provide a response object with HTTP status or headers; inspect those through appropriate diagnostics.
5. Repeat export measurements using a documented dataset size and environment. Separate server processing from download time before selecting an optimization.

These are planned checks, not completed results. Background exports or query changes require profiling evidence and an agreed performance target.

## Lesson Learned

A browser symptom narrows an investigation; it does not prove a root cause. Separate access-control decisions, stream handling, and performance measurements before proposing a fix.

## Technical References

- [WHATWG HTML Standard: Server-sent events](https://html.spec.whatwg.org/multipage/server-sent-events.html): response requirements, connection failures, and error-event behavior.
- [MDN: Using server-sent events](https://developer.mozilla.org/en-US/docs/Web/API/Server-sent_events/Using_server-sent_events): stream format and client error handling.

These references support protocol guidance, not the historical application observations.
