<!-- slop-ignore F7 --> <!-- Preserve the published article title. -->
# Article Summary - Google Warns LLMjacking Attacks Are Costing Some Enterprises Up to $1 Million in Cloud Charges

<!-- slop-ignore R2 --> <!-- Preserve the article-summary template's metadata layout. -->
**Source:** The Hacker News

**Author:** Ravie Lakshmanan

**Publication date:** 2026-11-03

**Reviewed:** 2026-11-04

**Link:** [Read the original article](https://thehackernews.com/2026/11/google-warns-llmjacking-attacks-are.html)

---

## Summary

The article describes LLMjacking, in which attackers use an organization's model access and leave it paying for unauthorized consumption. It combines Google Threat Intelligence Group and Mandiant investigations with a separate Symantec report about unauthorized AI coding relays. The two reports describe different paths to abuse and exposure. [The Hacker News](https://thehackernews.com/2026/11/google-warns-llmjacking-attacks-are.html)

Google and Mandiant report incidents with fraudulent charges exceeding $100,000 in one day and cumulative charges reaching $1 million at some organizations. Attackers obtained cloud credentials or exposed model access, expanded permissions, and monetized resources through proxy services. Google calls resale gateways that pool unauthorized access LLM Mixers. These amounts describe investigated incidents. [Google and Mandiant report, November 2, 2026](https://cloud.google.com/blog/topics/threat-intelligence/llmjacking-monetizing-compromised-cloud-models)

Symantec describes a relay that installs genuine Codex and Claude Code clients, then changes their configuration to use third-party servers and removes execution restrictions. It reports use across a dozen organizations. Symantec had no evidence that the operator had abused that position to harvest prompts or manipulate responses. Both primary reports were read for this note. Incident findings remain attributed to their investigators, and testing of their detection or remediation guidance is NOT RUN. [Symantec report, October 29, 2026](https://www.security.com/threat-intelligence/openai-claude-unauthorized-relays)

---

## Key Takeaways

* Stolen session tokens can provide access after authentication. Google describes UNC6993 tricking users into sharing JSON containing an active access token. For a QA review, I would include session theft and revocation alongside login and MFA checks. [Google and Mandiant report](https://cloud.google.com/blog/topics/threat-intelligence/llmjacking-monetizing-compromised-cloud-models)

* Early activity can be small. Google observed credential validation using `max_tokens=1`, followed in other activity by rapid creation and deletion of service accounts to evade rate limits. I would investigate whether usage controls aggregate activity across identities under the same project. [Google and Mandiant report](https://cloud.google.com/blog/topics/threat-intelligence/llmjacking-monetizing-compromised-cloud-models)

* Model gateways belong in authorization reviews. Google reports exploitation of LiteLLM's `/key/regenerate` user-ID rebinding flaw, CVE-2026-40217, to obtain `PROXY_ADMIN` credentials. A proposed regression test should inspect the regenerated key's owner and effective permissions. [Google and Mandiant report](https://cloud.google.com/blog/topics/threat-intelligence/llmjacking-monetizing-compromised-cloud-models)

* Installation provenance and effective configuration need separate evidence. Symantec observed changes to `~/.codex/config.toml` and `~/.claude/settings.json`, including third-party endpoints, relay-issued credentials, and disabled telemetry. Its report identifies configuration changes as the mechanism. I would inspect the active endpoint and execution policy after setup and restart. [Symantec report](https://www.security.com/threat-intelligence/openai-claude-unauthorized-relays)

* Budget notifications and enforced limits need distinct acceptance criteria. Google's guidance includes quotas, spending controls, and audit monitoring. In a test environment, I would establish which controls send a notification and which reject additional consumption, including concurrent requests and streaming. [Google and Mandiant report](https://cloud.google.com/blog/topics/threat-intelligence/llmjacking-monetizing-compromised-cloud-models)

---

## Lesson Learned

I would define the authorized identity, permitted model, and consumption limit before writing tests. Each check needs evidence from the component that enforces the relevant rule. An HTTP error alone leaves questions about whether an upstream provider accepted a request or charged for work already started.

The following checks are proposed for an isolated lab using synthetic identities, dummy credentials, a mock billing ledger, and a local model-service stub. All checks are NOT RUN. The relay fixture would be locally controlled, with harmless configuration files and no external reseller connection.

| Proposed check | Expected result | Evidence to collect |
| --- | --- | --- |
| Request inference without a credential, with an expired token, and with a token scoped to another model or project. | The service denies each unauthorized request before dispatching work to the model stub. | Authorization decisions, stub invocation count, and mock billing entries. |
| Revoke a dummy credential and retry through an existing test session. | Subsequent access follows the documented revocation policy. Any propagation delay or still-valid derived token is recorded. | Revocation timestamp, token relationships, and subsequent access decisions. |
| Rotate synthetic service accounts while submitting concurrent requests against a shared project quota. | Account rotation preserves the aggregate limit. Rejected requests create no additional model work. | Per-account and project totals, quota decisions, and upstream request records. |
| Reach a mock spending cap during a stream and send another request. | The implementation follows its documented rules for ongoing streams and new requests. Notifications and blocking behavior are assessed separately. | Stream timeline, admission decisions, alert delivery time, and mock charges. |
| Attempt to change a dummy key's owner or increase its permissions during regeneration. | The gateway enforces owner and role authorization and issues no privileged credential to the unauthorized caller. | Before-and-after key metadata, effective permissions, and audit events. |
| Apply a harmless configuration fixture that changes a client's endpoint and execution policy. | The review identifies the changes and verifies restoration against the approved baseline after restart. | Configuration differences, effective runtime settings, and connections to the local relay stub. |

For monitoring, I would correlate credential changes with service enablement and model usage. I would first confirm that the relevant logs are collected, then test alert delivery using synthetic events. A missing event would remain an evidence gap until I established whether collection, processing, or the detection rule caused it.

---

## Personal Reflection

I want to make resource consumption part of my authorization testing. A request can use valid credentials while exceeding the owner's intended model scope or spending authority. I would record both the access decision and resulting work so that a passing test has evidence beyond the response shown to the caller.

My next exercise would use a small gateway stub with project-level accounting and a configuration baseline for a mock coding client. I would begin with quota aggregation under account rotation, then check revocation and configuration restoration. I would keep expected outcomes separate from observations and attach sanitized evidence to each result. These exercises remain NOT RUN.
