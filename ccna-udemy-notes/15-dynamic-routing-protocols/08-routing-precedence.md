# Routing Precedence

## Overview

Routing precedence explains how a router chooses a route for a packet. The decision has two related parts:

1. For routes to the **same network and prefix**, the router keeps the route with the best Administrative Distance (AD), then metric.
2. When forwarding a packet, the router checks all matching routes and uses the **longest prefix match** first.

The order to remember is:

```text
Longest Prefix Match -> Administrative Distance -> Metric
```

## Transcript Topology

The lecture uses this intentionally unrealistic topology to demonstrate route precedence. R1 learns overlapping routes from several neighbors running different protocols; this is a teaching scenario, not a production design.

```text
R2 (RIP)    172.16.0.2  ---- Gi0/0 \
R3 (OSPF)   172.16.0.6  ---- Gi0/1  \
R4 (EIGRP)  172.16.0.10 ---- Gi0/2 --- [ R1 ] --- Gi0/4 --- 192.168.0.0/30
R5 (EIGRP)  172.16.0.14 ---- Gi0/3  /
```

R2, R3, R4, and R5 advertise routes to R1. The later examples use their different protocol sources, AD values, metrics, and overlapping prefixes to show how R1 selects an installed route and forwards each packet.

## How a Router Learns Routes

A router can learn routes from these sources:

| Route type | How it is learned | Example on R1 |
| --- | --- | --- |
| Connected route | An IP address is configured on an interface | `172.16.0.0/30` on `Gig0/0` |
| Local route | The exact IP address configured on an interface | `172.16.0.1` on `Gig0/0` |
| Static route | Manually configured by an administrator | `192.168.100.0/24` via `172.16.0.2` |
| Dynamic route | Advertised by a routing-protocol neighbor | `192.168.0.0/24` learned through RIP |

```text
R1 Gig0/0: 172.16.0.1/30 ------- 172.16.0.2/30: R2
                                                |
                                         192.168.0.0/24

R1 also has a static route:
192.168.100.0/24 via 172.16.0.2
```

`show ip route` displays the routes that R1 has installed and can use for forwarding.

## Routes with the Same Network and Prefix

Routes compete only when both the network and prefix are identical.

```text
Same:      192.168.0.0/24 and 192.168.0.0/24
Different: 192.168.0.0/24 and 192.168.0.0/26
```

Different prefixes are separate routes. They can all appear in the routing table even when their address ranges overlap.

### 1. Administrative Distance

AD compares the trustworthiness of routes learned from different sources. Lower AD is preferred.

```text
EIGRP: AD 90
OSPF:  AD 110
RIP:   AD 120

Best AD in this group: EIGRP
```

### 2. Metric

Metric breaks a tie when routes to the same network and prefix have the same AD. Lower metric is preferred.

```text
Two EIGRP routes to same prefix

Via R4: metric 3072
Via R5: metric 6144

Result: route via R4 wins because 3072 is lower.
```

### Equal-Cost Paths

If multiple routes have the same network, prefix, AD, and metric, all can be installed. The router performs equal-cost load balancing across those paths.

Example:

```text
Destination: 10.0.1.0/24

Via R4: EIGRP, [90/3072], next hop 172.16.0.10
Via R5: EIGRP, [90/3072], next hop 172.16.0.14

Result: both routes enter the routing table.
```

## Example: AD First, Then Metric

R1 learns four routes to `10.0.0.0/24`:

| Learned from | Protocol | AD | Metric | Decision |
| --- | --- | --- | --- | --- |
| R2 | RIP | 120 | 5 | Discarded: worse AD |
| R3 | OSPF | 110 | 2 | Discarded: worse AD |
| R4 | EIGRP | 90 | 3072 | Installed: best metric among best-AD routes |
| R5 | EIGRP | 90 | 6144 | Discarded: higher EIGRP metric |

The route installed by R1 is the EIGRP route through R4 with next hop `172.16.0.10`.

The RIP and OSPF metrics do not matter here. Their AD values were worse than EIGRP's AD, so they were removed from consideration before metric comparison.

## Longest Prefix Match

Longest prefix match happens when a packet destination matches more than one installed route. The router chooses the most specific matching prefix, which is the largest prefix length.

```text
More specific                                 Less specific
/30  >  /28  >  /26  >  /24  >  /16
```

### Overlapping Routes on R1

R1 has these installed routes:

| Prefix | Route source | Outbound interface |
| --- | --- | --- |
| `192.168.0.0/30` | Connected | `Gig0/4` |
| `192.168.0.0/28` | EIGRP | `Gig0/3` |
| `192.168.0.0/26` | EIGRP | `Gig0/2` |
| `192.168.0.0/24` | RIP | `Gig0/0` |
| `192.168.0.0/16` | OSPF | `Gig0/1` |

These routes do not compete at installation time because their prefixes differ. They coexist in the routing table.

### Packet-Matching Examples

| Packet destination | Matching routes | Longest matching prefix | Result |
| --- | --- | --- | --- |
| `192.168.0.2` | `/30`, `/28`, `/26`, `/24`, `/16` | `/30` | Forward out `Gig0/4` |
| `192.168.0.5` | `/28`, `/26`, `/24`, `/16` | `/28` | Forward out `Gig0/3` |
| `192.168.0.20` | `/26`, `/24`, `/16` | `/26` | Forward out `Gig0/2` |
| `192.168.0.120` | `/24`, `/16` | `/24` | Forward out `Gig0/0` |
| `192.168.1.5` | `/16` only | `/16` | Forward out `Gig0/1` |

The `192.168.0.120` example is important: RIP's AD is worse than OSPF's, but the RIP `/24` route wins because longest prefix match is checked before AD.

## Verifying the Selected Route

Use `show ip route` with a destination address to see which route the router will use for that destination.

```text
R1# show ip route 192.168.1.5
```

In the example, this matches the OSPF route to `192.168.0.0/16`, with next hop `172.16.0.6` out `Gig0/1`.

## Practice Question Logic

For a packet addressed to `10.0.0.16`:

1. Routes to `10.0.0.0/28` do not match because that range ends at `10.0.0.15`.
2. The remaining matching routes have the same network and prefix.
3. Compare AD first: EIGRP is preferred over OSPF and RIP.
4. The EIGRP route through R7 is selected.

The two OSPF routes with metrics `6` and `9` are not considered while the EIGRP route exists because OSPF has a worse AD. If R7 fails and the EIGRP route is removed, the OSPF route with metric `6` becomes the next best route.

## My Takeaways

- Routes with identical network and prefix are chosen by lowest AD, then lowest metric.
- Different prefixes can coexist, even when their address ranges overlap.
- Longest prefix match is checked before AD and metric when forwarding a packet.
- A more specific RIP route can beat a less-specific OSPF route despite RIP having a worse AD.
- Equal AD and metric for the same prefix allow equal-cost load balancing.
- `show ip route <destination-ip>` is the quickest way to verify which route matches a destination.
