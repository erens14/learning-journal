# QA Lesson Learned - Cumulative Rounding Discrepancies in Partial Payment Remain Calculations

## Scenario

The accounts receivable settlement module (**Receivable Payment**) supports multi-tranche partial payments against a single invoice, including proportional withholding tax (**PPh 23**) deductions for each partial settlement.

The system architecture is designed to:

1. Calculate tax deductions individually per partial payment transaction.
2. Dynamically re-calculate and aggregate the remaining balance (**Total Remain**) on the parent entity view (**Receivable Detail / Info**) after each payment iteration:
$$\text{Total Remain} = \text{Gross Invoice Amount} - \sum (\text{Net Payment Received}_i + \text{Tax Deducted}_i)$$

---

## Observation

During regression testing on multi-stage partial payments, QA observed a decoupling between component-level accuracy and aggregate-level balance integrity:

* **Transaction Level (Passed):** Each individual payment record accurately calculated the 2% PPh 23 tax value and posted corresponding balanced entries in the payment ledger.
* **Master Entity Level (Failed):** Upon navigating to the **Receivable Detail** view after multiple partial payments, the displayed **Total Remain** amount suffered from a fractional discrepancy (e.g., small rounding variances of Rp 1 to Rp 102).

Technical analysis indicated floating-point rounding divergence during database aggregation (`SUM()`) queries vs. backend application layer rounding implementations (`round() / floor()`).

---

## Why This Matters

### User Impact

* Finance teams cannot mark accounts receivable records as fully settled (`PAID`) due to phantom fractional balances remaining on parent invoices.

### System Impact

* Cumulative precision drift across multiple partial payments blocks automated status transition triggers from `PARTIAL` to `PAID`.

### Data Impact

* Discrepancies between historical payment transaction totals and parent ledger summary balances impair audit trails.

### Business Impact

* Operational friction during financial period closes and customer statement reconciliations due to unresolvable minor remain balances.

---

## QA Learning

Evaluating financial settlement mechanisms requires verifying both individual transaction math and long-term aggregate balance math across multiple execution cycles.

### Validation Points

* **Multi-Tranche Boundary Testing:** Run full partial payment lifecycles ($3+$ sequential partial payments) rather than testing only a single partial payment step.
* **Precision Audit Across Layers:** Compare calculated balances across the Payment Form UI, Database Query Views, Journal Postings, and Master Detail Summary cards to ensure identical rounding application.
* **Zero-Balance Verification:** Verify that the final partial payment exacts a true `Remain = 0.00` state without requiring manual balance adjustments.

### Edge Cases

* Invoices with odd fractional amounts divided into irregular partial payment percentages (e.g., 33.33% partial payments with 2% PPh 23).
* Reversing or voiding a middle partial payment within a multi-payment chain to observe aggregate recalculation behavior.
* Multi-currency partial settlements subject to exchange rate rounding alongside tax deductions.

---

## UX / System Consideration

* **Standardized Rounding Policy:** Enforce a unified currency rounding policy (e.g., `HALF_UP` or explicit integer truncation) applied consistently at both the backend application service layer and database query aggregation views.
* **Fixed-Point Precision Types:** Store monetary amounts and tax figures using exact numeric data types (`DECIMAL(18,2)` or integer cents/rupiah) rather than floating-point data types (`FLOAT` or `DOUBLE`).
* **Auto-Settlement Thresholds:** Implement a minor rounding variance tolerance mechanism (e.g., variances $< \text{Rp } 1.00$ automatically settle to zero upon final payment processing).

---

## Key Takeaway

A feature is not verified simply because an individual transaction calculation passes. QA must validate the cumulative math across multi-stage lifecycles to catch subtle floating-point rounding errors before they corrupt master entity balances.
