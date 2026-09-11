# Equal Cost Multi Path (ECMP)

## Overview

Equal Cost Multi Path (ECMP) allows a router to install multiple best paths to same destination when those paths have equal metric. Router load balances outbound traffic across installed next hops, improving path use and resilience without choosing a single equal-cost route.

Common CCNA IGPs—RIP, OSPF, IS-IS, and EIGRP—support ECMP by default. Static routes can also provide ECMP when identical destination prefixes use different next hops.

---

## Key Concepts

### Equal-Cost Routes

Paths must reach same prefix and have same best metric within routing protocol. Router can then install multiple next hops, subject to platform and protocol maximum-path settings.

### Per-Flow Load Balancing

Router normally selects one ECMP path for a traffic flow using a hash. Packets from same flow stay on selected path; different flows can use different paths.

### Packet Ordering

Keeping one flow on one path reduces risk of out-of-order delivery. Different paths can have different latency, so sending packets from same flow over alternating links could disrupt applications or transport performance.

### Unequal-Cost Load Balancing

EIGRP can be configured for unequal-cost load balancing with its `variance` feature. This is not default behavior; other common CCNA IGPs use equal-cost paths only.

---

## How It Works

1. Routing protocol learns multiple candidate paths to destination prefix.
2. Router calculates metric for each candidate path.
3. Equal lowest-metric paths are installed in routing table.
4. Router hashes each flow to one installed next hop and forwards all packets for that flow through that path.
5. If one path fails, routing protocol reconverges and traffic continues through remaining valid path or paths.

```text
                 100 Mbps                 100 Mbps
R4 -- R3 -- R2 -- R1 -- 10.0.1.0/24
 |                                      |
 +------ R5 -- R6 ----------------------+
                 100 Mbps

Both paths have equal metric.
Flow A: R4-R3-R2-R1
Flow B: R4-R5-R6-R1
```

---

## Components / Structure

| Component | Description |
| --- | --- |
| **Destination prefix** | Same network and mask reached through multiple paths, such as `10.0.1.0/24`. |
| **Metric** | Protocol-specific path value. ECMP requires paths tied at best metric. |
| **Next hop** | Immediate neighbor selected for one installed ECMP route. |
| **Routing table** | Can show multiple next hops for one destination prefix. |
| **Load-balancing hash** | Method used to keep a flow on one selected ECMP path. |
| **Maximum paths** | Limit on how many equal-cost paths protocol and device install. |

---

## Comparison

| Feature | ECMP | Unequal-Cost Multipath |
| --- | --- | --- |
| Path metric | Equal best metrics required | Different metrics allowed within configured limits |
| Default behavior | Supported by common CCNA IGPs | Not default in EIGRP |
| Common use | Two or more equivalent paths | EIGRP design using `variance` |
| Traffic distribution | Different flows can use different equal paths | Uses feasible unequal EIGRP paths after configuration |
| Same-flow forwarding | Stays on one selected path | Stays on one selected path |

### RIP versus OSPF in Same Topology

| Protocol | Why paths may or may not be equal |
| --- | --- |
| **RIP** | Equal hop counts create ECMP even if link bandwidth differs. |
| **OSPF** | Equal cumulative costs create ECMP; lower-bandwidth links usually have higher cost and may prevent ECMP. |

---

## Commands (If Applicable)

### Cisco IOS

#### Verify Multiple Installed Next Hops

```text
Router# show ip route 10.0.1.0
Router# show ip route
```

When ECMP is active, route output lists multiple `via` next-hop entries for same destination prefix.

#### Configure Static ECMP

```text
Router# configure terminal
Router(config)# ip route 10.0.1.0 255.255.255.0 10.1.1.2
Router(config)# ip route 10.0.1.0 255.255.255.0 10.1.3.2
```

Both static routes must use identical destination network and mask. Router can install both equal-preference next hops.

#### Restore Default Interface Bandwidth in Lab

```text
Router# configure terminal
Router(config)# interface fastEthernet2/0
Router(config-if)# no bandwidth 10000
```

Removing manually configured `10000` Kbps bandwidth returns FastEthernet interface to default 100 Mbps reference, allowing OSPF path costs to become equal when rest of topology matches.

---

## Example

R4 reaches `10.0.1.0/24` behind R1 through two three-hop paths:

```text
Path 1: R4-R3-R2-R1
Path 2: R4-R5-R6-R1

RIP metric: 3 hops for each path
Result: R4 installs routes via R3 and R5.
```

If R5 links remain 10 Mbps while top links are 100 Mbps, RIP still treats paths as equal because it only uses hop count. OSPF does not: it prefers lower-cost top path. After R5-side links return to 100 Mbps, OSPF sees equal costs and installs both paths.

---

## Important Notes

* **ECMP is not round-robin per packet:** Cisco forwarding normally keeps each flow on one path to preserve packet order.
* **Equal metric does not mean equal bandwidth:** RIP can load balance across equal-hop paths with different link speeds.
* **Metric and administrative distance differ:** ECMP compares same-protocol best paths; administrative distance chooses route source when different protocols advertise identical prefix.
* **ECMP needs convergence:** After topology or metric changes, wait for adjacencies and routing table to stabilize before judging installed paths.
* **Static ECMP needs exact prefix match:** Different subnet masks are different routes and do not form one ECMP set.
* **Use EIGRP unequal-cost multipath deliberately:** Configure and validate it; do not assume it occurs by default.

---

## My Takeaways

* **ECMP installs multiple equally best paths:** It uses available network capacity without sacrificing route preference.
* **Metrics decide ECMP eligibility:** Same destination alone is insufficient; paths must tie at best metric.
* **Flow consistency protects applications:** Same traffic flow stays on one path, avoiding reordering from different path delays.
* **Protocol metric changes outcome:** RIP sees equal hops, while OSPF evaluates cost based on bandwidth by default.
* **Route output proves ECMP:** Multiple `via` entries for one prefix confirm multiple paths are installed.
