# EIGRP (Enhanced Interior Gateway Routing Protocol)

## Overview

EIGRP supports large networks and converges much faster than RIP. Its `network` statements select participating interfaces, which form neighbor relationships and advertise their configured networks. This lecture covers basic configuration, wildcard masks, Router ID selection, and verification on a five-router lab.

## Main Characteristics

EIGRP stands for Enhanced Interior Gateway Routing Protocol. Its predecessor, IGRP, is an older legacy protocol.

| Feature | Behavior |
| --- | --- |
| Convergence | Quickly learns usable routes after configuration or topology changes. |
| Bounded updates | Sends topology-change information to routers affected by the change rather than unnecessarily flooding it everywhere. |
| Multicast messages | Directs multicast traffic to listening EIGRP routers instead of broadcasting it to every host. |
| Equal-cost load balancing | Uses up to four equal-cost paths by default in the lecture's Cisco environment; the maximum can be increased manually. |
| Unequal-cost load balancing | Can use paths with different metrics when explicitly configured. It is not enabled automatically. |

Unequal-cost load balancing distinguishes EIGRP from the other protocols compared in the lecture. The configuration for that feature and the metric calculation are left for later lessons.

## Autonomous System Number

Enable EIGRP from global configuration mode with an Autonomous System (AS) number:

```text
Router# configure terminal
Router(config)# router eigrp 100
```

The AS identifies the EIGRP administrative domain. Routers must use the same AS number to peer with each other; physical connectivity alone is insufficient.

The lecture describes two organizations connected by an extranet, each running EIGRP internally with a different AS number:

```text
 Organization A                         Organization B
 [EIGRP router] -------- physical link -------- [EIGRP router]
 AS number A                                  AS number B

 Different AS numbers: no EIGRP peering across this link.
 Each organization exchanges routes within its own EIGRP domain.
```

The AS labels above represent different numbers; the transcript does not specify actual values for the two organizations.

## Wildcard Masks

The optional mask in an EIGRP `network` statement is a wildcard mask, the inverse of a subnet mask.

Calculate it by subtracting each subnet-mask octet from `255`.

### Example 1: Convert a `/16` Mask

```text
  255.255.255.255
- 255.255.  0.  0
-----------------
    0.  0.255.255
```

1. First octet: `255 - 255 = 0`.
2. Second octet: `255 - 255 = 0`.
3. Third octet: `255 - 0 = 255`.
4. Fourth octet: `255 - 0 = 255`.

Subnet mask `255.255.0.0` becomes wildcard mask `0.0.255.255`.

### Example 2: Convert a `/30` Mask

```text
  255.255.255.255
- 255.255.255.252
-----------------
    0.  0.  0.  3
```

1. The first three octets each give `255 - 255 = 0`.
2. The last octet gives `255 - 252 = 3`.

Subnet mask `255.255.255.252` becomes wildcard mask `0.0.0.3`.

### When the Wildcard Mask Is Omitted

Without an explicit wildcard mask, the `network` command uses the classful major-network range:

| Classful range | Default subnet mask | Equivalent wildcard mask |
| --- | --- | --- |
| Class A | `255.0.0.0` | `0.255.255.255` |
| Class B | `255.255.0.0` | `0.0.255.255` |
| Class C | `255.255.255.0` | `0.0.0.255` |

For example, these statements select the same interfaces:

```text
Router(config-router)# network 10.0.0.0
Router(config-router)# network 10.0.0.0 0.255.255.255
```

They are alternatives; there is no need to enter both.

## What the `network` Command Actually Does

The command matches **interface IP addresses**. It does not directly specify the prefix length of the routes to advertise.

For each matching interface:

1. Enable EIGRP on the interface.
2. Send and listen for EIGRP hello messages.
3. Peer with compatible adjacent EIGRP routers on the same link.
4. Advertise the network and subnet mask configured on that interface.

The examples use these three interfaces on R1:

```text
                         [R1]
                           |
          +----------------+----------------+
          |                |                |
     FastEthernet0/0  FastEthernet1/0  FastEthernet2/0
     10.1.0.1/24      10.0.1.1/24      10.0.2.1/24
          |                |                |
     10.1.0.0/24      10.0.1.0/24      10.0.2.0/24
```

### 1. Match Every Interface Beginning with `10`

```text
R1(config-router)# network 10.0.0.0
```

The implicit wildcard is `0.255.255.255`, so all three interfaces match.

| Matching interface | Network advertised from its configuration |
| --- | --- |
| `FastEthernet0/0` | `10.1.0.0/24` |
| `FastEthernet1/0` | `10.0.1.0/24` |
| `FastEthernet2/0` | `10.0.2.0/24` |

The `/8` matching range does not create a `10.0.0.0/8` advertisement. The lecture's example advertises the configured `/24` networks.

### 2. Match Only Interfaces Beginning with `10.0`

```text
R1(config-router)# network 10.0.0.0 0.0.255.255
```

The first two octets must match `10.0`; the remaining two can vary.

| Interface address | Matches? | Result from this statement |
| --- | --- | --- |
| `10.1.0.1/24` | No | `FastEthernet0/0` is not enabled for EIGRP and its network is not included. |
| `10.0.1.1/24` | Yes | Enable `FastEthernet1/0` and advertise `10.0.1.0/24`. |
| `10.0.2.1/24` | Yes | Enable `FastEthernet2/0` and advertise `10.0.2.0/24`. |

The matching range corresponds to `/16`, but the advertised networks remain `/24`. Advertising a `10.0.0.0/16` summary would require separate summarization configuration, which is not covered here.

### 3. Use Separate Subnet Matches

These three statements select the same interfaces as the broad `network 10.0.0.0` statement in this example:

```text
R1(config-router)# network 10.1.0.0 0.0.0.255
R1(config-router)# network 10.0.1.0 0.0.0.255
R1(config-router)# network 10.0.2.0 0.0.0.255
```

Using only the third statement would enable EIGRP only on `FastEthernet2/0` and include `10.0.2.0/24`.

### 4. Match Exact Interface Addresses

A wildcard of `0.0.0.0` matches one exact IP address:

```text
R1(config-router)# network 10.1.0.1 0.0.0.0
R1(config-router)# network 10.0.1.1 0.0.0.0
R1(config-router)# network 10.0.2.1 0.0.0.0
```

All three interfaces are selected again. The exact-address matches do not turn their advertised networks into `/32` routes; the interfaces are configured with `/24` masks.

### Comparing the Matching Methods

| Method | Interfaces selected in this example | Advertised networks |
| --- | --- | --- |
| One classful statement for `10.0.0.0` | All three | All three configured `/24` networks |
| `10.0.0.0 0.0.255.255` | `FastEthernet1/0` and `FastEthernet2/0` | `10.0.1.0/24` and `10.0.2.0/24` |
| Three separate subnet statements | All three | All three configured `/24` networks |
| Three exact-address statements | All three | All three configured `/24` networks |

Different matching methods can produce the same result. The distinction to remember is the interface-selection range versus the interface's actual network mask.

## EIGRP Router ID

The Router ID identifies the router to other EIGRP routers. It uses the format of an IPv4 address.

Without a manually configured Router ID, selection follows this order:

1. Highest IP address among configured loopback interfaces.
2. If no loopback exists, highest IP address among the eligible physical interfaces.

### Selection Examples

| Scenario in the lecture | Selected Router ID |
| --- | --- |
| No loopbacks; highest physical address is `10.0.3.1` on `FastEthernet3/0` | `10.0.3.1` |
| `Loopback0` has address `1.1.1.1` | `1.1.1.1`, even though it is numerically lower than the physical address |
| Manual Router ID is configured as `2.2.2.2` | `2.2.2.2` |

```text
 No manual Router ID
          |
          +-- Loopback exists? -- yes --> Highest loopback IP
                          |
                          no
                          |
                          +-----------> Highest physical-interface IP
```

Check interface addresses and the selected Router ID with:

```text
Router# show ip interface brief
Router# show ip protocols
```

A loopback or an explicit Router ID provides a more stable identity than relying on changing physical-interface addresses.

### Adding a Loopback After EIGRP Starts

Adding a loopback does not immediately replace an already selected Router ID in the lecture's example. EIGRP must restart before it selects the new loopback address.

The lecture mentions disabling and re-enabling EIGRP or rebooting the router. Both can interrupt routing or connectivity, so this is a disruptive change rather than a routine verification step.

### Manually Set the Router ID

```text
Router# configure terminal
Router(config)# router eigrp 100
Router(config-router)# eigrp router-id 2.2.2.2
```

The Router ID does not have to be an address configured on an interface. It is an identifier written in IPv4 format. The lecture recommends using an actual router address to make the identity easier to recognize and troubleshoot.

## Lab Configuration

The lab contains R1 through R5. All interfaces included in this exercise have addresses in `10.X.X.X`, and every router uses AS `100`.

Apply the same basic configuration to each router:

```text
Router# configure terminal
Router(config)# router eigrp 100
Router(config-router)# network 10.0.0.0
```

The omitted wildcard defaults to `0.255.255.255`, selecting all the lab's interfaces beginning with `10`.

After configuration, the demo shows neighbors coming up quickly. R5 sits at the bottom of the topology and directly neighbors R1 and R4. This is the portion of the diagram described with specific neighbor addresses:

```text
 [R4] -------------------- [R5] -------------------- [R1]
 10.1.3.1                                           10.0.3.1
      <------ EIGRP neighbor relationships ------>

 All three use AS 100.
 R5 should list two neighbors: 10.1.3.1 and 10.0.3.1.
```

The transcript also places R3 near the middle of the five-router topology, but does not give the remaining links and interface labels in enough detail to reconstruct the full diagram here.

## Verification Commands

```text
Router# show running-config | section eigrp
Router# show ip protocols
Router# show ip eigrp interfaces
Router# show ip eigrp neighbors
Router# show ip route
```

| Command | What to check |
| --- | --- |
| `show running-config \| section eigrp` | EIGRP-related configuration sections, including the routing process and relevant interface sections. |
| `show ip protocols` | Running protocols, EIGRP AS, Router ID, configured networks, timers, routing-information sources, and metric settings. |
| `show ip eigrp interfaces` | Interfaces participating in EIGRP and their EIGRP traffic statistics. Useful for checking the effect of `network` statements. |
| `show ip eigrp neighbors` | Whether adjacent routers have formed EIGRP neighbor relationships, their addresses, and the local interfaces used to reach them. |
| `show ip route` | Whether learned EIGRP routes have entered the routing table. |

### Verify Neighbors Before Routes

1. Configure EIGRP on both ends of a link.
2. Run `show ip eigrp neighbors` to confirm the relationship is up.
3. Run `show ip route` to check that expected routes are installed.
4. Use the protocol and interface commands to inspect settings and interface selection.

One verification example shows neighbor `10.0.0.1` reachable through `FastEthernet0/0`. In the five-router lab, R5 lists the two expected neighbors at `10.0.3.1` and `10.1.3.1`.

### Reading EIGRP Routes

The routes shown in the lecture use code `D` for EIGRP. Their bracketed values contain the administrative distance followed by the metric:

```text
[AD/metric]
```

The example routes have AD `90`. Also inspect their destination prefixes, next-hop addresses, and exit interfaces. The EIGRP metric calculation is deferred to a later lecture; it is not a RIP hop count.

The demo checks learned routes on R5 and then R3, confirming that route exchange works beyond a single neighbor relationship.

## My Takeaways

- Matching AS numbers are required for EIGRP peering. A connected cable alone does not establish a neighbor relationship.
- Calculate wildcard masks octet by octet; the mask controls which interface addresses match.
- A broad `network` statement or an exact-address match can select the same interfaces. Neither changes their configured subnet masks.
- Keep the Router ID predictable. An added loopback may require a process restart before it becomes the selected identity.
- Check neighbors first, participating interfaces next when needed, and learned routes in the routing table.
- Equal-cost paths are used automatically; unequal-cost load balancing needs explicit configuration.
