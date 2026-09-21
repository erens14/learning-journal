# Administrative Distance

## Overview

Administrative Distance (AD) helps a router choose between routes to the same destination that came from different routing sources. The lower AD is preferred because it represents the more trusted source.

Metric is different: it chooses the best path only after routes from the same routing protocol are being compared.

## Route Selection Order

1. Compare the route source using Administrative Distance.
2. Keep routes from the source with the lowest AD.
3. Compare the metric between the remaining routes from that protocol.
4. Install the lowest-metric route, or equal-cost routes, in the routing table.

```text
Same destination prefix
        |
Different routing protocols?
        |
        +-- Yes: lowest AD wins first
        |
        +-- Same protocol: lowest metric wins
```

A RIP hop count cannot be compared directly with an OSPF cost because the protocols calculate metrics differently.

## Metric vs Administrative Distance

| Item | Used for | Lower value means |
| --- | --- | --- |
| **Metric** | Choosing paths learned through the same protocol | Better path within that protocol |
| **Administrative Distance** | Choosing routes learned through different sources | More trusted route source |

### Metric Examples

| Protocol | Metric |
| --- | --- |
| RIP | Hop count |
| OSPF | Cost, derived from interface bandwidth by default |

For example, RIP could prefer a two-hop path over a three-hop path. OSPF could prefer the three-hop path if its total cost is lower because the links have higher bandwidth.

## Default Administrative Distance

| Route Source | Default AD |
| --- | --- |
| Connected interface | 0 |
| Static route | 1 |
| External BGP | 20 |
| EIGRP | 90 |
| OSPF | 110 |
| IS-IS | 115 |
| RIP | 120 |

## Reading `show ip route`

The values inside square brackets are shown as:

```text
[Administrative Distance / Metric]

Example: [120/1]
         |   |
         |   +-- RIP metric: 1 hop
         +------ RIP Administrative Distance: 120
```

`show ip route` shows routes that won the route-selection process and entered the routing table.

## Floating Static Routes

A floating static route is a backup route with a manually increased AD.

Normal static routes use AD `1`, so they would normally override IGP routes. To make a static route a backup, configure its AD higher than the preferred dynamic route.

### OSPF Backup Example

OSPF has AD `110`. A static route with AD `115` stays out of the routing table while the OSPF route is available, then becomes active if the OSPF route is removed.

```text
Router(config)# ip route 10.0.1.0 255.255.255.0 10.1.3.2 115
```

| Part | Meaning |
| --- | --- |
| `10.0.1.0 255.255.255.0` | Destination network and mask |
| `10.1.3.2` | Next-hop router for the backup path |
| `115` | AD of the static route; higher than OSPF's 110 |

### Static-Only Backup Example

Two static routes can use different AD values:

```text
Primary route: default AD 1
Backup route:  AD 5
```

The lower-AD primary route is installed first. If its directly connected path fails, the backup route can replace it.

### Limitation of a Static-Only Backup

Be careful when the primary path contains routers beyond the first next hop. If a downstream link fails, the local router may not detect it and can keep forwarding traffic to the first next hop.

```text
R4 -- R3 -- R2 -- R1
      ^
      R4 detects an R4-R3 failure.
      R4 may not detect an R3-R2 or R2-R1 failure.
```

For this reason, a static-only backup route is most reliable when the router can directly detect failure of its primary path.

## Lab Checks

```text
Router# show ip protocols
Router# show ip route
```

The lab showed that when the same prefix was learned through RIP, IS-IS, OSPF, and EIGRP, the selected route changed as a lower AD became available:

```text
RIP 120  -> IS-IS 115 -> OSPF 110 -> EIGRP 90
```

The floating static route was installed only after the preferred dynamic route was removed.

## My Takeaways

- Administrative Distance compares route sources; metric compares paths from the same source.
- Lower values are preferred for both AD and metric, but they answer different questions.
- OSPF cost is based on bandwidth by default, not hop count.
- A normal static route is not a backup for an IGP because AD 1 is normally preferred.
- A floating static route needs an AD higher than the main route and must be tested for failures beyond the first hop.
