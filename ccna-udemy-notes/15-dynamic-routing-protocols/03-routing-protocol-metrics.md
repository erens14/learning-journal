# Routing Protocol Metrics

## Overview

When a router learns multiple paths to same destination, an IGP assigns each path a metric. Lower metric is preferred. Only best eligible route is installed in routing table; remaining learned paths stay in protocol database as alternatives.

Metrics let dynamic routing protocols adapt to failures. When best path is lost, router reconverges and installs next-best available path.

---

## Key Concepts

### Metric

A metric is protocol-specific path preference value. Lower value means more preferred path. Metrics are only compared between routes learned by same routing protocol.

### Distance Vector Metric Exchange

Distance Vector routers advertise known networks and their metric to direct neighbors. Each receiving router adds its own path information before advertising onward.

### Link State Path Calculation

Link State routers flood link information in an area. Every router builds topology database, then independently calculates best paths using its protocol metric.

### Convergence and Failover

After link or route change, protocol detects change, recalculates paths, and updates routing table. During convergence, routing table may temporarily not show expected best route.

---

## How It Works

1. Router learns one or more candidate paths to destination.
2. Routing protocol assigns or calculates metric for each path.
3. Router installs lowest-metric eligible route in routing table.
4. If selected path fails, router reconverges and installs next-best available route.

```text
                   100 Mbps links
R4 -- R3 -- R2 -- R1 -- 10.0.1.0/24
 |                         |
 +------ R5 ---------------+
        10 Mbps links

R4 has two paths to 10.0.1.0/24.
RIP: prefers R4-R5-R1 (fewer hops).
OSPF/EIGRP: normally prefer higher-bandwidth top path.
```

---

## Components / Structure

| Protocol | Type | Metric | Default behavior relevant to path choice |
| --- | --- | --- | --- |
| **RIP** | Distance Vector | Hop count | Lowest hop count wins; 15 is maximum reachable hop count. |
| **EIGRP** | Advanced Distance Vector | Composite metric | Uses bandwidth and delay by default; load and reliability are optional metric inputs. |
| **OSPF** | Link State | Cost | Cost is derived from interface bandwidth by default; can be manually set. |
| **IS-IS** | Link State | Cost | Links have equal default cost; set interface costs to prefer a bandwidth-based path. |

### Routing Information Locations

| Location | Purpose |
| --- | --- |
| **Routing protocol database** | Keeps routes or topology information learned by protocol, including alternatives. |
| **Routing table** | Holds selected best route used for packet forwarding. |
| **Administrative distance** | Chooses preferred source when different routing protocols offer same prefix; it is considered before metric. |

---

## Comparison

| Feature | RIP | OSPF | IS-IS | EIGRP |
| --- | --- | --- | --- | --- |
| Primary metric | Hop count | Cost | Cost | Composite |
| Uses bandwidth by default | No | Yes | No | Yes |
| Manual path control | Limited | Configure cost | Configure cost | Configure bandwidth or delay inputs |
| Scalability consideration | Maximum 15 reachable hops | Enterprise-scale open standard | Often used in service-provider or large-scale designs | Commonly Cisco-focused deployment |
| Expected path in example | Lower-hop, 10 Mbps path | Higher-bandwidth, 100 Mbps path | Lower-hop path unless costs adjusted | Higher-bandwidth, 100 Mbps path |

---

## Commands (If Applicable)

### Cisco IOS

#### Inspect Interfaces and Installed Routes

```text
Router# show ip interface brief
Router# show ip route
Router# show running-config interface fastEthernet2/0
```

#### Test Convergence and Failover

```text
Router# configure terminal
Router(config)# interface fastEthernet3/0
Router(config-if)# shutdown

Router# show ip route

Router# configure terminal
Router(config)# interface fastEthernet3/0
Router(config-if)# no shutdown
```

`shutdown` forces a path failure in lab. After protocol reconverges, use `show ip route` to verify fallback route. Restore interface with `no shutdown`.

---

## Example

R4 learns two RIP routes to `10.0.1.0/24`:

```text
Via R3: 3 hops
Via R5: 2 hops

Installed route: via R5, because 2 is lower than 3.
```

R5 path may have less bandwidth than R3 path, but RIP ignores bandwidth. OSPF cost and default EIGRP metric normally prefer higher-bandwidth R3 path instead. If active interface fails, router removes route, reconverges, and installs remaining valid path.

---

## Important Notes

* **Lower metric wins only within same protocol:** Administrative distance determines precedence when different route sources advertise identical prefix.
* **RIP scalability limit is 15 hops:** Routes with a metric greater than 15 are unreachable; this limits RIP to small or lab networks.
* **IS-IS cost is not bandwidth-derived by default:** Equal interface costs can make lower-hop path win unless costs are manually designed.
* **EIGRP delay is configured, not actively measured:** Its metric uses interface bandwidth and delay values; it does not send probes to measure real-time delay.
* **Wait for convergence before diagnosing:** Newly configured adjacencies or failed links need detection and recalculation time before routing table stabilizes.
* **One IGP per organization is normal:** Multiple IGPs and redistribution increase operational complexity; mergers and legacy networks are common exceptions.

---

## My Takeaways

* **Metric chooses protocol’s preferred path:** Lowest metric is best, but meaning of metric changes by protocol.
* **RIP optimizes hop count, not link quality:** Fewer routers can win even when path has less bandwidth.
* **OSPF and EIGRP generally choose practical paths:** Their default metrics account for bandwidth, with EIGRP also using delay.
* **IS-IS needs deliberate cost design:** Default equal costs can produce lower-hop routing instead of preferred-bandwidth routing.
* **Dynamic routing is self-healing:** Route failure triggers reconvergence and fallback to next-best known path when available.
