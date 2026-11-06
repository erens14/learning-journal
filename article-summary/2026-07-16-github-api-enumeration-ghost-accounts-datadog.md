# GitHub API Enumeration: Overlapping Reconnaissance Campaigns Targeting Corporate Repositories

**Source:** Datadog Security Labs, The  Hacker News
**Author:** Ravie Lakshmanan
**Link:** [Dormant Github Accounts Help Attackers](https://thehackernews.com/2026/07/dormant-github-accounts-help-attackers.html)

---

## Summary

Datadog Security Labs has issued a warning regarding multiple overlapping cyber campaigns systematically targeting corporate GitHub organizations, repositories, and individual user accounts. Threat actors are utilizing automated scraping tools paired with custom or legitimate-sounding user agents to conduct programmatic reconnaissance. To bypass security triggers and blend into normal operations, the campaign leverages a mix of over 50 "ghost" accounts (which were created two to five years ago and intentionally left inactive) alongside dozens of legitimate accounts whose Personal Access Tokens (PATs) or OAuth tokens were compromised or exposed unintentionally.

The text outlines the stealth execution methods and the ultimate impact of these enumeration campaigns:

* **Exploitation of Unauthenticated API Surface:** Because a substantial portion of GitHub’s API can be reached without authentication, attackers can query public data cleanly. They systematically list public repositories, map out user follower/following lists, extract gists, check organizational memberships, and run GraphQL queries against public objects without raising immediate red flags.
* **Reconnaissance and Infrastructure Mapping:** By combining these seemingly harmless queries, threat actors programmatically map out an organization’s entire GitHub ecosystem, identifying its active members, social circles, and specific projects modified by developers.
* **Escalation to Private Code Exfiltration:** While the bulk of the activity focuses on gathering public information, the campaign is not purely passive. Datadog confirmed that in select corporate scenarios, the threat actors successfully pivoted from data enumeration to cloning private repositories.

## Key Takeaways

* Threat actors use aged "ghost" accounts (2 to 5 years old) to bypass newer account creation security baselines and mask malicious scraping activity.
* Compromised or unintentionally exposed Personal Access Tokens (PATs) and OAuth credentials provide attackers with clean authentication pathways into corporate targets.
* GitHub’s vast unauthenticated API footprint allows automated scanners to gather deep reconnaissance data while blending into normal day-to-day web traffic.
* Although the majority of requests target public information, these campaigns can quickly escalate to the unauthorized cloning of private corporate codebases.
* The true danger of these attacks lies in their aggregate behavior; individual requests look unremarkable, but they represent versioned tooling moving in sync across weeks.

## Lesson Learned

* **Enforcing Strict Token Hygiene:** Development teams must implement automated scanning gates within code pipelines to instantly detect and revoke exposed PATs or OAuth tokens before they can be weaponized.
* **Monitoring Aggregate API Anomaly Patterns:** Security architectures must shift from evaluating standalone requests to utilizing behavioral analytics that detect synchronized, multi-account movement targeting public infrastructure boundaries.
* **Restricting Public Profile Footprints:** System administrators should audit organizational visibility settings, minimizing the amount of structural information (like developer connections and project histories) accessible via unauthenticated endpoints.
* **Applying the Principle of Least Privilege to API Access:** Organizations must ensure that all developer-generated access tokens are tightly scoped to the minimum required permissions, preventing broad account enumeration if a token is lost.

## Personal Reflection

I would compare the repository access granted by a narrowly scoped token with the access available after revocation. The useful evidence would identify the token scope, requested resource, and observed result. These are proposed checks, not completed token-security tests.
