# OSPF Advanced Topics

## Overview

This topic covers OSPF router IDs, passive interfaces, and default-route injection. The router ID gives a router a stable OSPF identity. Passive interfaces let OSPF advertise connected networks without forming neighbors on those links. Default-route injection lets internal routers learn a route toward an external destination through the edge router.

These notes use the supplied **OSPF Advanced Topics** lecture transcript as the primary source. The lab observations below are reported by the instructor, not results from a lab I executed.

## Router ID

An OSPF router ID is a 32-bit identifier written in IPv4 address format. A manually configured ID does not need to be an address assigned to an interface.

### Selection Order

| Priority | Selection |
| --- | --- |
| 1 | Manually configured `router-id` |
| 2 | Highest loopback IP address when loopbacks are available |
| 3 | Highest eligible interface IP address when no loopback is available |

The lecture recommends using a loopback or an explicit router ID rather than relying on a physical interface address. An address already associated with the router can also make identification easier during troubleshooting.

**Clarification:** an arbitrary manually chosen ID must still be unique in the OSPF domain. A loopback avoids dependence on a physical link, but it can still be administratively disabled or removed; "never goes down" is an oversimplification. Cisco documents the identity and selection rules in [Troubleshooting Duplicate Router IDs with OSPF](https://www.cisco.com/c/en/us/support/docs/ip/open-shortest-path-first-ospf/23862-duplicate-router-id-ospf.html).

### Selection Examples from the Lecture

- R1 has no loopbacks. Its highest interface address is `10.0.3.1` on FastEthernet3/0, so OSPF selects `10.0.3.1`.
- In a separate R1 example, Loopback0 has `1.1.1.1`. OSPF prefers that loopback over numerically higher physical interface addresses when selecting the ID.
- In the lab, R4 initially has no loopbacks. Its ISP-facing address, `203.0.113.1` on FastEthernet3/0, becomes its router ID.

Use these commands to inspect the interface addresses and the active OSPF router ID:

```text
show ip interface brief
show ip protocols
```

The transcript's isolated reference to `show protocols` is normalized to `show ip protocols`, which is used throughout the demonstration.

### Adding a Loopback After OSPF Starts

On R4, the instructor creates Loopback0:

```text
R4# configure terminal
R4(config)# interface loopback 0
R4(config-if)# ip address 1.1.1.1 255.255.255.255
R4(config-if)# end
```

This creates a logical interface with a `/32` address. The lecture does not require `no shutdown` for this newly created loopback.

Adding the loopback does **not** immediately replace R4's active router ID. The instructor checks `show ip protocols` and still sees `203.0.113.1` until OSPF restarts.

In the first restart demonstration, the instructor:

1. Displays and copies the existing OSPF configuration with `show running-config | section ospf`.
2. Removes process 1 using `no router ospf 1` in global configuration mode.
3. Restores the copied configuration to recreate the process.
4. Checks `show ip protocols` and reports that the ID is now `1.1.1.1`.

**Disruption:** `no router ospf 1` deletes the process configuration. This is not merely a reset. Restoring the complete configuration is part of the demonstrated sequence, and adjacencies and learned routes are interrupted.

### Setting an Explicit Router ID

The instructor then configures R4 with a manual ID:

```text
R4# configure terminal
R4(config)# router ospf 1
R4(config-router)# router-id 2.2.2.2
R4(config-router)# end
```

In the demonstration, the active ID remains `1.1.1.1` until OSPF restarts. The instructor uses this privileged EXEC command and accepts its confirmation prompt:

```text
R4# clear ip ospf process
```

This restarts OSPF and disrupts its adjacencies. The instructor reports that the adjacencies go down and return, and `show ip protocols` then shows `2.2.2.2`.

Treat restart commands as disruptive operations. On a live network, schedule any required restart through the normal maintenance process rather than copying the lab sequence during active service.

## Passive Interfaces

An OSPF passive interface does not send Hellos or form OSPF adjacencies. Its connected network can still be advertised to internal OSPF neighbors through other participating interfaces.

There are two separate configuration decisions:

1. **Include the interface in OSPF** using the matching `network` statement in these examples.
2. **Make it passive** to prevent an OSPF adjacency on that link.

`passive-interface` alone does not select the interface for OSPF advertisement. Likewise, passive mode does not disable ordinary IP forwarding. Cisco describes the protocol behavior in [Default Passive Interfaces](https://www.cisco.com/c/en/us/td/docs/routers/ios-xe/ip-routing/b-ip-routing/m_iri-default-passive-interface.html).

### R1 Example: Loopback and External Organization

The lecture shows R1 connected to R6, which belongs to another organization:

```text
R1
 |-- Loopback0: logical interface, no physical neighbor
 |
 `-- FastEthernet2/0 ---- R6 (another organization)
     passive for OSPF

Internal OSPF neighbors learn the included networks through other R1 links.
No interface addresses or internal peer identities are supplied here.
```

The instructor makes the loopback and external-facing interface passive:

```text
router ospf 1
 passive-interface Loopback0
 passive-interface FastEthernet2/0
```

The intention is to advertise the relevant networks internally without exchanging OSPF routing information with R6. The loopback must be included in OSPF if other routers need a route to it; making it passive is not what enables that advertisement.

### Passive by Default

Instead of listing each passive interface, the lecture makes all OSPF interfaces passive and enables neighbor formation only on the intended internal links:

```text
router ospf 1
 passive-interface default
 no passive-interface FastEthernet0/0
 no passive-interface FastEthernet1/0
 no passive-interface FastEthernet3/0
```

For this R1 example, FastEthernet0/0, FastEthernet1/0, and FastEthernet3/0 can form adjacencies. Loopback0 and FastEthernet2/0 remain passive. The `no passive-interface` commands remove passive mode; the interfaces must still participate in OSPF.

Applying `passive-interface default` to an existing network can interrupt neighbors unless the required exceptions are configured appropriately.

### R4 Lab: Advertise the ISP Subnet Internally

The lab uses R1 through R5, with R4 connected to the ISP:

```text
Internal OSPF network                R4                        ISP
R1, R2, R3, R5                       FastEthernet3/0
(internal links not supplied)        203.0.113.1 ---- 203.0.113.2
                                                203.0.113.0/24

R4 advertises the ISP subnet internally.
FastEthernet3/0 stays passive: no OSPF adjacency with the ISP.
```

Initially, R4's OSPF network statement selects only addresses beginning with `10`. The instructor reports that the internal routers have no OSPF route to `203.0.113.0/24`.

R4 then makes the ISP-facing interface passive and includes its subnet in area 0:

```text
R4# configure terminal
R4(config)# router ospf 1
R4(config-router)# passive-interface FastEthernet3/0
R4(config-router)# network 203.0.113.0 0.0.0.255 area 0
R4(config-router)# end
```

The instructor checks `show ip route` on an internal router and reports that the route appears after convergence. This advertises the connected subnet internally while preventing OSPF peering on R4's ISP link.

The R1 theory example and R4 lab example use different external-facing interfaces. Do not copy R1's active-interface exceptions onto R4 without checking its topology.

## Default-Route Injection

R4 needs a default route toward the ISP for destinations without a more specific route. The internal routers can learn that default through OSPF instead of each receiving a separate static configuration.

Configure the static default and OSPF origination on R4:

```text
R4# configure terminal
R4(config)# ip route 0.0.0.0 0.0.0.0 203.0.113.2
R4(config)# router ospf 1
R4(config-router)# default-information originate
R4(config-router)# end
```

- `ip route` sends traffic matching the default route toward ISP next hop `203.0.113.2`.
- `default-information originate` advertises a default into OSPF when R4 has a default route in its routing table for this configuration.
- A configured static route must actually be installed; configuration text alone does not establish that condition. See [Cisco: How Does OSPF Generate Default Routes?](https://www.cisco.com/c/en/us/support/docs/ip/open-shortest-path-first-ospf/13692-21.html).

The internal routers learn `0.0.0.0/0` through the OSPF network toward R4. This does not mean their immediate next hop is the ISP address; the transcript does not supply their full internal paths.

### What External Means Here

The injected default appears as an OSPF external route because it originates from outside OSPF's internal route calculation. In this example, the source is R4's static default route.

"External" describes the route's origin relative to OSPF. It does not prove that the destination or router belongs to another organization. The command specifically originates a default; it does not redistribute every configured static route.

### Verification from the Lecture

On R4, inspect the local routing table:

```text
show ip route
```

Check that the static default is installed toward `203.0.113.2`. On R1 and the other internal routers, use the same command to inspect the learned default.

The instructor reports that R1 learns the OSPF default after origination is configured. No exact routing-table output, metric, or internal next-hop address is provided in the transcript.

Advertising `203.0.113.0/24` and advertising `0.0.0.0/0` serve different purposes. The first provides a route to the ISP-facing subnet. The second provides a fallback route for destinations with no more specific match.

## My Takeaways

- I should plan unique, stable router IDs and verify the active ID rather than assuming a configuration change took effect.
- A process restart can interrupt routing; deleting a process also removes its configuration.
- Interface participation determines what OSPF advertises. Passive mode determines where OSPF can form neighbors.
- I need to distinguish R1's external link from R4's ISP link before reusing configuration examples.
- Default origination depends on an installed default in this example, so I should check the edge router before checking downstream routers.
- An OSPF external route describes where routing information came from, not an organization's boundary.
