# Dynamic Routing Protocols & RIPv2 Lab Implementation

## Overview

Dynamic routing protocols exchange network information and select paths using their routing rules. They can update routes after topology changes, reducing the number of routes an administrator must maintain manually.

## Key Concepts

### Dynamic Route Discovery

Routers exchange routing information with neighbors running the same protocol. Each router uses the received information to calculate its paths to remote networks.

### Automatic Reconvergence

When a link fails, recovers, or a subnet is added, the routing protocol exchanges updates and recalculates paths. The update mechanism and convergence time depend on the protocol.

### Next-Hop Behavior

A router's next hop is always its **directly connected neighbor interface** along the path toward the target destination. A router never sets a distant, non-directly connected router as its next hop, as it can only forward packets to an immediate neighbor.

### Route Summarization

Route summarization (or aggregation) combines multiple specific subnets into a single, broader network advertisement (e.g., announcing `10.0.1.0/24` and `10.0.2.0/24` as a single `10.0.0.0/16` route).

* **Memory Optimization:** Shrinks routing tables, resulting in less RAM usage.
* **CPU Compartmentalization:** If a specific link within the summarized block goes down, routers outside that boundary experience no change to their summary route, saving CPU cycles by skipping routing table recalculations.

## How It Works

1. **Adjacency Formation:** Routers establish a peering or neighbor relationship with directly connected devices running the same protocol.
2. **Initial Propagation:** Each router advertises its directly connected networks to its neighbors.
3. **Route Relay:** As routers receive updates, they update their own tables and pass the learned routes to their other neighbors, propagating path details step-by-step across the topology.
4. **Continuous Maintenance:** The network continuously monitors link states. Any failure triggers automated updates, prompting all devices to calculate a new best path.

```text
[ R1 ] --(10.0.0.1/24)-- [ R2 ] --(10.1.0.2/24)-- [ R3 ]
  |                        |
[Networks]               [Table Updates]
10.0.1.0/24              Learns R1 networks via 10.0.0.1
10.0.2.0/24              Passes summaries/routes to R3
                         
                         (R3 sets R2 as next hop, NOT R1)
```

## Components / Structure

### Dynamic Routing Table Entry Layout

| Component | Description | Example |
| --- | --- | --- |
| **Route Source (Code)** | Identifies the protocol used to discover the path. | `R` (RIP) |
| **Destination Network** | The remote subnet address paired with its mask. | `10.0.0.0/24` |
| **Administrative Distance (AD)** | The trustworthiness rating of the routing protocol (lower means more trusted). | `120` (RIP Default) |
| **Metric** | The cost value assigned to the path by the protocol algorithm. | `1` (1 hop away) |
| **Next-Hop IP Address** | The interface IP of the next immediate router along the path. | `via 10.1.0.2` |
| **Outbound Interface** | The local physical port used to forward packets out. | `FastEthernet0/0` |

## Comparison

| Feature | Dynamic Routing Protocols | Static Routing |
| --- | --- | --- |
| **Administration as the network grows** | Exchanges route information automatically. | Requires maintaining the configured routes manually. |
| **Administrative Effort** | Low; paths are discovered automatically. | High; tedious manual entry required on every device. |
| **Topology Adaptability** | Automatic; reconverges and finds alternative paths. | Manual; requires admin intervention to re-route during failures. |
| **Resource Utilization** | High; consumes CPU, memory, and bandwidth for updates. | Extremely low; zero protocol overhead. |
| **Primary Deployment Use** | Core internal enterprise traffic routing. | Special edge scenarios (e.g., single backup route or internet gateway). |

## Commands

### Cisco IOS

#### Enabling RIPv2 Protocol

```text
!! On each Router

Router# configure terminal
Router(config)# router rip
Router(config-router)# version 2
Router(config-router)# no auto-summary
Router(config-router)# network 10.0.0.0
```

#### Real-Time Diagnostics & Table Verification

```text
Router# debug ip rip

// turn off debug mode
Router# undebug all

Router# show ip route
```

## Example

### Multi-Router Template Deployment Workflow

When configuring five routers ($R1$ to $R5$) pre-configured with IP addresses in the `10.0.0.0` space, using a text editor layout allows you to paste configurations across multiple CLI environments quickly while avoiding human typing slips:

```text
! Step 1: Open Terminal Configuration Mode
configure terminal

! Step 2: Initialize RIP and select Classless Version 2
router rip
version 2

! Step 3: Turn off automatic summarization at classful boundaries
no auto-summary

! Step 4: Bind all local interfaces matching the network space
network 10.0.0.0
```

### Verification Pipeline Output

Running `debug ip rip` on a middle router like $R3$ shows dynamic update payloads arriving in real time before verifying the final table state:

```text
R3# debug ip rip
*Jul 17 08:40:20: RIP: received v2 update from 10.1.0.2 on FastEthernet0/0
*Jul 17 08:40:20:      10.0.0.0/24 via 0.0.0.0 in 1 hops
R3# undebug all
All possible debugging has been turned off

R3# show ip route
R        10.0.0.0/24 [120/1] via 10.1.0.2, 00:00:12, FastEthernet0/0
C        10.1.0.0/24 is directly connected, FastEthernet0/0
```

## Important Notes

* **The Next-Hop Validation Boundary:** The next-hop value inside a routing table must always map to a directly connected neighbor interface IP. Routers cannot forward packets directly to a device multiple hops away.
* **The Danger of Debug Streams:** Live `debug` tools execute at high kernel priorities inside Cisco IOS. Leaving them active can flood the terminal, saturate CPU resources, and crash production environments. Always use `undebug all` or `un all` immediately after capturing data.
* **The Dynamic Edge Propagation Strategy:** In enterprise setups, a single default static route (`0.0.0.0/0`) is configured manually on the edge router facing the ISP. This static route is then automatically injected and propagated via the dynamic protocol to all internal routers, removing the need for manual configuration on internal devices.

## My Takeaways

* A successful ping does not show how the route was learned. Check the routing table for leftover static routes.
* Prepare repeated CLI blocks in a text editor, then check the device prompt and command feedback when applying them.
* Verify `no auto-summary` where the lab requires individual subnet routes.
* Stop debugging with `undebug all` after collecting output.
* Inspect next-hop addresses when tracing the forwarding path.
