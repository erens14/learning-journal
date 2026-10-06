# QA Lesson Learned - Out of Sync Status Between Stock Issue and Stockcard

## Scenario

The process currently under test belongs to the **Warehouse/Stock Management** module, specifically focusing on the **"Turun Gudang" (Stock Issue / Goods Issuance)** feature.

The context of this business workflow is:

- Users (warehouse/operational staff) trigger the "Turun Gudang" action to release items from physical storage.
- The expected behavior is that once the item status is declared as "Turun Gudang", the system automatically updates the records in the **Stockcard** in real-time.
- This stockcard update serves as the primary validation for the system to perform stock deduction in the subsequent steps/processes.

---

## Execution Context

| Field | Value |
| --- | --- |
| Activity | Goods-issue and stock-ledger consistency checking |
| Evidence basis | Existing QA observations; the evidence summary below reconstructs them with generalized conditions |
| Result scope | Reported findings only. This reconstruction adds no new execution result, confirmed root cause, or successful retest. |

Original application screenshots and confidential development artifacts are excluded under the [NDA-safe evidence standard](../portfolio-standards.md#nda-safe-portfolio-evidence). Reconstructed examples illustrate the written record; they are not independent execution proof.

## Observation

The system successfully processed the initial "Turun Gudang" action, but a systemic failure occurred during downstream logistics logging:

- The goods issuance transaction data **failed to log / did not enter the Stockcard**.
- Because the stockcard was not populated, the system lost its data reference required to reduce item quantities.
- As a direct impact, the **stock deduction feature failed to function (failed to cut stock)** for that specific transaction.
- This created an inconsistent state: on one hand, the document/status indicated the goods had left the warehouse, but on the other hand, the physical stock count in the system was never reduced.

---

## Portfolio Evidence

**Reconstruction notice:** These checkpoints summarize observations already described in this note. Conditions and example references are generalized or fictional. No original screenshot, internal log, or new test run is represented.

| Evidence ID | Reconstructed checkpoint | Expected behavior | Observation recorded in the source note |
| --- | --- | --- | --- |
| STOCK-E01 | Complete a goods-issue action for a fictional transaction | The issued state has a corresponding stock-ledger entry | The action completed without the expected stockcard entry. |
| STOCK-E02 | Compare the issued state with the inventory movement | The required quantity reduction accompanies the completed workflow | Stock was not reduced for the affected transaction. |

## Why This Matters

This issue escalates into significant impacts across multiple areas:

### User Impact

- Warehouse operators or admins cannot complete the stock deduction process, potentially halting consecutive shipping or usage workflows.

### System Impact

- A breakdown in the data flow between interconnected modules (Logistics/Warehouse Module to Inventory/Stockcard Module) compromises the reliability of system automation.

### Data Impact

- It causes a severe data disparity between the actual physical items in the warehouse and the digital records stored within the stockcard.

### Business Impact

- It poses risks of phantom overstock or corrupted monthly inventory reports, which can disrupt material requirement analysis and management decision-making.

---

## QA Learning

Key takeaways to incorporate into future testing cycles:

- **Verify End-to-End Data Flow:** Testing a feature that changes document status (such as "Turun Gudang") must not stop at a "Success Message" on the UI. QA must trace the data impact all the way down to secondary database tables, such as the stockcard logs.
- **Ensure State & Action Integration:** For every item movement action, ensure that backend triggers or event listeners successfully execute the update queries to the stockcard before the entire transaction is marked complete *transactional rollback management*.
- **Test Asynchronous & Queue Edge Cases:** Verify how the system behaves if the stockcard update experiences delays due to query queues or unexpected mid-process network drops.

---

## UX / System Consideration

- **Asynchronous Progress Indicators:** If the stockcard update relies on a background process (*background job*), the system should display a clear processing status (e.g., *Pending / Processing / Success*) on the admin dashboard so users know whether the stock has actually been deducted.
- **Robust Error Handling & Fail-safes:** The system must reject the "Turun Gudang" action or throw a clear error message if the stockcard query fails to execute, rather than letting the transaction hang in an inconsistent state without stock deduction.

---

## Key Takeaway

A successful status change on a transaction document does not guarantee the accuracy of underlying inventory mutations; rigorous validation of the entire data chain (*data lineage*) is essential to maintain system logistics integrity.
