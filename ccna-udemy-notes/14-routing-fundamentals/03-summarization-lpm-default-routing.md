# Summarization, LPM, and Default Routing

## Overview

These notes cover four routing decisions: summarizing prefixes, selecting the longest matching prefix, using equal-cost paths, and forwarding through a default route. The lab compares how those choices affect traffic paths.

## Key Concepts

### Route Summarization

The mathematical consolidation of multiple contiguous, sequential subnets into a single, broader network advertisement. Summarizing routes minimizes the total entry count in a routing table, reducing memory consumption and optimizing CPU lookup cycles during packet forwarding.

### Classful vs. Classless (CIDR) Summarizatio

* **Classful Summarization:** Consolidating subnets at traditional class boundaries (e.g., combining `10.1.0.0/24`, `10.1.1.0/24`, and `10.1.2.0/24` into a broad Class B `10.1.0.0/16` boundary).
* **Classless (CIDR) Summarization:** Aggregating specific contiguous subnets using a customized mask boundary (e.g., using a `/22` mask to encompass networks from `10.1.0.0` to `10.1.3.0` exclusively), avoiding the advertisement of unallocated address space.

### Longest Prefix Match (LPM)

The definitive algorithm used by a router to select a path when a packet's destination IP address matches multiple entries in the routing table. The router will always select the route entry with the **most specific mask length (longest prefix)**. This is also called the *specificity rule*.

### Equal-Cost Multi-Path (ECMP) Load Balancing

When a router has multiple independent paths to the exact same destination prefix with identical mask lengths and identical administrative distances/metrics, it populates both next-hops into the routing table and distributes transit traffic across them.

### Per-Flow Hashing Mechanics

To prevent out-of-order packet delivery within a single conversation, Cisco Express Forwarding (CEF) uses a per-flow hashing algorithm for ECMP. It hashes the source and destination IP addresses (and often layer 4 ports). Therefore:

* With an unchanged topology and hash configuration, the same flow normally uses the same ECMP next hop. Path changes can remap it.
* A different destination can change the hash input, but may still select the same next hop. Hash collisions and platform-specific inputs prevent a guarantee of alternating paths.

### Default Route (`0.0.0.0/0`)

A catch-all static entry known as the **Gateway of Last Resort**. It matches all possible IP spaces. If a packet's target destination fails to match any specific entry in the routing table, it falls back to this route (typically pointing out toward an ISP).

### Asynchronous (Asymmetric) Routing

Outbound and return packets take different paths. This can complicate troubleshooting and affect stateful firewalls along those paths.

## How It Works

### Five-Router Multi-Path Lab Topology Layout

The lab uses five routers with top and bottom paths between the internal networks and the ISP connection.

```text
                                  [ TOP PATH ]
                    ─── Link 10.0.0.0/24 ───> [ Router R2 ]
                   │                             │ Link 10.1.0.0/24
                   │                             v
             [ Router R1 ]                  [ Router R3 ]
             (Internal Core)                     │ Link 10.1.1.0/24
                   │                             v
                   │                        [ Router R4 ] ───> [ ISP Edge ] (203.0.113.2)
                   │                             ^             (Default Gateway)
                   │                             │ Link 10.1.2.0/24
                    ─── Link 10.0.3.0/24 ───> [ Router R5 ]
                                  [ BOTTOM PATH ]
```

### Flow Architecture & Hashing Realities

PC1 (`10.0.1.10`), behind R1, uses the ECMP paths to reach the example external web servers:

```text
[ PC1: 10.0.1.10 ] ───> [ Router R1 (Evaluates Default Routes) ]
                             │
                             ├─ Flow A to 50.50.50.50 ──> Hashes to R5 (Bottom Path) ──> R4 ──> ISP
                             └─ Flow B to 50.50.50.51 ──> Hashes to R2 (Top Path)    ──> R3 ──> R4 ──> ISP
```

## Components / Structure

### Static Route Command Parameters & Routing Table Codes

Static routes are managed using the standard configuration syntax: `ip route <network-prefix> <subnet-mask> <next-hop-ip>`. When analyzing the operational routing table using `show ip route`, special flag codes denote the status of these paths:

| Table Code / Flag | Parameter Name | Technical Definition |
| --- | --- | --- |
| `C` | Connected Route | An interface network automatically injected when an IP is configured and status is up/up. |
| `S` | Static Route | A remote destination path manually defined by a network administrator. |
| `S*` | Candidate Default | Indicates that the static route is configured as `0.0.0.0/0`, acting as the gateway of last resort. |
| `<network-prefix>` | Destination Target | The remote subnet or consolidated summary network target block. |
| `<subnet-mask>` | Mask Subsystem | The bitmask length determining the prefix size (`/16`, `/24`, etc.). |
| `<next-hop-ip>` | Gateway Interface | The adjacent neighbor router interface IP address designated to receive the packet next. |

## Comparison

### Overlapping Static Prefixes & Forwarding Decisions

When multiple static routes coexist inside a routing table, the router determines path selection hierarchically based on prefix length symmetry:

| Active Routing Table Entries on R1 | Packet Destination Target | Winning Route Selection | Path Taken & Operational Reasoning |
| --- | --- | --- | --- |
| `10.1.0.0/16` via R2 (`10.0.0.2`) | `10.1.1.10` | **`10.1.0.0/16`** | **Top Path via R2:** Only matches the broad summary route block; falls within the classful boundary. |
| `10.1.0.0/16` via R2 (`10.0.0.2`) | | | |

**AND** `10.1.3.0/24` via R5 (`10.0.3.2`) | `10.1.3.25` | **`10.1.3.0/24`** | **Bottom Path via R5:** Longest Prefix Match wins. The `/24` prefix is longer and more specific than the `/16` summary route. |
| `0.0.0.0/0` via R2 (`10.0.0.2`)

**AND** `0.0.0.0/0` via R5 (`10.0.3.2`) | `50.50.50.50` | **Both Routes (Tie)** | **ECMP Load Balancing:** Prefixes and masks are identical. Traffic balances across both paths using per-flow hashing rules. |
| `10.1.0.0/16` via R2 (`10.0.0.2`)

**AND** `0.0.0.0/0` via R4 (`203.0.113.2`) | `10.1.2.15` | **`10.1.0.0/16`** | **Top Path via R2:** The internal summary route (`/16`) is more specific than the default gateway route (`/0`). |

## Commands (If Applicable)

### Cisco IOS Configuration & Verification Commands

#### 1. Tearing Down Individual /24 Static Lines

```text
Router-R1# configure terminal
Router-R1(config)# no ip route 10.1.0.0 255.255.255.0 10.0.0.2
Router-R1(config)# no ip route 10.1.1.0 255.255.255.0 10.0.0.2
Router-R1(config)# no ip route 10.1.2.0 255.255.255.0 10.0.0.2
Router-R1(config)# no ip route 10.1.3.0 255.255.255.0 10.0.0.2

```

#### 2. Implementing an Aggregated Class B Summary Route

```text
! Replaces the four individual /24 routes with a single classful /16 statement
Router-R1(config)# ip route 10.1.0.0 255.255.0.0 10.0.0.2
```

#### 3. Configuring a Tight Classless (CIDR) Summary Route

```text
! Aggregates subnets 10.1.0.0 through 10.1.3.0 specifically using a /22 boundary mask
Router-R1(config)# ip route 10.1.0.0 255.255.252.0 10.0.0.2
```

#### 4. Interface Activation and Edge Default Routing on R4

```text
Router-R4(config)# interface fastEthernet 3/0
Router-R4(config-if)# ip address 203.0.113.1 255.255.255.0
Router-R4(config-if)# no shutdown
Router-R4(config-if)# exit
Router-R4(config)# ip route 0.0.0.0 0.0.0.0 203.0.113.2
```

#### 5. Deploying Internal Equal-Cost Multi-Path (ECMP) Default Routes on R1

```text
! Configure dual next-hops with identical zero-prefixes to force load balancing
Router-R1(config)# ip route 0.0.0.0 0.0.0.0 10.0.0.2
Router-R1(config)# ip route 0.0.0.0 0.0.0.0 10.0.3.2

```

#### 6. Routing Table Verification

```text
! Verify complete routing metrics and check if the Gateway of Last Resort is active
Router-R1# show ip route
```

## Example

### Lab Trace Scenario: Asymmetric Routing and ECMP Verification

#### Part 1: Observing Asymmetric Flow

Before a specific return path was fixed on R1, an extended trace execution from R5 toward PC1 (`10.0.1.10`) with a designated source interface of `10.1.3.2` revealed an asymmetric traffic loop:

* **Outbound Path:** R5 forwarded directly to R1 via link `10.0.3.1` because it possessed a direct static entry.
* **Return Path:** When PC1 replied, R1 evaluated its routing table, matched its broad summary entry (`10.1.0.0/16`), and forwarded the return packet to R2 (`10.0.0.2`). The traffic then traversed R2 $\rightarrow$ R3 $\rightarrow$ R4 $\rightarrow$ R5.

#### Part 2: Forcing Symmetric Path via Longest Prefix Match

To optimize the path, the administrator injected a specific `/24` route onto R1:

```text
Router-R1(config)# ip route 10.1.3.0 255.255.255.0 10.0.3.2
```

When PC1 subsequently sends packets to `10.1.3.2`, R1 identifies two matches: `10.1.0.0/16` and `10.1.3.0/24`. The router selects the **`10.1.3.0/24`** path because its prefix length is longer and more specific, driving symmetric forwarding directly back to R5.

#### Part 3: Verifying Per-Flow Hashing on ECMP

With dual default routes configured on R1 pointing to both R2 (`10.0.0.2`) and R5 (`10.0.3.2`), traceroute outputs from PC1 demonstrate how the hashing engine functions:

* **Execution Trace 1:**

```text
PC1> traceroute 50.50.50.50
1  10.0.1.1  (R1 Gateway)
2  10.0.3.2  (R5 - Bottom Path Chosen by Hash)
3  10.1.2.1  (R4 Edge)
```

The demonstrated trace to `50.50.50.50` used the bottom path via R5. Repeated traceroute probes can vary transport fields, and their selected path depends on the platform's hash inputs and current forwarding state.

* **Execution Trace 2:**

```text
PC1> traceroute 50.50.50.51
1  10.0.1.1  (R1 Gateway)
2  10.0.0.2  (R2 - Top Path Chosen by Hash)
3  10.1.0.1  (R3)
4  10.1.1.1  (R4 Edge)
```

The second demonstrated destination used the top path via R2. Changing an address can select another path, but a one-digit change does not guarantee it.

## Important Notes

* Per-packet load balancing can reorder packets when paths have different delays. Keeping a flow on one path reduces that source of reordering.
* **The Default Route Asterisk:** In the Cisco IOS routing table output, a default static route is flagged as `S*`. The asterisk symbol explicitly marks the entry as a candidate for the **Gateway of Last Resort**.
* **Summarization Risk:** Classful summary masks (like `/16` on a `10.1.0.0` space) advertise a massive block of addresses. If some subnets within that block are attached to alternative paths or are unallocated, broad summarization can misroute data or create routing black holes.
* Different outbound and return paths can work, but stateful firewalls on those paths may affect communication.

## My Takeaways

* Directly connected paths populate a routing table automatically when an interface is up/up, but routing packets to remote subnets requires a manual static route or a dynamic protocol.
* A summary can replace multiple route entries with one covering prefix.
* Classless CIDR summarization offers precise boundary definitions (like a `/22` mask), preventing a router from accidentally advertising unallocated or incorrect IP ranges.
* When a destination IP matches multiple entries in a routing table, the Longest Prefix Match rule ensures the entry with the longest subnet mask always wins.
* Equal-Cost Multi-Path (ECMP) routing allows a router to automatically balance traffic across multiple exit gateways when paths share identical network prefixes and mask lengths.
* In the demonstrated CEF behavior, per-flow hashing keeps a flow on one ECMP path and reduces reordering caused by different path delays.
* A default route (`0.0.0.0 0.0.0.0`) handles destinations without a more specific match; the lab points it toward the provider.
* Asymmetric routing occurs naturally when outbound and return path choices differ, requiring systematic verification across all intermediary devices during troubleshooting loops.
* Real-time diagnostics like tracing distinct external destinations (`50.50.50.50` vs. `50.50.50.51`) allow engineers to quickly verify if an ECMP multi-path load balancer is operating correctly.
