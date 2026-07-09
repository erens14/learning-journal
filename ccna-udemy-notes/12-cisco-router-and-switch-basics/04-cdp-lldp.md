# Neighbor Discovery Protocols (CDP and LLDP)

## Overview

Cisco Discovery Protocol (CDP) and Link Layer Discovery Protocol (LLDP) are Layer 2 neighbor discovery protocols that share operational metadata with directly connected network devices. These protocols provide administrators with critical information—such as the neighbor's hostname, local/remote interface connections, hardware platform, operating system version, and configured IP addresses. These tools are incredibly useful for dynamically mapping network topologies, validating physical cabling placement, and troubleshooting remote environments when accurate structural documentation is missing.

## Key Concepts

### Layer 2 Operation

Because both protocols function strictly at the Data-Link Layer (Layer 2), neighbor devices can detect and map one another even if the connecting interfaces completely lack Layer 3 IP address configurations.

### Footprinting Security Risk

While highly advantageous for internal network mapping, discovery protocols present a notable security vulnerability. Unfiltered neighbors broadcast operational architecture summaries in cleartext, meaning malicious actors can intercept these packets on edge networks to identify system models, OS platforms, and targeting scopes.

### Vendor Proprietary vs. Open Standard

- **CDP:** Designed explicitly by Cisco for the Cisco ecosystem. It operates across switches, routers, firewalls, and voice systems like IP Phones and Cisco Unified Communications Manager (UCM).
- **LLDP:** An open-standard IEEE protocol developed later to allow cross-vendor interoperability between varying network systems (e.g., Cisco, HP, Juniper) and system endpoints like Linux servers.

## How It Works

Devices running discovery protocols generate periodic multi-destination Layer 2 frames out of all active interfaces. Directly connected neighbors intercept these frames, process the embedded metadata fields, populating an internal cache database, and discard the frame without forwarding it downstream.

```text
  [ Cisco Router R1 ]                                                  [ Cisco Switch SW1 ]
   (Fa0/0 Interface)                                                   (Fa0/1 Interface)
           |                                                                   |
           |---- 1. Periodic CDP Frame Broadcast (Every 60s) ----------------->|
           |     [Payload: Naming="R1", Platform="2811", IP="192.168.0.1"]      |
           |                                                                   |
           |                                                               (Logs R1 to
           |                                                               Local Cache)
           |                                                                   |
           |<--- 2. Periodic CDP Frame Broadcast (Every 60s) ------------------|
           |     [Payload: Naming="SW1", Platform="3560", IP="unassigned"]     |
           |                                                                   |
      (Logs SW1 to                                                             
       Local Cache)                                                            
```

## Components / Structure

### Discovery Protocol Operational Properties

| Property | Cisco Discovery Protocol (CDP) | Link Layer Discovery Protocol (LLDP) |
| --- | --- | --- |
| **Standard Type** | Cisco Proprietary | Open Standard (IEEE 802.1AB) |
| **Default State** | Enabled by default on most Cisco platforms. | Platform-dependent (Often disabled by default on legacy IOS). |
| **Packet Interleaving** | Dispatched automatically every 60 seconds. | Dictated by independent protocol timer variables. |
| **Interface Binding** | Operates across physical ports and virtual sub-interfaces. | Restrained exclusively to physical hardware link interfaces. |

## Comparison

### Technical and Feature Differences

| Feature Capability | CDP | LLDP |
| --- | --- | --- |
| **Multi-Vendor Interoperability** | No (Restrained strictly to Cisco devices). | Yes (Universal compatibility across hardware ecosystems). |
| **Multi-Device / Port Support** | Yes (Can track multiple entities via sub-interfaces). | No (Restrained to discovering one distinct device per port). |
| **Host System Integration** | Limited (Does not natively poll standard OS endpoints). | Broad (Natively detects endpoints like Linux servers). |
| **Granular Port Control** | Single control lock (`cdp enable`). | Bidirectional split control (`transmit` and `receive`). |

## Commands (If Applicable)

### Cisco IOS

#### 1. Managing Cisco Discovery Protocol (CDP)

```text
! Disabling CDP globally across the entire system infrastructure
Router(config)# no cdp run

! Re-activating CDP globally
Router(config)# cdp run

! Selectively turning off CDP on an untrusted edge or external-facing interface
Router(config)# interface FastEthernet0/1
Router(config-if)# no cdp enable
```

#### 2. Managing Link Layer Discovery Protocol (LLDP)

```text
! Activating LLDP globally
Router(config)# lldp run

! Granular interface isolation configuration for LLDP
Router(config)# interface FastEthernet0/1
Router(config-if)# no lldp transmit
Router(config-if)# no lldp receive
```

#### 3. Execution Verification Diagnostics

```text
! View global configuration tracking states and active timer intervals
Router# show cdp
Router# show lldp

! Display a scannable summary table outlining all recognized adjacent neighbors
Router# show cdp neighbors
Router# show lldp neighbors

! Pull a highly verbose data transcript including neighboring IP strings and OS versions
Router# show cdp neighbors detail
Router# show lldp neighbors detail
```

## Example

### Analyzing Topology Status Layout Output

When mapping an unfamiliar environment, running `show cdp neighbors` provides a clean, scannable overview of the surrounding topology:

```text
Switch# show cdp neighbors
Capability Codes: R - Router, T - Trans Bridge, B - Source Route Bridge
                  S - Switch, H - Host, I - IGMP, r - Repeater, P - Phone

Device ID        Local Intrfce     Holdtme    Capability   Platform    Port ID
Router           Fas 0/1           142        R            2811        Fas 0/0
Switch           Fas 0/24          178        S            3560        Fas 0/1
```

*Output Field Interpretations:*

- **Device ID:** The administrative hostname assigned to the neighboring device.
- **Local Intrfce:** The physical interface slot on *your* current local system where the cable links.
- **Holdtme:** The remaining cache survival window (seconds) before the entry is flushed if no new packets arrive.
- **Capability:** The operational device role type (e.g., `R` for Router, `S` for Switch).
- **Platform:** The exact commercial hardware model profile of the neighbor node.
- **Port ID:** The precise physical connection interface port on the *neighbor's remote side*.

To obtain the neighbor's administrative IP routing configuration for an SSH hop, execute the detailed breakdown:

```text
Switch# show cdp neighbors detail
-------------------------
Device ID: Router
Entry address(es):
  IP address: 192.168.0.1
Platform: cisco 2811, Capabilities: Router
Interface: FastEthernet0/1, Port ID (outgoing port): FastEthernet0/0
Version :
Cisco IOS Software, 2800 Software (C2811-ADVSECURITYK9-M), Version 12.4(15)T1
```

## Important Notes

- **The Security Balance:** Discovery protocols should generally be disabled on edge ports facing client PCs, public areas, or external networks to keep sensitive infrastructure details hidden from unauthorized network scans.
- **Granular LLDP Tuning:** Unlike CDP's single toggle, LLDP allows you to customize port behavior independently (e.g., allowing a port to listen to incoming server announcements using `lldp receive` while stopping it from broadcasting internal network layouts via `no lldp transmit`).
- **The Importance of Hostnames:** Discovery features pull neighboring configurations in real time. If devices are left with default naming variables like `Router` or `Switch`, mapping the path during an outage becomes significantly more confusing.

## My Takeaways

- CDP and LLDP run completely at Layer 2, meaning they can map neighboring infrastructure nodes even if Layer 3 IP parameters are completely missing or broken.
- CDP is a proprietary protocol tailored for the Cisco ecosystem, whereas LLDP serves as an open-standard utility that can discover independent non-Cisco systems like Linux servers.
- To secure external perimeter links from network footprinting, administrators should systematically disable discovery protocols on public or client-facing interfaces.
- While the basic `neighbors` command generates a high-level summary table of adjacent links, adding the `detail` modifier exposes the exact management IP addresses needed for terminal hops.
- Troubleshooting remote sites becomes significantly faster using discovery commands, allowing engineers to verify physical link connectivity and map device connections entirely through the CLI.
