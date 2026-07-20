# Analysis of a ClickFix Campaign Exploiting Windows search-ms Protocol to Deliver MetaStealer

**Source:** YouTube (John Hammond)  
**Author:** John Hammond  
**Link:** [6.pdf John Hammond YT](https://youtu.be/EZ6TEjx7JLw?si=e0Zf6sqoDrie39Ks)  

---

## Summary

This video transcript provides a step-by-step breakdown by security researcher John Hammond analyzing an obfuscated phishing and malware delivery campaign. The attack begins with a user searching for remote desktop software (AnyDesk) and getting redirected through a Google malvertising link to a suspicious domain (`any.inc`). The landing page presents a fake Cloudflare Turnstile "verify you are human" CAPTCHA, masking its underlying logic behind Base64 and XOR-encoded JavaScript routines.

Unlike typical ClickFix scams that instruct users to copy and paste malicious PowerShell scripts into their command prompt, interacting with this fake CAPTCHA triggers an HTTP 302 redirect using the custom Windows `search-ms:` protocol handler. This protocol forces Windows Explorer to query a remote attacker-controlled SMB share (`\\secureview.nisk.inc...`), displaying a remote folder containing a file named `readme any PDF`—which is actually a malicious Windows shortcut (`.LNK`) file.

When executed, the LNK file launches batch commands via `cmd.exe` using system environment variables (`comspec`). To distract the victim, it opens the legitimate AnyDesk download page in Microsoft Edge while simultaneously using `curl` to fetch a malicious MSI installer (`6.pdf`). Notably, the download request embeds the victim's `%COMPUTERNAME%` as a dynamic subdomain, allowing threat actors to track infected hosts before silently installing the payload via `msiexec.exe`.

Deep analysis of the extracted MSI package reveals bundled cleanup scripts (`1.js`), custom DLLs, and an executable (`ls26.exe`) packed with *Private EXE Protector*. Dynamic analysis in a sandbox environment confirms that the payload executes a User Account Control (UAC) bypass using `computerdefaults.exe`, adds exclusions to Windows Defender, and deploys **MetaStealer** to harvest browser credentials, cookies, and system information.

## Key Takeaways

* Attackers leverage Google search ads (malvertising) targeting common utility searches (like AnyDesk) to redirect users to fake verification landing pages.
* The campaign abuses the Windows `search-ms:` protocol handler to automatically open remote SMB file shares inside Windows Explorer, bypassing standard browser file-download warnings.
* Environment variables (`%COMPUTERNAME%`) are dynamically injected into `curl` request subdomains during staging to exfiltrate host identifiers without needing complex preliminary payloads.
* Threat actors rely heavily on Living off the Land Binaries (LOLBins)—including `cmd.exe`, `curl.exe`, `msiexec.exe`, `wscript.exe`, and `computerdefaults.exe`—for payload execution and privilege escalation.
* The ultimate payload delivered is MetaStealer, packed via *Private EXE Protector*, which modifies Windows Defender exclusions to steal browser passwords, session cookies, and system metrics undetected.

## Lesson Learned

* Non-standard protocol handlers (like `search-ms:`) represent a dangerous bridge between web browser interactions and local OS file management, requiring strict system-level monitoring.
* Attackers intentionally use LNK shortcuts hosted on remote SMB shares to make external malicious files appear as local or network assets to unsuspecting users.
* Deobfuscating multi-stage malware requires combining static inspection (decoding obfuscated JavaScript, extracting MSI/CAB files) with dynamic sandbox execution to observe process creation safely.
* Simple system utilities like `curl` and `msiexec` are frequently weaponized in post-exploitation staging, emphasizing the need for robust endpoint detection rules on administrative binaries.

## Personal Reflection

As a QA engineer and cybersecurity enthusiast, reviewing this teardown highlights how critical edge-case protocol behaviors are when assessing application and OS integration risks. In QA, the focus is often on verifying expected system boundaries and input handling; seeing how threat actors weaponize native handlers like `search-ms:` to breach the browser sandbox demonstrates how unexpected protocol execution paths can be exploited.

This analysis reinforces the value of end-to-end trace analysis, from initial UI interactions down to low-level process creation. Understanding how initial stagers abuse built-in tools (`curl`, `msiexec`) to silently deploy info-stealers inspires me to incorporate security-minded checks into regular testing workflows—such as monitoring unexpected process spawns, network calls, and file system modifications during application execution.
