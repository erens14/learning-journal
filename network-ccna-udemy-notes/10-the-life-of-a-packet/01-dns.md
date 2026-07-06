# Domain Name System (DNS)

## Overview

The Domain Name System (DNS) is a foundational Layer 7 (Application Layer) protocol used to resolve human-readable Fully Qualified Domain Names (FQDNs), such as `www.cisco.com`, into numerical IP addresses. This resolution process is critical because network routing and packet encapsulation require Layer 3 IP addresses to successfully deliver data across a network.

## Key Concepts

### Fully Qualified Domain Name (FQDN)
An FQDN is the complete domain name for a specific computer, or host, on the internet. It consists of a host name and a domain name (e.g., `LinuxA.FlackboxA.lab`).

### Authoritative DNS Server
A DNS server that holds the actual, original database records for a specific domain. It is responsible for definitively answering queries for hosts within its configured zone.

### DNS Forwarding
Because an internal DNS server cannot store the records of the entire internet, it uses "Forwarders" to pass queries for external or unknown domains onto public DNS servers.

## How It Works
When an application uses an FQDN, the system must resolve it to an IP address before the packet can be fully encapsulated at Layer 3. 

```text
[ Sender Host ]                                   [ Internal DNS Server ]
       |                                                     |
       |--- 1. Query: What is LinuxA.FlackboxA.lab? ------>| (Authoritative for domain)
       |<-- 2. Response: IP is 172.23.4.2 -------------------| 
       |
  (Resolves FQDN to IP)
       |
       |==== 3. Encapsulates & sends Layer 3 Packet =======> [ Target Host (LinuxA) ]

```

*Note: If the internal DNS server does not know the address (external query), it forwards the request to a public DNS server before responding to the host.*

## Components / Structure

DNS utilizes specific transport layer behaviors depending on the query status:

| Component / Property | Description |
| --- | --- |
| **Layer 7 Protocol** | Domain Name System (DNS) |
| **Default Transport Protocol** | **UDP Port 53** (Used for standard queries due to lower overhead) |
| **Failover Transport Protocol** | **TCP Port 53** (Used if the response exceeds buffer limits or for zone transfers) |
| **DNS Record Type (A Record)** | Maps a hostname to an IPv4 address |

## Comparison

| Feature | Internal DNS Server | External / Public DNS Server |
| --- | --- | --- |
| **Authority** | Authoritative for local enterprise domains (e.g., `FlackboxA.lab`). | Authoritative for internet domains or acts as a root/resolver. |
| **Database Scope** | Contains private, internal host IP records. | Contains global public mapping records. |
| **Internet Access** | Requires forwarders to resolve external domains. | Directly resolves or traverses the internet hierarchy. |

## Commands (If Applicable)

### Windows

```bash
# View network interface details, including the assigned DNS server and local domain
ipconfig /all

# Query the DNS server to resolve a specific hostname or FQDN
nslookup LinuxA

```

### Linux

```bash
# Query DNS to check resolution for a host (Alternative to nslookup)
dig LinuxA

```

### Cisco IOS

```text
Router# configure terminal
Router(config)# ip dns server
Router(config)# ip name-server 172.23.4.1

```

## Example

### Windows Host Resolution Scenario

* **Host IP:** `172.23.1.10` (/24)
* **Default Gateway:** `172.23.1.254`
* **DNS Server:** `172.23.4.1`
* **Local Domain:** `FlackboxA.lab`

When executing a ping command from the Windows host:

```text
C:\> ping LinuxA
Pinging LinuxA.FlackboxA.lab [172.23.4.2] with 32 bytes of data:
Reply from 172.23.4.2: bytes=32 time=1ms TTL=64

```

*Process:* The host implicitly attaches the local domain suffix, queries `172.23.4.1` via UDP port 53, receives `172.23.4.2`, and successfully initializes the ICMP traffic.

## Important Notes

* **Encapsulation Order:** During packet generation, the application data passes down to Layer 4 (e.g., specifying TCP/UDP ports) and requires successful DNS resolution before the Layer 3 IP header fields (Source/Destination IP) can be finalized.
* **Forwarder Dependency:** Unconfigured forwarders on an internal DNS server will cause queries for external public websites to fail, even if internal resolution works perfectly.
* **Caching:** Hosts and DNS servers temporarily cache resolved queries to avoid sending network traffic for the same destination repeatedly.

## My Takeaways

* DNS acts as the bridge between human-friendly names (FQDNs) and network-routing configurations (IP addresses).
* By default, DNS prioritizes UDP Port 53 for speed but can switch to TCP Port 53 if reliability or larger payload constraints demand it.
* An internal DNS environment allows local hostnames (like `EngineeringA`) to be easily mapped and managed inside a private domain infrastructure.
* Troubleshooting DNS issues on a local workstation usually starts with verifying the configurations via `ipconfig /all` and checking connectivity with `nslookup`.
* Network engineers must ensure proper DNS forwarders are specified on local servers to maintain seamless connectivity to outside internet resources.
