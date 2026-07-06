# QA Lesson Learned - Out of Sync Status Between Stock Issue and Stockcard

## Scenario

The process currently under test belongs to the **Warehouse/Stock Management** module, specifically focusing on the **"Turun Gudang" (Stock Issue / Goods Issuance)** feature[cite: 1]. 

The context of this business workflow is:
- Users (warehouse/operational staff) trigger the "Turun Gudang" action to release items from physical storage[cite: 1].
- The expected behavior is that once the item status is declared as "Turun Gudang", the system automatically updates the records in the **Stockcard** in real-time[cite: 1].
- This stockcard update serves as the primary validation for the system to perform stock deduction in the subsequent steps/processes[cite: 1].

---

## Observation

The system successfully processed the initial "Turun Gudang" action, but a systemic failure occurred during downstream logistics logging:
- The goods issuance transaction data **failed to log / did not enter the Stockcard**[cite: 1].
- Because the stockcard was not populated, the system lost its data reference required to reduce item quantities[cite: 1].
- As a direct impact, the **stock deduction feature failed to function (failed to cut stock)** for that specific transaction[cite: 1].
- This created an inconsistent state: on one hand, the document/status indicated the goods had left the warehouse, but on the other hand, the physical stock count in the system was never reduced[cite: 1].

---

## Why This Matters

This issue escalates into significant impacts across multiple areas:

### User Impact
- Warehouse operators or admins cannot complete the stock deduction process, potentially halting consecutive shipping or usage workflows[cite: 1].

### System Impact
- A breakdown in the data flow between interconnected modules (Logistics/Warehouse Module to Inventory/Stockcard Module) compromises the reliability of system automation[cite: 1].

### Data Impact
- It causes a severe data disparity between the actual physical items in the warehouse and the digital records stored within the stockcard[cite: 1].

### Business Impact
- It poses risks of phantom overstock or corrupted monthly inventory reports, which can disrupt material requirement analysis and management decision-making[cite: 1].

---

## QA Learning

Key takeaways to incorporate into future testing cycles:
- **Verify End-to-End Data Flow:** Testing a feature that changes document status (such as "Turun Gudang") must not stop at a "Success Message" on the UI. QA must trace the data impact all the way down to secondary database tables, such as the stockcard logs[cite: 1].
- **Ensure State & Action Integration:** For every item movement action, ensure that backend triggers or event listeners successfully execute the update queries to the stockcard before the entire transaction is marked complete (*transactional rollback management*)[cite: 1].
- **Test Asynchronous & Queue Edge Cases:** Verify how the system behaves if the stockcard update experiences delays due to query queues or unexpected mid-process network drops[cite: 1].

---

## UX / System Consideration

- **Asynchronous Progress Indicators:** If the stockcard update relies on a background process (*background job*), the system should display a clear processing status (e.g., *Pending / Processing / Success*) on the admin dashboard so users know whether the stock has actually been deducted[cite: 1].
- **Robust Error Handling & Fail-safes:** The system must reject the "Turun Gudang" action or throw a clear error message if the stockcard query fails to execute, rather than letting the transaction hang in an inconsistent state without stock deduction[cite: 1].

---

## Key Takeaway

A successful status change on a transaction document does not guarantee the accuracy of underlying inventory mutations; rigorous validation of the entire data chain (*data lineage*) is essential to maintain system logistics integrity[cite: 1].