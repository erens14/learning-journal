# Directly Connected and Local Routes

## Overview

A router uses its **Routing Table** to select paths and forward packets. These notes cover **Directly Connected** and **Local** routes, which appear automatically for configured, operational interfaces in the lab.

## Key Concepts

### Directly Connected Routes (`C`)

When an interface is configured with an IP address and successfully transitions to an operational `up/up` state, the router automatically calculates the network address space of that interface. It injects it into the routing table as a Connected route, flagged with the code **`C`**. This allows the router to immediately forward transit traffic bound for any host on that local subnet.

### Local Routes (`L`)

Introduced in Cisco IOS Version 15 and later, Local routes are flagged with the code **`L`**. They represent the specific, individual IP address assigned to the router's own interface. Local routes always look like host routes because they utilize a **`/32`** subnet mask, regardless of the actual subnet mask configured on the physical port.

### Automated Population

Connected and local routes do not require a routing protocol configuration. They are added or removed as the configured interface's operational state changes.

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

Read the route entry using these fields:

```text
 Codes: C - connected, L - local, S - static, R - RIP, M - mobile, B - BGP
        ...

       [1] [2]          [3]               [4]
        C   10.0.1.0/24 is directly connected, FastEthernet1/0
        L   10.0.1.1/32 is directly connected, FastEthernet1/0
```

### Metadata Segment Explanations

* **`[1]` Route code:** `C` identifies a connected subnet; `L` identifies a local interface address.
* **`[2]` Destination prefix:** The network or host address covered by the route.
* **`[3]` Path information:** Describes how the destination is reached.
* **`[4]` Outgoing interface:** The physical or logical interface used for forwarding.

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

* **Setup:** Router `R1` has operational ports `Fa1/0` (`10.0.1.1/24`) and `Fa2/0` (`10.0.2.1/24`). `PC1` uses `10.0.1.10`; `PC2` uses `10.0.2.10`.
* **Route check:** The example routing table contains both `C` and `L` entries:

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

*Initial timeout:* The first ping may show `.` while `R1` resolves `PC1`'s MAC address through ARP. Check the ARP table and subsequent replies before attributing the timeout to a routing fault.

## Important Notes

* **The Line Status Dependency:** An interface configuration alone will not populate the routing table. If an interface is `administratively down` or shows a status state of `down/down`, its corresponding connected and local routing lines are instantly purged from the routing engine.
* **The `/32` Diagnostic Advantage:** In legacy IOS builds (prior to version 15), running `show ip route` only displayed network block paths. Administrators had to execute a separate `show ip interface brief` command to figure out the exact IP address assigned to the router's own interface. Local host routes simplify this tracking process.
* In this lab, the router can forward between its directly connected subnets without additional static or dynamic routes.

## My Takeaways

* An addressed interface must be operational before its connected route is installed. `no shutdown` removes an administrative shutdown; it does not guarantee link readiness or the presence of other routes in the routing table.
* Directly Connected routes (`C`) permit routers to forward data packets out of appropriate ports toward external destination subnets.
* Local host routes (`L`) use a `/32` prefix mask to clearly identify the explicit IP addresses assigned to the router's own local interfaces.
* Cisco IOS Version 15 introduced local host routes to streamline network mapping by eliminating the need to continuously switch between routing and interface configuration tables.
* Connected and local entries change with the operational state of their configured interfaces.
* An empty routing table indicates that the router has no active, configured Layer 3 interfaces and is completely incapable of forwarding transit data frames.
* The initial packet drop commonly observed during baseline network tests is caused by the router performing background ARP resolutions to discover a neighbor's hardware address.
* Host workstations require an explicit Default Gateway entry pointing to the local router interface to send packets outside their immediate local subnet.
