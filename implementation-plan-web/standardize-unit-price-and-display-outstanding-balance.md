# PRD: Standardize Unit Price and Display Outstanding Balance

> **Portfolio sanitization notice:** Module names, view paths, class names, financial values, and internal identifiers are generalized. Example values are fictional and exist only to define testable behavior.

## Problem

The transaction-detail page used an inconsistent unit-price formatter. Values stored with four decimal places could render with three visible decimal places, reducing readability and creating inconsistent financial presentation.

The same page did not show the remaining vendor-payment balance. Users had to calculate the difference between the grand total and total paid manually.

## Goal

- Display every unit price using the application's localized currency format with exactly two decimal places.
- Show the outstanding balance in the transaction summary.
- Highlight a positive outstanding balance and provide the existing Add Payment action.
- Display zero and a `PAID` state when the transaction is fully paid or overpaid.
- Preserve existing payment creation, deletion, and recalculation behavior.

## Target Users

- Operational staff reviewing purchase transactions
- Finance staff reviewing vendor payments and outstanding balances

## Functional Requirements

- The Product Information table displays each unit price with exactly two decimal places.
- The summary displays `OUTSTANDING BALANCE` directly below `TOTAL PAID`.
- Outstanding balance is calculated as `grand total - total paid`.
- A positive outstanding balance appears in red and displays the existing Add Payment action.
- A zero outstanding balance appears as `0.00` in green with a `PAID` badge.
- Historical overpayment data never produces a negative displayed balance; it displays `0.00` and `PAID`.
- Opening the detail page does not change transaction or payment data.

## Technical Rules

- Limit implementation to the target transaction-detail view and its render tests.
- Reuse the application's fixed two-decimal currency formatter.
- Use decimal-safe subtraction and comparison rather than floating-point arithmetic.
- Calculate the outstanding balance once and reuse the same value for display and payment-state decisions.
- Preserve explanatory comments around monetary precision and balance calculation.
- Repository changes must pass whitespace validation.
- Do not change database schemas, routes, API contracts, payment services, related reports, or exports.

## Acceptance Criteria

- A stored unit price of `1000.0000` displays as `1,000.00`, not `1,000.000`.
- `OUTSTANDING BALANCE` appears directly below `TOTAL PAID`.
- A fictional grand total of `1,000.00` and total paid of `300.00` produce an outstanding balance of `700.00` in red.
- When grand total equals total paid, the page displays `0.00` in green with a `PAID` badge.
- Overpayment data does not display a negative balance.
- The Add Payment action appears only when the outstanding balance is positive.
- Render tests cover unpaid, fully paid, and overpaid states.
- Existing monetary-formatting tests remain passing.

## Out of Scope

- Changes to stored price or total values
- Payment creation, update, deletion, or recalculation changes
- Changes to related summary, detail, payment reports, or exports
- Route, API, authentication, or authorization changes
- Global formatter changes that could affect other pages
- Unrelated shared-component repairs
