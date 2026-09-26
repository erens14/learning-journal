# PRD: Synchronize Initial Procurement Report Totals

> **Portfolio sanitization notice:** Report names, query fields, endpoints, financial values, and internal identifiers are generalized. No production records or confidential schema details are included.

## Problem

When users first opened procurement reports, the summary totals and visible table rows could use different date filters. KPI cards and footer totals therefore did not always match the initial dataset until the user applied a filter manually.

The payment report could also calculate totals using the parent-document date while filtering visible rows by payment date.

## Goal

Display accurate KPI and footer totals immediately when users open:

- The procurement summary report
- The procurement line-item report
- The procurement payment report

## Target Users

- Operational staff reviewing purchase transactions
- Finance staff reviewing vendor payments and outstanding payables

## Functional Requirements

- The default report range is the current calendar month.
- Initial server-rendered summaries use the same default date range as the initial table rows.
- Summary and line-item report totals match the rows shown on first load.
- Payment-report totals use rows filtered by payment date.
- Payment-report KPI and footer totals include invoice value, amount paid, and remaining payable.
- An empty result set displays zero for every total.
- Existing manual filter, reset, export, validation, routing, and database behavior remains unchanged.

## Technical Rules

- Reuse the existing report filter parameters and endpoints.
- Preserve two-decimal monetary precision on the server.
- Calculate payment totals from the same filtered query used to load payment-report rows.
- Use payment date, not only the parent-document date, for payment-report filtering and totals.
- Preserve explanatory comments around implicit initial-filter synchronization.
- Do not expose internal query-field or endpoint names in portfolio evidence.

## Acceptance Criteria

- Opening each procurement report immediately shows totals that match the visible table rows without selecting Apply Filter.
- The initial date range covers the current calendar month.
- Payment-report totals use payment-date filtering.
- Invoice value, amount paid, and remaining payable match the filtered payment rows.
- An empty query result displays zero totals without an error.
- Existing manual filters, reset actions, and exports continue to work.
- Existing procurement-report tests remain passing.

## Out of Scope

- Automatic total refresh after every individual filter-field change
- Database migrations
- Route or API-contract changes
- Reports outside the procurement module
- Changes to payment creation or posting behavior
