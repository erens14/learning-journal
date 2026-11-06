# npm 12 Disables Install Scripts by Default to Reduce Supply Chain Risk

**Source:** The Hacker News  
**Author:** Ravie Lakshmanan  
**Link:** [npm 12 Disables Install Scripts by Default to Reduce Supply Chain Risk](https://thehackernews.com/2026/07/npm-12-disables-install-scripts-by.html)  

---

## Summary

GitHub has officially released npm version 12, changing default execution settings for package-installation security. To combat a rising wave of supply chain attacks targeting the Node.js ecosystem, the update flips three historically permissive, trust-by-default execution configurations into strict, opt-in restrictions.

The primary target of this hardening initiative is the package installation phase, which has historically been highly vulnerable to exploitation. Previously, running a standard `npm install` command automatically triggered underlying lifecycle scripts (such as `preinstall`, `install`, and `postinstall`) embedded within both direct and deeply nested transitive dependencies. Malicious actors frequently abused this behavior by publishing typo-squatted or compromised packages that automatically executed arbitrary malicious code on a developer’s local workstation or a shared CI/CD build runner during installation.

To eliminate this code-execution surface, npm 12 implements the following foundational default changes:

* **Blocked Install Scripts:** The `allowScripts` configuration now defaults to off. Dependency lifecycle hooks and implicit native `node-gyp` builds are entirely blocked unless explicitly allowlisted in the project's `package.json` configuration or authorized via the CLI.
* **Restricted Git Dependencies:** The `--allow-git` parameter now defaults to `none`, completely blocking the resolution of direct or transitive dependencies hosted via external Git repositories unless explicitly permitted.
* **Restricted Remote URLs:** The `--allow-remote` parameter now defaults to `none`, preventing npm from resolving external tarball links (e.g., HTTPS URLs) outside the official registry without manual override.

Furthermore, npm 12 implements strict identity-based security policies by phasing out legacy granular access tokens (GATs) that bypass two-factor authentication (2FA). Tokens configured to bypass 2FA will lose sensitive account and package management permissions. Their publishing capabilities are also heavily restricted, transitioning the ecosystem toward OpenID Connect (OIDC) trusted publishing and mandatory human 2FA sign-offs for package deployments.

## Key Takeaways

* GitHub has launched npm version 12, flipping decades-old permissive defaults to enforce a zero-trust installation architecture.
* Dependency lifecycle hooks (`preinstall`, `install`, `postinstall`) and implicit `node-gyp` rebuilds are now entirely blocked by default.
* Resolution mechanisms for direct or transitive Git repositories and remote HTTPS tarball URLs have been switched to a strict, opt-in structure.
* Project maintainers must explicitly manage trusted dependencies using a new `allowScripts` configuration block in their `package.json`.
* Granular access tokens that bypass 2FA are deprecated for publishing and administrative actions, mandating OIDC or human-verified multi-factor workflows.
* The update shifts the ecosystem's baseline security model from assuming third-party dependency safety to treating unverified scripts as active risks.

## Lesson Learned

* **Eliminating Permissive Defaults:** Modern ecosystem security requires engineering platforms to prioritize defense over total convenience, shifting the burden of trust confirmation from the user to an explicit configuration model.
* **Securing Transitive Software Layers:** Software validation frameworks cannot simply verify direct code dependencies; they must actively account for the integrity and automated execution rights of third-party dependencies down the entire supply chain tree.
* **Identity and Infrastructure Hardening:** Hardening access points through strict multi-factor enforcement and OIDC authentication prevents token harvesting and account takeover vectors from poisoning automated distribution channels.
* **Proactive Refactoring Workflows:** Engineering teams must adapt their local build and continuous integration (CI) environments to support allowlist-style dependency patterns, ensuring necessary scripts run securely without opening ambient holes.

## Personal Reflection

`postinstall` can run code while a developer is setting up a dependency, before the application itself is tested. That makes package installation part of the security boundary I need to understand.

I would include automated build sequences and dependency execution permissions in my quality checks. Application behavior and the delivery pipeline need separate evidence; a working application does not establish that its installation hooks are safe.
