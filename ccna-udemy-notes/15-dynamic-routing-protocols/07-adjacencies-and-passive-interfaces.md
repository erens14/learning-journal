# Adjacencies and Passive Interfaces

## Overview

Dynamic routing protocols are enabled globally and then activated on selected router interfaces. On an active interface, the router looks for compatible routing-protocol peers on the directly connected link. When a matching peer is found, the routers can exchange routing information.

A passive interface keeps its connected subnet in the routing protocol while preventing routing-protocol traffic from being sent through that interface.

## Adjacency Concept

Protocols such as OSPF and EIGRP use hello packets to discover compatible directly connected peers and form adjacencies. Modern protocols commonly use multicast for this traffic, which is more efficient than broadcast because uninterested hosts do not need to process it.

```text
                 Loopback0
              192.168.1.1/32
                    (passive)
                       |
RA ---- Fa0/0 ---- [ R1 ] ---- Fa1/0 ---- RB
                     |
                   Fa2/0
                     |
             RC: partner router
                 (passive)
```

In this example, R1 forms internal routing relationships with RA and RB. It does not form one with RC because RC belongs to a partner organization.

## Interface States in the Example

| R1 interface | Routing-protocol setting | Result |
| --- | --- | --- |
| `Loopback0` | Passive | Advertises `192.168.1.1/32`; no peer can exist on a logical loopback. |
| `FastEthernet0/0` | Active | Forms an internal relationship with RA and exchanges routes. |
| `FastEthernet1/0` | Active | Forms an internal relationship with RB and exchanges routes. |
| `FastEthernet2/0` | Passive | Advertises its subnet internally but does not send routing information to partner router RC. |

## Why Use Passive Interfaces

### Advertise a Subnet Without Exposing Routing Information

If an interface is not included in the routing protocol, its subnet is not advertised to internal routers. This protects a partner link from routing updates, but it also prevents internal routers from learning a route to that subnet.

A passive interface solves both needs:

```text
R1 advertises 10.0.2.0/24 to RA and RB
R1 does not send routing updates toward RC
```

For limited partner connectivity, static routes can be used instead of sharing internal dynamic-routing information.

### Make Loopbacks Passive

A loopback is logical, so another router cannot be directly connected to it. Making it passive keeps the loopback route advertised while avoiding unnecessary routing-protocol traffic on an interface that can never form a peer relationship.

## RIP Lab Configuration

The lab uses RIPv2 on R1. In RIP, passive-interface suppresses RIP updates on that interface; RIP does not form OSPF/EIGRP-style hello-based adjacencies.

```text
R1# configure terminal
R1(config)# interface loopback 0
R1(config-if)# ip address 192.168.1.1 255.255.255.255

R1(config)# router rip
R1(config-router)# version 2
R1(config-router)# no auto-summary
R1(config-router)# passive-interface loopback0
R1(config-router)# passive-interface fastEthernet2/0
R1(config-router)# network 192.168.1.1
R1(config-router)# network 10.0.0.0
```

`network 10.0.0.0` enables RIP on R1 interfaces in the `10.x.x.x` range. The passive commands must still be present so R1 does not send RIP updates through `Loopback0` or the partner-facing `FastEthernet2/0` interface.

## Lab Verification

```text
R1# show ip protocols
R4# show ip route
R6# show ip route
```

After RIP converges, internal router R4 learns routes to R1's `10.0.1.0/24`, `10.0.2.0/24`, and `192.168.1.1/32` networks. Partner router R6 can run RIP and try to peer with R1, but it does not learn R1's internal routes because R1's partner-facing interface is passive.

## My Takeaways

- Routing protocols run only on interfaces included in their configuration.
- Active internal interfaces exchange routing information with compatible peers.
- Passive interfaces advertise the connected network without sending protocol updates through that interface.
- Loopbacks should be passive because no physical peer can exist on them.
- A passive partner-facing interface helps keep internal routing information private while preserving internal reachability to that link.
