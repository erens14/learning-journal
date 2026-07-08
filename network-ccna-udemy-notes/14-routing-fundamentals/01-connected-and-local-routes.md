# Directly Connected and Local Routes

## Overview

A router's two primary functions are determining the best path to available destination networks and forwarding production traffic along those paths. To make these forwarding decisions, the router utilizes an internal database called a **Routing Table**. The absolute baseline of any routing table consists of routes that the router learns automatically as soon as an administrator configures an IP address on an active interface and brings it up. These are categorized as **Directly Connected** and **Local** routes.

## Key Concepts

### Directly Connected Routes (`C`)

When an interface is configured with an IP address and successfully transitions to an operational `up/up` state, the router automatically calculates the network address space of that interface. It injects it into the routing table as a Connected route, flagged with the code **`C`**. This allows the router to immediately forward transit traffic bound for any host on that local subnet.

### Local Routes (`L`)

Introduced in Cisco IOS Version 15 and later, Local routes are flagged with the code **`L`**. They represent the specific, individual IP address assigned to the router's own interface. Local routes always look like host routes because they utilize a **`/32`** subnet mask, regardless of the actual subnet mask configured on the physical port.

### Automated Population

Unlike static routes or dynamic routing protocols, connected and local routes require no explicit routing protocol configuration lines. They are dynamically generated and removed in perfect synchronization with the physical layer status of their parent interface.

## How It Works

### Interface Activation & Routing Entry Ingestion Workflow

```text
       [ Administrator Configures Port ]
                      |
                      v
      "interface Fa0/0" -> "ip address 10.0.0.1 255.255.255.0"
                      |
                      v
               "no shutdown"
                      |
                      v
  [ Line Protocol & Link State transition to UP/UP ]
                      |
        +-------------+-------------+
        |                           |
        v                           v
 [ Inject Connected Route ]   [ Inject Local Host Route ]
   - Code: C                    - Code: L
   - Network: 10.0.0.0/24       - Specific IP: 10.0.0.1/32
   - Exit Port: Fa0/0           - Exit Port: Fa0/0
```

### Lab Topology Baseline Architecture

```text
  [ PC 1 ]                                  [ Router R1 ]                                  [ PC 2 ]
IP: 10.0.1.10/24                             (IOS Ver 15)                               IP: 10.0.2.10/24
GW: 10.0.1.1                                       |                                       GW: 10.0.2.1
     |                                             |                                             |
     |===== Subnet 10.0.1.0/24 =====> [ Interface Fa1/0 ]                                        |
                                      [ Interface Fa2/0 ] <===== Subnet 10.0.2.0/24 =============|
                                      [ Interface Fa0/0 ] ---> Subnet 10.0.0.0/24 (Management/Lab)
```

## Components / Structure

### Dissecting the Routing Table Syntax Output Line

When running a path inspection lookup, the output block structuralizes metadata segments systematically:

```text
 Codes: C - connected, L - local, S - static, R - RIP, M - mobile, B - BGP
        ...

       [1] [2]          [3]               [4]
        C   10.0.1.0/24 is directly connected, FastEthernet1/0
        L   10.0.1.1/32 is directly connected, FastEthernet1/0
```

### Metadata Segment Explanations

* **`[1]` Route Source Code Identifier:** Maps how the route entries were learned (`C` = Connected Subnet, `L` = Local Host IP).
* **`[2]` Destination Network Prefix Space:** The target IP domain boundaries or exact host allocation addresses.
* **`[3]` Gateway / Path Attribute Status:** Explicit statement tracking how the target environment handles the link.
* **`[4]` Outbound Exit Interface:** The exact physical or logical port hardware slot where frames are pushed out onto the wire.

## Comparison

### Connected (`C`) vs. Local (`L`) Routing Entries

| Performance Metric | Connected Routes (`C`) | Local Routes (`L`) |
| --- | --- | --- |
| **Primary Structural Objective** | Identifies the entire subnet segment attached to the port interface. | Pinpoints the exact IP identity assigned to the local router interface. |
| **Subnet Mask Formatting** | Matches the classful or classless prefix designator defined (e.g., `/24`). | Statically locked to **`/32`** (Host Route) across all installations. |
| **Cisco IOS Release Availability** | Legacy standard; functional across all historic software versions. | Modern standard; introduced globally starting within **IOS Version 15**. |
| **Administrative Utility** | Directs transit traffic heading *through* the router to local hosts. | Identifies traffic terminating *at* the router itself (e.g., management SSH/Ping). |

## Commands (If Applicable)

### Cisco IOS

#### 1. Configuring Router Interface IPs to Generate Routes

```text
Router-R1# configure terminal
Router-R1(config)# interface fastEthernet 0/0
Router-R1(config-if)# ip address 10.0.0.1 255.255.255.0
Router-R1(config-if)# no shutdown
Router-R1(config-if)# exit

Router-R1(config)# interface fastEthernet 1/0
Router-R1(config-if)# ip address 10.0.1.1 255.255.255.0
Router-R1(config-if)# no shutdown
Router-R1(config-if)# exit

Router-R1(config)# interface fastEthernet 2/0
Router-R1(config-if)# ip address 10.0.2.1 255.255.255.0
Router-R1(config-if)# no shutdown
Router-R1(config-if)# end
```

#### 2. Auditing the Routing Tables Engine

```text
! View the complete operational layer of the routing entries database
Router-R1# show ip route

! Quick visual comparison audit of running configurations
Router-R1# show ip interface brief
```

### Host Operating Systems (GNS3 VPCS Simulator)

```bash
# Verify basic workstation endpoint interface IP layout profiles
show ip

# Probe end-to-end bidirectional lane reachability across subnets
ping 10.0.2.10

# Trace the structural path hops through the default gateway node
trace 10.0.2.10
```

## Example

### Comprehensive Lab Operational Validation Transcript

* **Situation Setup:** Router `R1` has ports `Fa1/0` (`10.0.1.1/24`) and `Fa2/0` (`10.0.2.1/24`) operational. `PC1` stands at `10.0.1.10` and `PC2` stands at `10.0.2.10`.
* **Execution Stage:** Reviewing the system table shows the automatic generation of both `C` and `L` indicators:

```text
Router-R1# show ip route
     10.0.0.0/8 is variably subnetted, 6 subnets, 2 masks
C       10.0.0.0/24 is directly connected, FastEthernet0/0
L       10.0.0.1/32 is directly connected, FastEthernet0/0
C       10.0.1.0/24 is directly connected, FastEthernet1/0
L       10.0.1.1/32 is directly connected, FastEthernet1/0
C       10.0.2.0/24 is directly connected, FastEthernet2/0
L       10.0.2.1/32 is directly connected, FastEthernet2/0
```

When running a path tracing probe from `PC1` to `PC2` through the router infrastructure:

```text
PC1> trace 10.0.2.10
as206722.net (10.0.2.10) port=80 ttl=64 1024 ms
1   10.0.1.1   1.231 ms  0.892 ms  0.741 ms  (Default Gateway Interface)
2   10.0.2.10  2.114 ms  1.542 ms  1.421 ms  (Target Destination Node)
```

*Behind-the-Scenes Mechanics Note:* When `R1` attempts to ping `PC1` or forward the initial packet from `PC2` to `PC1`, the very first ICMP echo probe frame may occasionally drop or print an initial timeout symbol (`.`). This is normal behavior: the router must briefly buffer the active traffic packet while it broadcasts a Layer 2 ARP query to discover the physical MAC address matching the host IP destination.

## Important Notes

* **The Line Status Dependency:** An interface configuration alone will not populate the routing table. If an interface is `administratively down` or shows a status state of `down/down`, its corresponding connected and local routing lines are instantly purged from the routing engine.
* **The `/32` Diagnostic Advantage:** In legacy IOS builds (prior to version 15), running `show ip route` only displayed network block paths. Administrators had to execute a separate `show ip interface brief` command to figure out the exact IP address assigned to the router's own interface. Local host routes simplify this tracking process.
* **Immediate Autonomous Inter-VLAN Routing:** As long as a router holds active physical ports or virtual sub-interfaces spanning multiple subnets, it can route traffic between those segments instantly without needing any static routes or dynamic routing protocols.

## My Takeaways

* A router will not route or build an active path matrix until its physical interface status states are brought up via the `no shutdown` command.
* Directly Connected routes (`C`) permit routers to forward data packets out of appropriate ports toward external destination subnets.
* Local host routes (`L`) use a `/32` prefix mask to clearly identify the explicit IP addresses assigned to the router's own local interfaces.
* Cisco IOS Version 15 introduced local host routes to streamline network mapping by eliminating the need to continuously switch between routing and interface configuration tables.
* The routing engine automatically updates, injecting or removing connected and local entries dynamically as interface states change.
* An empty routing table indicates that the router has no active, configured Layer 3 interfaces and is completely incapable of forwarding transit data frames.
* The initial packet drop commonly observed during baseline network tests is caused by the router performing background ARP resolutions to discover a neighbor's hardware address.
* Host workstations require an explicit Default Gateway entry pointing to the local router interface to send packets outside their immediate local subnet.
