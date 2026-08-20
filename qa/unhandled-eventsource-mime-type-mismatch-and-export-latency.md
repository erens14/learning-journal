# QA Lesson Learned - EventSource SSE MIME Type Mismatch & Export Performance Bottlenecks

## Scenario

The **Report Vehicle Order** module was designed to process large historical datasets (including date range filters exceeding 1 year) using two data retrieval streams:

1. **Real-time Web UI Display:** Fetching and rendering report data using Server-Sent Events (`EventSource` / SSE) for continuous data streaming.
2. **Data Export:** Generating `.xlsx` spreadsheet files directly from backend queries.

The expected behavior was that the Web UI would stream data smoothly via text/event-stream headers, and the Excel export would execute within an acceptable performance response window (< 10 seconds).

---

## Observation

During testing with a data filter interval exceeding 1 year, two distinct technical issues were identified across rendering and performance layers:

1. **EventSource Authentication & Header Handling Failure (Web UI):**
   The Web UI displayed a blank/empty report. Inspection of the browser's Network tab revealed a JSON error response (`Unauthorized Access`), while the Console logged:
   `EventSource's response has a MIME type ("application/json") that is not "text/event-stream". Aborting the connection.`
   The SSE handler failed to pass or maintain authentication tokens, causing the backend to throw a 401/403 JSON exception instead of an event stream response.

2. **Excel Export Latency (Performance Bottleneck):**
   The Excel report generated successfully and matched the applied filters accurately. However, execution latency reached **~30 seconds**, blocking the browser connection thread during processing.

---

## Why This Matters

### User Impact

* Users see a blank, non-responsive screen on the web UI with no user-facing error notifications explaining token or stream connection failures.
* Users face noticeable UI lag and extended waiting times (~30s) when exporting large historical reports, creating the perception that the application has frozen.

### System Impact

* Unhandled EventSource connection aborts trigger repeated reconnect loops, swelling client-server connection pools.
* Synchronous heavy query execution for large Excel exports hogs memory allocations on active web server worker threads.

### Data Impact

* Users might repeatedly click the export button during the 30-second delay, triggering duplicate memory-intensive database queries.

### Business Impact

* Decreased operational efficiency for logistics and finance teams requiring fast access to historical vehicle order metrics.

---

## QA Learning

Testing streaming interfaces and heavy reporting modules requires validating network protocol headers, authentication persistence, error fallback states, and strict performance response SLAs.

### Validation Points

* **Protocol & MIME Type Compliance:** Ensure SSE endpoints consistently return `Content-Type: text/event-stream` even when handling authorization checks or exceptions.
* **Authentication Propagation:** Confirm that bearer tokens or session cookies are correctly bound to EventSource or WebSocket handshake connections.
* **UI Error State Handling:** Verify that stream connection aborts immediately render human-readable toast notifications or empty state placeholders instead of a blank UI.
* **Performance Benchmark Testing:** Measure response time SLAs on large dataset queries (e.g., records spanning > 1 year).

### Edge Cases

* Expired session tokens during an active SSE connection stream.
* Concurrent users triggering simultaneous 30-second Excel exports for multi-year data ranges.
* Interrupted connection streams mid-transfer during large payload rendering.

---

## UX / System Consideration

* **Stream Error Catching:** Update the frontend SSE error listener to catch `401 Unauthorized` or non-`text/event-stream` headers and trigger a automatic token refresh or redirect to login.
* **Asynchronous Chunking / Background Export:**
  * Convert long-running synchronous Excel exports (~30s) into asynchronous background queue jobs (e.g., Redis/RabbitMQ worker).
  * Implement file chunking or send an email/in-app notification once the large file is ready for download.
* **DB Query & Indexing Optimization:** Optimize the underlying report query with proper composite index coverage on date range fields to reduce execution latency below 5 seconds.

---

## Key Takeaway

A successful data export is incomplete if execution latency degrades user experience, and streaming data layers must handle authentication failures gracefully. Quality Assurance must evaluate network protocol headers and performance response times alongside functional correctness.
