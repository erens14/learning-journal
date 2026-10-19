# Static Routing and Multi-Router Lab Deployment

## Overview

**Static Routing** lets an administrator configure routes to remote networks manually. This lab follows multi-hop routes and investigates a ping failure caused by a missing return route.

## Key Concepts

### Manual Remote Path Definition

Static routes provide manual control without exchanging dynamic routing updates. The lesson uses them in a fixed topology; an administrator must account for path changes and failures.

### Next-Hop Adjacency

A static route can only point to a next-hop IP address that resides on an **immediately adjacent, directly connected network segment**. A router cannot forward a frame directly to a next-hop IP multiple hops away; it must hand the packet off to its closest immediate neighbor interface.

### Asymmetric Path Isolation & Bidirectional Reliance

A ping needs a route for the ICMP Echo Request and a return route for the Echo Reply. A missing return route can therefore cause a timeout even when the request reaches its destination.

### Active ICMP Debugging

`show ip route` displays installed routes. The lab also uses `debug ip icmp` to observe whether the Echo Request arrives at the destination router while investigating the missing return route.

## How It Works

### Three-Router Lab Topology Layout

```text
  [ PC 1 ] (10.0.1.10/24)
     │
     ├─── Subnet 10.0.1.0/24 ───┐
  [ PC 2 ] (10.0.2.10/24)        v
     │                      [ Router R1 ]
     └─── Subnet 10.0.2.0/24 ───┤
                                │ Interface Fa0/0: 10.0.0.1
                                └─── Link Subnet 10.0.0.0/24 ───┐
                                                                v
                                                          [ Router R2 ] (Transit Hub)
                                                                │ Interface Fa1/0: 10.1.0.2
                                                                └─── Link Subnet 10.1.0.0/24 ───┐
                                                                                                v
                                                                                          [ Router R3 ]
                                                                                                │ Interface Fa0/0: 10.1.1.1
                                                                                                └─── Subnet 10.1.1.0/24
                                                                                                        │
                                                                                                    [ PC 3 ] (10.1.1.10/24)
```

## Components / Structure

### Static Route Statement Parameter Mapping

Configure the lab's static routes in global configuration mode: `ip route <network> <mask> <next-hop>`.

| Parameter Element | Component Context | Technical Operational Purpose |
| --- | --- | --- |
| **`ip route`** | Core Global Command | Invokes the static path generation engine within Cisco IOS. |
| **`10.1.0.0`** | Destination Prefix | The specific remote subnet address block the local router needs to reach. |
| **`255.255.255.0`** | Subnet Mask | Defines the boundaries and exact host capacity of the target network block. |
| **`10.0.0.2`** | Next-Hop Gateway IP | The active interface IP on the adjacent neighbor router that receives the packet next. |

## Commands (If Applicable)

### Cisco IOS Multi-Router Complete Lab Script

#### 1. Router R1 Configuration

```text
! Bring up local interfaces and establish static routes to networks behind R2 and R3
Router-R1# configure terminal
Router-R1(config)# interface fastEthernet 0/0
Router-R1(config-if)# ip address 10.0.0.1 255.255.255.0
Router-R1(config-if)# no shutdown
Router-R1(config-if)# exit

! Add static routes targeting remote subnets, pointing to R2's connecting link interface
Router-R1(config)# ip route 10.1.0.0 255.255.255.0 10.0.0.2
Router-R1(config)# ip route 10.1.1.0 255.255.255.0 10.0.0.2
Router-R1(config)# end
Router-R1# copy running-config startup-config
```

#### 2. Router R2 (Transit Node) Configuration

```text
Router-R2# configure terminal
Router-R2(config)# interface fastEthernet 0/0
Router-R2(config-if)# ip address 10.0.0.2 255.255.255.0
Router-R2(config-if)# no shutdown
Router-R2(config-if)# exit

Router-R2(config)# interface fastEthernet 1/0
Router-R2(config-if)# ip address 10.1.0.2 255.255.255.0
Router-R2(config-if)# no shutdown
Router-R2(config-if)# exit

! Map static paths pointing back to R1's internal subnets and down to R3's segment
Router-R2(config)# ip route 10.0.1.0 255.255.255.0 10.0.0.1
Router-R2(config)# ip route 10.0.2.0 255.255.255.0 10.0.0.1
Router-R2(config)# ip route 10.1.1.0 255.255.255.0 10.1.0.1
Router-R2(config)# end
Router-R2# copy running-config startup-config
```

#### 3. Router R3 Configuration

```text
Router-R3# configure terminal
Router-R3(config)# interface fastEthernet 0/0
Router-R3(config-if)# ip address 10.1.0.1 255.255.255.0
Router-R3(config-if)# no shutdown
Router-R3(config-if)# exit

Router-R3(config)# interface fastEthernet 1/0
Router-R3(config-if)# ip address 10.1.1.1 255.255.255.0
Router-R3(config-if)# no shutdown
Router-R3(config-if)# exit

! Configure static routes to reach the intermediate link and R1's downstream networks via R2
Router-R3(config)# ip route 10.0.0.0 255.255.255.0 10.1.0.2
Router-R3(config)# ip route 10.0.1.0 255.255.255.0 10.1.0.2
Router-R3(config)# ip route 10.0.2.0 255.255.255.0 10.1.0.2
Router-R3(config)# end
Router-R3# copy running-config startup-config
```

#### 4. Path Analysis and Diagnostic Utilities

```text
! View the state of the active routing engine table
Router-R3# show ip route

! Enable real-time console tracing for inbound and outbound ICMP events
Router-R3# debug ip icmp

! Turn off all active tracking debug mechanisms completely
Router-R3# undebug all
```

## Example

### Troubleshooting Lab Asymmetry Using Active Debugging

* **The Problem:** R1 has static routes to `10.1.1.0/24` pointing to R2 (`10.0.0.2`). However, when R1 runs `ping 10.1.1.1` to check connectivity to R3's local interface, the ping consistently times out and fails.
* **The Investigation:** To trace the packet path, the engineer logs onto R3 and runs `debug ip icmp` before launching a second ping from R1.

#### Real-Time Console Output Capture on R3

```text
R3# debug ip icmp
ICMP packet debugging is on
R3#
ICMP: echo request rcvd, src 10.0.0.1, dst 10.1.1.1
ICMP: echo request rcvd, src 10.0.0.1, dst 10.1.1.1
```

#### Diagnostic Evaluation

1. The debug log proves that R1’s outbound configuration is functional. The ICMP echo request successfully traverses R1 $\rightarrow$ R2 $\rightarrow$ R3 and hits R3's interface.
2. However, R3 fails to generate a corresponding `echo reply sent` log.
3. Running `show ip route` on R3 reveals the root cause: R3 does not have a static route for the source network `10.0.0.0/24`. As a result, R3 has no idea how to route return packets back to R1 and drops them instantly.

Adding the missing return route on R3 (`ip route 10.0.0.0 255.255.255.0 10.1.0.2`) balances the path topology, allowing subsequent pings to complete successfully.

## Important Notes

* Verify the routes used in both directions. Outbound reachability alone is insufficient for a successful ping.
* **Adjacency Constraints:** Next-hop targets must be immediate neighbors. If a next-hop IP address cannot be resolved to a locally attached interface segment, Cisco IOS will mark the static route as unusable and exclude it from the routing table.
* Debug logging adds processing load. Use it selectively and stop it with `undebug all` after collecting the needed output.

## My Takeaways

* Directly connected interfaces allow a router to pass traffic locally, but routing to non-contiguous remote subnets requires a dynamic protocol or manual static routes.
* A static route acts as a fixed, rigid path instruction that cannot automatically adjust or dynamically re-route traffic around a network failure.
* Next-hop configurations must point directly to an adjacent neighbor interface IP address that is reachable over a local, directly connected link segment.
* Troubleshooting network connectivity requires verifying both the outbound and return paths; a missing return path will cause packets to drop at the destination.
* Successful network communication requires complete path alignment across all intermediate routers; every single transit node along a path must know how to forward the packet.
* `debug ip icmp` provides real-time visibility into the packet path by explicitly tracking whether ICMP echo request frames successfully reach a remote interface.
* Run `undebug all` when finished to stop active debug output.
* Run traceroute from the affected host to identify responding hops and narrow the investigation. A missing reply alone does not identify the fault.
