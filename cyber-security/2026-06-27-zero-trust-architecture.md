# Article Summary — Zero Trust Architecture

**Source:** National Institute of Standards and Technology (NIST)
**Author:** NIST
**Link:** https://www.nist.gov/blogs/taking-measure/zero-trust-cybersecurity-never-trust-always-verify

---

# Summary

This article introduces **Zero Trust Architecture (ZTA)** and explains why traditional perimeter-based security is no longer sufficient in today's IT environments. As organizations increasingly adopt cloud services, remote work, and mobile devices, the concept of a trusted internal network has become less effective.

The article references the 2015 U.S. Office of Personnel Management (OPM) data breach as an example of how attackers can exploit stolen credentials, gain access to internal systems, and move laterally across the network without being detected. This incident demonstrated the limitations of relying solely on perimeter defenses.

Zero Trust addresses these challenges through the principle of **"Never Trust, Always Verify."** Every access request must be authenticated, authorized, and continuously evaluated based on factors such as user identity, device health, access policies, and contextual information, regardless of where the request originates.

Overall, the article emphasizes that Zero Trust is not a single technology but a security architecture designed to minimize implicit trust, reduce lateral movement, and improve organizational resilience against modern cyber threats.

---

# Key Takeaways

* Traditional perimeter-based security is no longer sufficient for modern distributed environments.
* Zero Trust follows the principle of **"Never Trust, Always Verify."**
* Every access request should be continuously authenticated and authorized.
* Continuous verification helps reduce the risk of lateral movement after an initial compromise.
* Zero Trust is an architectural approach rather than a standalone security product.

---

# Lesson Learned

* Modern cybersecurity should rely on continuous verification instead of implicit trust.
* Stolen credentials remain one of the most common attack vectors.
* Identity, device posture, and security policies should all influence access decisions.
* Zero Trust focuses on limiting the impact of breaches rather than assuming they will never occur.

---

# Personal Reflection

This article helped me understand that Zero Trust is much more than implementing firewalls or MFA. It is a comprehensive security architecture that continuously validates every access request based on multiple factors rather than network location alone.

As I continue my cybersecurity learning journey, I want to explore **NIST SP 800-207** in more depth and understand how components such as the Policy Engine (PE), Policy Administrator (PA), and Policy Enforcement Point (PEP) work together to implement Zero Trust in enterprise environments.
