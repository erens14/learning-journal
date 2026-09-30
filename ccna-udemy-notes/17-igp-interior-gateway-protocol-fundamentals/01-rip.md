# RIP (Routing Information Protocol)

## Overview

RIP is a distance vector routing protocol. It learns routes from information supplied by neighboring routers and chooses paths using hop count. This lecture uses RIPv2 to connect five routers, then adds manual summaries, an advertised default route, and a passive interface toward the service provider.

## RIP Basics

| Property | Value / behavior |
| --- | --- |
| Protocol type | Distance vector: learns reachability through neighboring routers, sometimes called routing by rumour. |
| Metric | Hop count; fewer hops are preferred. |
| Maximum usable hop count | 15, which limits network size. |
| Default administrative distance | 120 on Cisco IOS. |
| Equal Cost Multi Path (ECMP) | Up to four equal-cost paths by default in the lecture's Cisco environment. |

For R1 to reach a network through R2, R3, and R4, the route has a hop count of three:

```text
 [R1] ------ [R2] ------ [R3] ------ [R4] ------ 10.1.0.0 network
             hop 1       hop 2       hop 3
```

The hop limit restricts scalability. The lecture uses RIP mainly as a small-network, lab, and demonstration protocol.

## RIPv1, RIPv2, and RIPng

| Feature | RIPv1 | RIPv2 |
| --- | --- | --- |
| Subnet masks included in updates | No | Yes |
| Variable Length Subnet Masks (VLSM) | Not supported | Supported |
| Update delivery | Broadcast | Multicast to `224.0.0.9` |
| Authentication | Not supported | Supported |

The lecture describes periodic routing updates every 30 seconds. Broadcast updates reach all hosts on the subnet; multicast targets devices listening for RIP updates.

RIPv1 does not carry mask information, so it cannot describe a mixture of subnet sizes the way RIPv2 can. The lecture contrasts consistently sized `/28` subnets with a mixture of `/24`, `/28`, and `/30` subnets. Consistent subnetting still depends on RIPv1's classful mask assumptions; it is not a guarantee that any topology will work.

RIPv2 authentication lets routers validate routing updates using matching authentication settings. RIP exchanges routing updates; it does not use hello messages or establish an OSPF/EIGRP-style adjacency. The transcript's references to RIP hellos and adjacency formation should be read as exchanging routing information with neighbors.

RIPng means RIP next generation and supports IPv6. The lecture mentions it briefly and focuses its configuration on RIPv2.

## Basic RIPv2 Configuration

All internal interfaces in the lab have addresses beginning with `10`. Apply this configuration to each router, R1 through R5:

```text
Router# configure terminal
Router(config)# router rip
Router(config-router)# version 2
Router(config-router)# no auto-summary
Router(config-router)# network 10.0.0.0
```

| Command | Purpose |
| --- | --- |
| `router rip` | Start or enter the RIP routing process. |
| `version 2` | Explicitly select RIPv2. |
| `no auto-summary` | Disable automatic summaries at classful network boundaries. |
| `network 10.0.0.0` | Enable RIP on interfaces in the `10.0.0.0` major network and include their connected networks in RIP advertisements. |

### The `network` Statement

RIP's `network` command references the classful major network and takes no subnet mask or wildcard mask.

For an interface with address `10.1.1.1/24`, use:

```text
Router(config-router)# network 10.0.0.0
```

The command selects interfaces in that major network. It does not mean that RIPv2 must advertise every selected subnet as `/8`; with automatic summarization disabled, updates retain the actual subnet masks.

## Automatic Summarization

In the lecture's IOS configuration, automatic summarization is enabled by default. It summarizes subnet routes to their classful major network when advertising across a classful network boundary.

| Interface address from the lecture | Actual connected subnet | Classful summary when advertised across a major-network boundary |
| --- | --- | --- |
| `192.168.10.1/30` | `192.168.10.0/30` | `192.168.10.0/24` |
| `172.16.10.1/30` | `172.16.10.0/30` | `172.16.0.0/16` |

The boundary condition matters: enabling RIP on an interface does not automatically replace every advertisement of that subnet with a classful summary. [Cisco RIP configuration guide](https://www.cisco.com/c/en/us/td/docs/ios-xml/ios/iproute_rip/configuration/xe-16-8/irr-xe-16-8-book/irr-cfg-info-prot.html).

If the actual topology does not match the summary, routers can send traffic toward a path that cannot reach the destination. Disable automatic summarization in this lab:

```text
Router(config)# router rip
Router(config-router)# no auto-summary
```

Manual summaries can still be configured where they match the intended network design.

## Lab Topology and Initial Route Choice

The transcript describes two paths between R1 and the `10.1.X.X` networks on the left:

```text
 [Service provider]
 203.0.113.2
         |
         | R4 FastEthernet3/0
         |
       [R4] -------- [R3] -------- [R2] -------- [R1]
          \                                      /
           \--------------- [R5] ---------------/

 From R1 toward 10.1.2.0/24:
   Top path:    R1 -> R2 -> R3 -> R4   = 3 hops
   Bottom path: R1 -> R5 -> R4         = 2 hops
```

Only interface labels and addresses stated in the transcript are included below:

| Router | Interface | Direction / known address |
| --- | --- | --- |
| R1 | `FastEthernet0/0` | Toward R2, next hop `10.0.0.2`. |
| R1 | `FastEthernet3/0` | Toward R5, next hop `10.0.3.2`. |
| R2 | `FastEthernet0/0` | Toward R1, on the `10.0.X.X` side. |
| R2 | `FastEthernet1/0` | Toward R3, on the `10.1.X.X` side. |
| R5 | `FastEthernet3/0` | Toward R1, on the `10.0.X.X` side. |
| R5 | `FastEthernet2/0` | Toward R4, on the `10.1.X.X` side. |
| R4 | `FastEthernet3/0` | Toward the service provider at `203.0.113.2`. |

### Verify the Initial Configuration

Before enabling RIP, the lab checks:

```text
Router# show ip protocols
Router# show ip route
```

Initially, no dynamic routing protocol is running, and the routing table contains connected and local routes.

After applying the RIPv2 configuration on all five routers, allow time for updates to propagate. The lab initially waits around a minute before checking again.

- R5 learns the individual remote `10.1.X.X` and `10.0.X.X` networks.
- R1 retains its connected/local networks and learns the remote `10.1.X.X` networks through RIP.
- For `10.1.2.0/24`, R1 prefers the bottom path through R5 because two hops are better than three.

The selected route on R1 has these values:

| Field | Value |
| --- | --- |
| Destination | `10.1.2.0/24` |
| Route source | RIP, shown by code `R` |
| AD / metric | `120 / 2` |
| Next hop | `10.0.3.2` on R5 |
| Outgoing interface | `FastEthernet3/0` |

## Manual Route Summarization

A manual summary advertises one larger prefix in place of its covered individual routes on the selected interface. This reduces the number of advertised entries and the receiving router's routing-table size. It can also contain the effect of changes inside the summarized part of the network.

Configure the summary on the interface **sending the advertisement**, which may be opposite the direction used to reach those networks.

### R2 Advertises the Right-Side Networks to R3

The theory example replaces these advertisements:

```text
 10.0.0.0/24
 10.0.1.0/24
 10.0.2.0/24
       |
       +---- advertised as 10.0.0.0/16
```

```text
 [R3] ------- Fa1/0 [R2] Fa0/0 ------- [R1 / 10.0.X.X networks]
      <------------- summary advertisement
                     10.0.0.0/16
```

R2 reaches those networks through `FastEthernet0/0`, but advertises their summary to R3 through `FastEthernet1/0`:

```text
R2# configure terminal
R2(config)# interface FastEthernet1/0
R2(config-if)# ip summary-address rip 10.0.0.0 255.255.0.0
```

The `/16` is the lecture's chosen summary, not the smallest possible aggregate of those three `/24` networks.

### Summarize in Both Directions on R2 and R5

| Router | Outgoing advertisement interface | Summary | Receiving side |
| --- | --- | --- | --- |
| R2 | `FastEthernet0/0` | `10.1.0.0/16` | R1 |
| R2 | `FastEthernet1/0` | `10.0.0.0/16` | R3 |
| R5 | `FastEthernet3/0` | `10.1.0.0/16` | R1 |
| R5 | `FastEthernet2/0` | `10.0.0.0/16` | R4 |

R2 configuration:

```text
R2# configure terminal
R2(config)# interface FastEthernet0/0
R2(config-if)# ip summary-address rip 10.1.0.0 255.255.0.0
R2(config-if)# exit
R2(config)# interface FastEthernet1/0
R2(config-if)# ip summary-address rip 10.0.0.0 255.255.0.0
```

R5 configuration:

```text
R5# configure terminal
R5(config)# interface FastEthernet3/0
R5(config-if)# ip summary-address rip 10.1.0.0 255.255.0.0
R5(config-if)# exit
R5(config)# interface FastEthernet2/0
R5(config-if)# ip summary-address rip 10.0.0.0 255.255.0.0
```

### Summary Routes and ECMP on R1

After convergence, the lab shows `10.1.0.0/16` on R1 in place of the separate remote `10.1.X.X/24` entries. The summary is learned through both directly neighboring routers with a metric of one:

```text
                    [R2: 10.0.0.2]
                   /              summary 10.1.0.0/16, metric 1
 [R1] ------------<
                   \              summary 10.1.0.0/16, metric 1
                    [R5: 10.0.3.2]
```

| Path on R1 | Next hop | Interface | Observed summary metric |
| --- | --- | --- | --- |
| Via R2 | `10.0.0.2` | `FastEthernet0/0` | 1 |
| Via R5 | `10.0.3.2` | `FastEthernet3/0` | 1 |

Both paths enter the routing table and support equal-cost load balancing. These are the summary metrics observed in this lab; they do not mean every destination inside the summary is physically one hop away.

### Restarting RIP in the Demo

The instructor removes and recreates RIP on R1 to discard old routes and speed up the demonstration:

```text
R1# configure terminal
R1(config)# no router rip
R1(config)# router rip
R1(config-router)# version 2
R1(config-router)# no auto-summary
R1(config-router)# network 10.0.0.0
```

`no router rip` removes the RIP process and its configuration. Learned routes are lost until RIP learns them again, so connectivity can be interrupted. The demo later repeats this step after other changes; in a production network, allow convergence instead of routinely restarting the protocol. Restarting R1 does not make updates propagate instantly through all other routers.

## Default Route Injection

R4 connects to the service provider. Configure one static default route there, then advertise a default through RIP so the internal routers can learn it:

```text
R4# configure terminal
R4(config)# ip route 0.0.0.0 0.0.0.0 203.0.113.2
R4(config)# router rip
R4(config-router)# default-information originate
```

The static route sends traffic without a more specific match to provider next hop `203.0.113.2`. `default-information originate` advertises a default route into RIP. This avoids configuring a separate static default on every internal router.

```text
 Traffic toward Internet:
 [R1] ------ [R5] ------ [R4] ------ [Provider: 203.0.113.2]

 Default-route advertisements travel inward:
 [R1] <----- [R5] <----- [R4]
 [R1] <----- [R2] <----- [R3] <----- [R4]
```

R4 advertises the default to R3 and R5, which propagate it farther into the internal network.

On R1, the lecture verifies:

| Field | Value |
| --- | --- |
| Destination | `0.0.0.0/0` |
| How R1 learns it | RIP |
| AD / metric | `120 / 2` |
| Next hop | `10.0.3.2` on R5 |
| Outgoing interface | `FastEthernet3/0` |

The default is static on R4 but RIP-learned on R1. Calling R1's entry a static route would confuse its origin with how R1 received it. The lab also checks R2 to confirm the default is propagating beyond one router.

## Advertise the Provider Network Internally

The provider-facing connected network, `203.0.113.0`, is initially absent from RIP advertisements because only `network 10.0.0.0` is configured.

R4 can include that connected network in RIP while suppressing outbound updates toward the provider:

```text
R4# configure terminal
R4(config)# router rip
R4(config-router)# passive-interface FastEthernet3/0
R4(config-router)# network 203.0.113.0
```

```text
                        Internal RIP routers
                              ^
                              | learn 203.0.113.0 network
                            [R4]
                              |
                     FastEthernet3/0: passive
                              |
                              X no outbound RIP updates
                              |
                         [Provider]
                         203.0.113.2
```

- The `network` statement includes the provider-facing connected network in RIP.
- `passive-interface` stops R4 sending RIP updates out `FastEthernet3/0`.
- Internal routers can still learn that network through R4's internal RIP interfaces.
- The interface remains available for normal IP forwarding; making it passive does not shut down the Internet link.

After convergence, check R1 for the newly learned `203.0.113.0` network. The transcript does not specify its subnet mask, so no mask is assumed here.

## Verification Commands

```text
Router# show ip protocols
Router# show running-config | section rip
Router# show ip route
Router# show ip rip database
```

| Command | What to inspect |
| --- | --- |
| `show ip protocols` | RIP version and settings, participating interfaces, configured networks, maximum paths, routing-information sources, and AD. |
| `show running-config \| section rip` | The RIP process configuration without scrolling through the whole running configuration. |
| `show ip route` | Routes installed in the routing table, including the learned subnets, summaries, and default. |
| `show ip rip database` | RIP's known route information when an expected route is absent from the routing table. |

The lecture's protocol output lists `FastEthernet0/0`, `FastEthernet1/0`, `FastEthernet2/0`, and `FastEthernet3/0`, a maximum of four paths, the `10.0.0.0` network, and routing-information sources `10.0.0.2` and `10.0.3.2`. These sources identify routers supplying updates, not established hello-based adjacencies.

In `show ip route`, code `R` identifies a RIP route. The bracketed values are `[AD/metric]`: for RIP, the second number is hop count. Also inspect the next-hop address, route-update age, and outgoing interface.

If an expected route is missing, use the RIP database to distinguish a route that RIP has learned but not installed from one that RIP does not currently know. Receiving updates alone does not guarantee that every expected route was advertised or selected.

## My Takeaways

- RIP measures distance in routers crossed. Its hop limit makes it unsuitable for a large routing domain.
- Use RIPv2 for subnet-mask information, VLSM, multicast updates, and authentication support.
- The classful `network` statement selects participating interfaces; the advertised prefix length is a separate issue.
- Place a manual summary on the interface sending it to the receiving router.
- Summarization changes what the receiving router knows and can change the visible metrics and equal-cost paths.
- Keep the static Internet default on the edge router and distribute a default through RIP to internal routers.
- A passive RIP interface suppresses outbound routing updates while preserving normal packet forwarding.
- Verify configuration, the routing table, and RIP's database separately. Wait for convergence before treating a missing route as a configuration failure.
