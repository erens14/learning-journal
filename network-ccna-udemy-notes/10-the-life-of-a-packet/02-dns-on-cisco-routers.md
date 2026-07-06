# Cisco IOS DNS Client and Server Configuration

## Overview

While Cisco routers are typically managed using direct IP addresses, they can be configured to act as either a **DNS Client** or a **DNS Server**. 
- A **DNS Client** configuration allows the router itself to resolve Fully Qualified Domain Names (FQDNs) or hostnames (e.g., when executing a `ping` command directly from the router's CLI). *Note: A router does not need to be a DNS client just to forward transit DNS traffic from other devices.*
- A **DNS Server** configuration enables the router to act as the authoritative name resolution source for the network by maintaining a local host database mapping names to IP addresses. While production environments usually utilize dedicated external Unix, Linux, or Windows servers, Cisco IOS is fully capable of handling local DNS roles.

## Key Concepts

### DNS Client vs. Transit Router
A router inherently routes packets containing DNS traffic (UDP/TCP Port 53) without special configuration. Configuring it as a DNS Client is only necessary if the router's own operating system needs to resolve names.

### `ip domain-lookup`
The global configuration command that enables the router to query a DNS server when an unrecognized string is typed into the CLI.

### Local Host Entries (`ip host`)
The manual static mapping database configured on a router. When acting as a DNS server, the router references these entries to respond to incoming client requests.

## How It Works

### Lab Topology Workflow

```text
  [ R1: DNS Client ]                      [ R2 ]                      [ R3: DNS Server ]
    (10.10.10.1)                       (10.10.10.2)                     (10.10.20.1)
         |                                  |                                |
         |--- 1. Ping R2 (Hostname) --------|                                |
         |                                                                   |
         |--- 2. DNS Query (UDP 53): Where is R2? -------------------------->| (Checks local host DB)
         |<-- 3. DNS Response: R2 is 10.10.10.2 <----------------------------|
         |
  (Resolves R2)
         |
         |================== 4. ICMP Echo Request (Ping) ===================> [ R2 ]
```

## Components / Structure

### DNS Configuration Options

| Command | Role | Description |
| --- | --- | --- |
| `ip domain-lookup` | Client / Server | Enables DNS resolution capabilities globally on Cisco IOS. |
| `ip name-server <IP>` | Client / Server | Defines the upstream or local DNS server IP address to query. |
| `ip domain-name <name>` | Client / Server | Defines the primary default domain suffix (e.g., `flackbox.lab`). |
| `ip domain-list <name>` | Client | Defines alternative/additional domain suffixes to check during resolution. |
| `ip dns server` | Server | Actively turns on the DNS daemon to listen for incoming client queries. |
| `ip host <name> <IP>` | Server | Statically maps a hostname or FQDN to an IP address in the local database. |

## Comparison

| Feature | Cisco Router as DNS Client | Cisco Router as DNS Server |
| --- | --- | --- |
| **Primary Purpose** | Resolves hostnames to IPs for local CLI commands. | Answers name resolution requests for other network hosts. |
| **Daemon Active** | No (Sends outbound queries only). | Yes (`ip dns server` must be enabled). |
| **Database Required** | No (Relies on external DNS servers). | Yes (Requires manual entry via `ip host` commands). |
| **Typical Use Case** | Small branch administration or lab environments. | Small isolated setups lacking dedicated server hardware. |

## Commands (If Applicable)

### Cisco IOS

#### 1. Configuring R3 as the DNS Server

```text
Router-R3# configure terminal
Router-R3(config)# ip domain-lookup
Router-R3(config)# ip name-server 10.10.20.1
Router-R3(config)# ip domain-name flackbox.lab
Router-R3(config)# ip dns server

! Standard hostname entries
Router-R3(config)# ip host R1 10.10.10.1
Router-R3(config)# ip host R2 10.10.10.2
Router-R3(config)# ip host R3 10.10.20.1

! FQDN entries
Router-R3(config)# ip host R1.flackbox.lab 10.10.10.1
Router-R3(config)# ip host R2.flackbox.lab 10.10.10.2
Router-R3(config)# ip host R3.flackbox.lab 10.10.20.1
Router-R3(config)# end
```

#### 2. Configuring R1 as the DNS Client

```text
Router-R1# configure terminal
Router-R1(config)# ip domain-lookup
Router-R1(config)# ip name-server 10.10.20.1
Router-R1(config)# ip domain-list flackbox.lab
Router-R1(config)# end
```

## Example

### Verifying DNS Resolution on Client Router (R1)

Once the configurations are complete, executing a ping from R1 triggers the DNS lookup process transparently:

```text
Router-R1# ping R3
Translating "R3"...using domain server (10.10.20.1) [OK]

Type escape sequence to abort.
Sending 5, 100-byte ICMP Echos to 10.10.20.1, timeout is 2 seconds:
!!!!!
Success rate is 100 percent (5/5), round-trip min/avg/max = 1/2/4 ms

```

```text
Router-R1# ping R2
Translating "R2"...using domain server (10.10.20.1) [OK]

Type escape sequence to abort.
Sending 5, 100-byte ICMP Echos to 10.10.10.2, timeout is 2 seconds:
!!!!!
Success rate is 100 percent (5/5), round-trip min/avg/max = 1/3/4 ms

```

## Important Notes

* **CLI Interruption:** If `ip domain-lookup` is enabled without a valid `ip name-server` configured, typing a typo in the CLI will cause the router to freeze for up to a minute while attempting to broadcast broadcast queries to find a DNS server.
* **Suffix Appending:** The `ip domain-list` command allows clients to search multiple domain spaces systematically when short hostnames (like `R2`) are input.
* **Scalability Limitations:** Utilizing a Cisco router as an authoritative DNS server is not scalable for enterprise environments because every single mapping must be manually typed out using separate `ip host` CLI lines.

## My Takeaways

* Configuring a router as a DNS client is completely optional and only matters if the administrator wants to reference domain terms directly within the IOS CLI prompt.
* Enabling `ip domain-lookup` without an underlying DNS infrastructure can slow down administration due to timeout hangs on command typographical mistakes.
* The `ip host` command serves a dual purpose: mapping static hosts locally on a single client device or populating the database when the device functions as an active DNS server.
* Multiple domain search parameters can be sequentialized using the `ip domain-list` suffix list command to make device queries more flexible.
* While Cisco IOS supports standalone server roles with `ip dns server`, production data networks universally rely on robust, centralized infrastructures like Windows Server or BIND on Linux.