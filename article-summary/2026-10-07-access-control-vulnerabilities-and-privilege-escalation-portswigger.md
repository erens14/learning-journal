# Article Summary — Access Control Vulnerabilities and Privilege Escalation

**Source:** PortSwigger Web Security Academy

**Author:** No individual byline displayed

**Publication date:** Not displayed on the source page

**Reviewed:** 2026-10-07

**Link:** [Access control vulnerabilities and privilege escalation](https://portswigger.net/web-security/access-control)

---

# Summary

PortSwigger distinguishes authentication, session management, and authorization: identifying someone, associating requests with that identity, and deciding what they may do.

Access restrictions can depend on privilege, resource ownership, or workflow state. Failures allow higher privileges, another user's resources, or actions outside the permitted sequence. An ownership failure can also expose an administrator's account and enable further escalation.

Examples include concealed endpoints, editable role parameters, routing or HTTP-method discrepancies, missing checks in later workflow steps, forged `Referer` headers, and bypassable location restrictions. Redirects can still disclose sensitive response data.

The article recommends default denial, consistent application-wide enforcement, explicit resource permissions, and auditing. This is vendor-authored educational material; product promotion is excluded. This note records reading and proposed analysis, not lab execution.

---

# Key Takeaways

* Vertical controls separate privileges; horizontal controls separate users' resources; context-dependent controls constrain workflow states.
* Insecure direct object references (IDOR) involve manipulated object references enabling unauthorized access. Unpredictable identifiers do not replace permission checks.
* Hidden controls and client-controlled request values are insufficient authorization evidence.
* Permissions need testing across requests, resources, and workflow steps.

---

# Lesson Learned

The following is my proposed QA application of the reading. These fictional scenarios are test designs, not reported vulnerabilities or completed tests.

| Proposed checkpoint | Fictional test design | Evidence I would collect in an authorized lab |
| --- | --- | --- |
| Separate role and ownership | Give two standard users separate records and one reviewer limited approval rights. Write the expected permission matrix before testing. | Documented actor, target record, action, and expected permission. |
| Verify a prohibited read | Ask whether User A can retrieve User B's `DEMO-RECORD-B` through the underlying request. Compare with an allowed read of User A's own record. | Sanitized request and response, authenticated actor, and whether protected fields appear. |
| Verify a prohibited write | Attempt a reviewer-only update using a standard-user session in the lab. Inspect the record afterward. | Both the rejection behavior and a read-back showing whether the record changed. |
| Check the final workflow action | Design a case where an approval confirmation is requested without satisfying its prerequisites. | Expected workflow state and the actual state before and after the request. |
| Compare alternate request paths | Inventory supported methods and route variants for one sensitive action, then repeat the same permission expectation. | A bounded list of variants tested and any variant that reaches the action. |
| Examine a rejected response | Check the response body when access redirects or displays an error. | Whether confidential content is disclosed, regardless of the page eventually displayed. |

For each future run, I would record the observed response and resulting state separately. A rejected-looking screen would not be sufficient evidence that a write was prevented. An allowed control case would also help distinguish a permission rejection from a broken endpoint or invalid input.

For public documentation, I would use fictional roles and records, describe the scope, and exclude confidential application captures. Planned checks remain unexecuted until I record their results. A successful check would support only its documented conditions, not a claim that the entire application is secure.

---

# Personal Reflection

As a QA engineer transitioning into entry-level cybersecurity, I can turn a business permission rule into a testable question: which actor may perform which action on which record in which state? That provides a concrete bridge from functional testing to security reasoning. I would document these checks as future security practice and keep them distinct from my existing QA observations.

My next step is to complete an introductory [PortSwigger access-control lab](https://portswigger.net/web-security/access-control#labs). I would write the expected boundary first, record what I observe, and explain the result in my own words. For defensive follow-up, I would consider which actor, action, resource, and decision fields would help an analyst investigate suspicious access. That logging idea is my learning extension, not a finding or implementation claim from this article. No lab has been completed for this note.

---
