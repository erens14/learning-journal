# Video Summary — Analysis of a ClickFix Campaign Exploiting Windows search-ms Protocol to Deliver MetaStealer

**Source:** YouTube (John Hammond)

**Channel / Speaker:** John Hammond

**Link:** [https://youtu.be/EZ6TEjx7JLw?si=e0Zf6sqoDrie39Ks](https://youtu.be/EZ6TEjx7JLw?si=e0Zf6sqoDrie39Ks)

---

## Executive Summary

In this technical breakdown, security researcher John Hammond analyzes a sophisticated social engineering and malware delivery campaign targeting users searching for utility software like AnyDesk. The attack chain begins with Google search malvertising, redirecting victims to a spoofed landing page (`any.inc`) featuring a fake Cloudflare Turnstile "Verify You Are Human" CAPTCHA. Underneath the landing page lies heavily obfuscated JavaScript utilizing Base64 encoding and XOR decryption routines.

Unlike traditional ClickFix lures that trick users into manually copying and executing PowerShell commands, this campaign weaponizes the native Windows `search-ms:` protocol handler via an HTTP 302 redirect. Interacting with the fake CAPTCHA forces Windows Explorer to query a remote attacker-controlled SMB share (`\\secureview.nisk.inc...`), displaying a remote folder containing a malicious Windows shortcut (`.LNK`) file masked as a PDF document.

Executing the shortcut triggers a multi-stage Living off the Land (LOLBin) infection chain. The script opens the legitimate AnyDesk download page in Microsoft Edge as a decoy while silently retrieving an MSI installer (`6.pdf`) using `curl.exe`. The request dynamically embeds the victim's `%COMPUTERNAME%` into the domain name to exfiltrate host identity. Once installed via `msiexec.exe`, the payload executes a User Account Control (UAC) bypass via `computerdefaults.exe`, adds Windows Defender exclusions, and deploys **MetaStealer** to harvest browser credentials, cookies, and system metrics.

## Chronology & Narrative Breakdown

* **Act 1: Malvertising & Obfuscated Landers:** A user searching for remote desktop software (AnyDesk) clicks a sponsored Google search ad. The link redirects to `any.inc`, displaying a blank page that dynamically renders a fake Cloudflare CAPTCHA via Base64 and XOR-encoded JavaScript routines to evade initial browser detection.
* **Act 2: ClickFix Verification & Protocol Abuse:** Clicking "Verify You Are Human" initiates an HTTP 302 redirect to `verification.nedisk.inc/recapture_v2.php`. Instead of copying a script to the clipboard, the server responds with a `Location` header invoking the Windows `search-ms:` protocol handler, forcing Windows Explorer to connect to a remote SMB network share (`\\secureview.nisk.inc\secureaccess`).
* **Act 3: LNK Execution & Subdomain Exfiltration:** Inside the remote Explorer window, the user sees a file named `readme any PDF` with a shortcut arrow. Double-clicking the `.LNK` file executes a chained batch command via `cmd.exe` (`%comspec%`). It opens the real AnyDesk site in Edge as a decoy while using `curl.exe` to fetch `6.pdf` from `http://[COMPUTERNAME].1.store/update/6.pdf`, exfiltrating the victim's hostname via DNS.
* **Act 4: MSI Unpacking, Defense Evasion & Stealer Deployment:** The downloaded `6.pdf` (an MSI package) is executed silently via `msiexec.exe`. The installer extracts a CAB archive containing a cleanup script (`1.js`) and a packed payload (`ls26.exe`). The payload uses `computerdefaults.exe` for UAC escalation, adds exclusion paths to Windows Defender, and launches **MetaStealer** to harvest stored credentials and system telemetry.

## Technical Deep Dive: Attack Chain & Payload Mechanics

* **Base64/XOR JavaScript Obfuscation:** The landing page hides its DOM structure behind a Base64 blob decoded at runtime via `atob()` and XOR routines, dynamically generating fake Cloudflare Ray IDs to appear legitimate to victim browsers.
* **`search-ms:` URI Scheme Abuse:** Weaponizes the native Windows search protocol (`search-ms:displayname=...&crumb=\\remote_smb_share`) to breach the web browser sandbox. This forces local Windows Explorer windows to display remote SMB shares without triggering standard browser download warnings.
* **LNK Payload & LOLBin Chaining:** The malicious shortcut relies entirely on native Windows utilities (`comspec` / `cmd.exe`, `msedge.exe`, `curl.exe`, `msiexec.exe`, `wscript.exe`) to perform browser decoys, silent file downloads, and background installations.
* **Host Reconnaissance via Dynamic Subdomains:** The `curl` command embeds the `%COMPUTERNAME%` system variable directly into the target HTTP request host string (e.g., `http://[VICTIM_HOSTNAME].1.store/...`), allowing attackers to log infected hostnames at the DNS level without needing preliminary reconnaissance binaries.
* **MSI/CAB Extraction & Private EXE Protector:** The MSI installer contains a CAB archive storing `1.js` (a JScript cleanup routine) and `ls26.exe` (a 70+ MB binary bloated to delay analysis and packed with *Private EXE Protector* to bypass static antivirus signatures).
* **Privilege Escalation & Stealer Execution:** Employs auto-elevating binaries (`computerdefaults.exe`) for UAC bypass, adds execution paths to the Windows Defender exclusion list (`Set-MpPreference`), and launches MetaStealer to extract browser passwords, session cookies, and system environment details.

## Key Takeaways

* Threat actors leverage Google search ads (malvertising) targeting popular software queries (like AnyDesk) to lead users to fake verification landing pages.
* The attack chain abuses the native Windows `search-ms:` protocol handler to auto-open remote SMB network shares inside Windows Explorer, bypassing browser download security alerts.
* System environment variables (`%COMPUTERNAME%`) are dynamically injected into `curl` request subdomains during staging to exfiltrate host identifiers without preliminary payloads.
* The campaign relies heavily on Living off the Land Binaries (LOLBins)—such as `cmd.exe`, `curl.exe`, `msiexec.exe`, `wscript.exe`, and `computerdefaults.exe`—for payload execution and privilege escalation.
* The ultimate payload delivered is MetaStealer, packed via *Private EXE Protector*, which modifies Windows Defender exclusions to steal browser passwords, session cookies, and system metrics undetected.

## Lesson Learned

* Non-standard protocol handlers (like `search-ms:`) represent a dangerous bridge between web browser interactions and local OS file management, requiring strict system-level monitoring and restriction.
* Attackers intentionally host LNK shortcuts on remote SMB shares to make external malicious files appear as local or network assets inside native Windows Explorer.
* Deobfuscating multi-stage malware requires combining static inspection (decoding obfuscated JavaScript, extracting MSI/CAB archives) with dynamic sandbox execution to observe process creation safely.
* Simple administrative utilities like `curl` and `msiexec` are frequently weaponized in post-exploitation staging, emphasizing the need for robust endpoint detection rules on built-in OS binaries.

## Personal Reflection

As a QA engineer and cybersecurity enthusiast, reviewing this teardown highlights how critical edge-case protocol behaviors are when assessing application and OS integration risks. In QA, the focus is often on verifying expected system boundaries and input handling; seeing how threat actors weaponize native handlers like `search-ms:` to breach the browser sandbox demonstrates how unexpected protocol execution paths can be exploited.

This analysis reinforces the value of end-to-end trace analysis, from initial UI interactions down to low-level process creation. Understanding how initial stagers abuse built-in tools (`curl`, `msiexec`) to silently deploy info-stealers inspires me to incorporate security-minded checks into regular testing workflows—such as monitoring unexpected process spawns, network calls, and file system modifications during application execution.
