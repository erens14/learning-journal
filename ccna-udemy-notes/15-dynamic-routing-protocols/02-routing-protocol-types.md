# Routing Protocol Types

## Overview

Dynamic routing protocols exchange reachability information and select paths automatically. They are grouped by administrative scope: Interior Gateway Protocols (IGPs) route within one organization or autonomous system, while Exterior Gateway Protocols (EGPs) route between organizations on the Internet.

---

## Key Concepts

### Interior Gateway Protocols (IGPs)

An IGP distributes routes inside a single organization or autonomous system. Common CCNA IGPs are:

* **RIP** — Routing Information Protocol; Distance Vector.
* **EIGRP** — Enhanced Interior Gateway Routing Protocol; advanced Distance Vector.
* **OSPF** — Open Shortest Path First; Link State.
* **IS-IS** — Intermediate System to Intermediate System; Link State.

### Exterior Gateway Protocols (EGPs)

An EGP exchanges routing information between autonomous systems. **BGP (Border Gateway Protocol)** is the EGP used on today’s Internet.

### Distance Vector Routing

Each router tells directly connected neighbors which networks it knows and its distance (metric) to each one. It does not advertise a complete topology map, so routers learn routes from each neighbor’s perspective. This is commonly called **routing by rumor**.

### Link State Routing

Each router advertises information about itself, its interfaces, and their links. That link-state information is flooded unchanged through the routing domain, allowing routers to build a complete topology database and calculate paths from the same network view.

---

## How It Works

Both Distance Vector and Link State protocols form adjacencies only with directly connected neighbors. Routers do not form a direct protocol adjacency with devices multiple hops away.

1. Neighboring routers form an adjacency.
2. Routers exchange protocol information with their direct neighbors.
3. Received information enters the routing protocol database.
4. Each router selects its best routes and installs them in the routing table.

```text
Distance Vector
R1 -- R2 -- R3
      |
      +-- advertises: "I know these networks; this is my metric to them."

Link State
R1 -- R2 -- R3
      |
      +-- floods link descriptions unchanged through the area.
          Each router builds the same topology view.
```

---

## Components / Structure

| Component | Description |
| --- | --- |
| **Adjacency** | Neighbor relationship between directly connected routers using the same routing protocol. |
| **Routing protocol database** | Protocol-specific learned information; for example, RIP database or OSPF link-state database. |
| **Routing table** | Best routes selected from connected, static, and dynamic routing information. |
| **Metric** | Protocol-specific value used to compare eligible paths. Distance Vector updates report a neighbor’s metric to a destination. |
| **Topology database** | Link State database describing routers and links in an area; used to calculate paths. |
| **Redistribution** | Controlled exchange of routes between protocols; useful during transitions but increases design complexity. |

---

## Comparison

| Feature | Distance Vector | Link State |
| --- | --- | --- |
| Common examples | RIP, EIGRP | OSPF, IS-IS |
| Update content | Reachable networks and metrics from neighbor’s perspective | Router and link descriptions |
| Topology knowledge | Direct neighbors plus advertised routes | Full topology of routing domain or area |
| Information handling | Updates are interpreted and re-advertised from each router’s perspective | Link-state information is flooded unchanged |
| Router resource demand | Generally lower topology-data requirement | More CPU and memory required to maintain and calculate topology |
| Routing decisions | Based on learned route/metric information | Based on complete topology view |

---

## Commands (If Applicable)

### Cisco IOS

#### Verify Active Routing Protocols and Learned Routes

```text
Router# show ip protocols
Router# show ip route
Router# show ip rip database
Router# show ip ospf database
```

#### Filter Running Configuration

```text
Router# show running-config | section rip
Router# show running-config | begin rip
```

#### Basic OSPF Lab Configuration

```text
Router# configure terminal
Router(config)# router ospf 1
Router(config-router)# network 10.0.0.0 0.255.255.255 area 0
```

`0.255.255.255` is a wildcard mask. In this lab it enables OSPF on interfaces whose IPv4 address begins with `10`.

---

## Example

In a five-router lab, routers R1 through R5 can run OSPF process `1` in area `0`. Each router forms adjacencies with its direct neighbors only, then learns the same link-state information for the area.

```text
R1 -- R2 -- R3 -- R4 -- R5

R1 does not become directly adjacent to R3.
R1-R2 and R2-R3 are direct neighbor relationships.

With OSPF, R5 can use `show ip ospf database`
to inspect information about routers and links across area 0.
```

If this topology used RIP instead, `show ip rip database` would display routes learned from neighbors, rather than a complete map of every router and link.

---

## Important Notes

* **Adjacency scope is same for both types:** Distance Vector and Link State protocols exchange information only with directly connected neighbors.
* **Full topology is not direct communication:** Link State routers learn a network-wide view because link-state advertisements are flooded through neighbors, not because every router peers directly with every other router.
* **Avoid unnecessary multi-protocol designs:** One IGP is normally sufficient inside an organization. Redistribution can be required after a merger or during migration, but it adds operational risk.
* **OSPF area is required:** The `network` command in this OSPF lab is incomplete without `area 0`.
* **Protocol database and routing table differ:** A protocol can learn several routes, but only selected best routes appear in `show ip route`.

---

## My Takeaways

* **IGP versus EGP describes routing scope:** IGPs operate inside one organization; BGP connects autonomous systems.
* **Distance Vector learns route claims:** A router trusts information advertised by its direct neighbor and does not hold a complete topology map.
* **Link State learns link information:** Flooded advertisements let every router in an area build a comparable topology database.
* **Neighbor-only adjacency does not mean neighbor-only knowledge:** OSPF peers only with adjacent routers while still learning about distant routers and links.
* **Verification follows data flow:** Check protocol status, inspect its database, then confirm selected routes in the routing table.
