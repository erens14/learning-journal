# OSPF Basic Configuration

## Overview

A basic Cisco IOS OSPF configuration creates a local process and selects the interfaces that participate in an area. The `network` statement matches interface IP addresses using a wildcard mask. OSPF advertises the actual subnets configured on those interfaces.

These notes cover the basic configuration and five-router demonstration in the supplied **OSPF Characteristics and Basic Configuration** transcript. Commands and reported observations come from the lecture; they are not evidence that I ran the lab.

## Process IDs

The global configuration command starts an OSPF process:

```text
router ospf 1
```

The process ID is **locally significant**. Neighboring routers do not need matching process IDs to form an adjacency. Using the same number throughout a simple lab makes configuration easier to follow, but matching numbers are not an adjacency requirement.

Different OSPF processes on one router maintain separate LSDBs. In the lecture's example, R2 uses two processes, so the routes learned on one side are not automatically shared with the other.

### Separate Processes on R2

```text
R3                         R2                         R1
Process 1                  Left: process 3            Process 4
                           Right: process 2
     ---- 10.1.0.0/24 ----      ---- 10.0.0.0/24 ----
          adjacency                  adjacency

R2: process 3 LSDB is separate from process 2 LSDB.
R1 and R3 do not learn each other's routes through this setup.
```

The diagram shows the links discussed in the transcript. Interface names, host addresses, and other links are not supplied.

R2 configuration from the lecture:

```text
router ospf 2
 network 10.0.0.0 0.0.0.255 area 0
router ospf 3
 network 10.1.0.0 0.0.0.255 area 0
```

These commands enable OSPF on matching interfaces but place the two sides in separate processes. The example demonstrates process isolation; it is not the normal configuration proposed for this small network.

### One Process on R2

In the second example, R1, R2, and R3 all use process 1. Both R2 links participate in the same process, allowing the route information to reach the other side.

```text
R3                         R2                         R1
Process 1                  Process 1                  Process 1
     ---- 10.1.0.0/24 ----      ---- 10.0.0.0/24 ----

Both R2 links belong to one OSPF process in area 0.
```

R2's configuration for this example:

```text
router ospf 1
 network 10.0.0.0 0.0.0.255 area 0
 network 10.1.0.0 0.0.0.255 area 0
```

The important change is putting both R2 interfaces into one process. The neighboring routers could still use different local process IDs.

## Network Statements and Wildcard Masks

The command format is:

```text
network <address> <wildcard-mask> area <area-id>
```

The statement selects interfaces whose IP addresses match the address and wildcard mask. On those interfaces, OSPF sends and listens for Hellos and can establish neighbor relationships. The actual interface subnet and mask determine the advertised network.

For the small single-area examples, the lecture uses **area 0**. Detailed area design belongs to a later topic.

### Calculating a Wildcard Mask

For the subnet masks in these examples, subtract each octet from 255.

For `255.255.0.0`:

```text
255 - 255 = 0
255 - 255 = 0
255 -   0 = 255
255 -   0 = 255

Wildcard mask: 0.0.255.255
```

For `255.255.255.252`:

```text
255 - 255 = 0
255 - 255 = 0
255 - 255 = 0
255 - 252 = 3

Wildcard mask: 0.0.0.3
```

Unlike the EIGRP command described in the lecture, this OSPF `network` command requires an explicit wildcard mask. Do not rely on an omitted mask defaulting to a classful range.

### Interface Selection Is Not Route Summarization

The lecture gives these R1 interfaces:

| R1 interface | Address or subnet supplied | Matches `10.0.0.0 0.0.255.255`? |
| --- | --- | --- |
| FastEthernet0/0 | `10.1.0.1/24` | No |
| FastEthernet1/0 | `10.0.1.0/24` subnet; host address not supplied | Yes |
| FastEthernet2/0 | `10.0.2.0/24` subnet; host address not supplied | Yes |

```text
R1
 |-- FastEthernet0/0: 10.1.0.1/24       excluded
 |-- FastEthernet1/0: 10.0.1.0/24 subnet selected
 `-- FastEthernet2/0: 10.0.2.0/24 subnet selected

Match range: 10.0.0.0 through 10.0.255.255
```

The configuration is:

```text
router ospf 1
 network 10.0.0.0 0.0.255.255 area 0
```

This enables OSPF on FastEthernet1/0 and FastEthernet2/0. It advertises their actual `10.0.1.0/24` and `10.0.2.0/24` subnets. It does **not** create a `10.0.0.0/16` summary route.

## Five-Router Lab Walkthrough

The demonstration uses R1 through R5. All internal interface subnets begin with `10`, so one statement selects those interfaces on every router.

Only R1's neighbors are identified in the narration. This is a partial view, not a reconstruction of the full five-router topology:

```text
R2 ---- R1 ---- R5

R3 and R4 also participate in the lab.
Their links and interface addresses are not stated in this transcript.
```

1. Enter global configuration mode on each router.
2. Create OSPF process 1.
3. Match the internal interfaces with a `10.0.0.0/8` address range and assign them to area 0.

Apply this configuration to R1, R2, R3, R4, and R5:

```text
configure terminal
router ospf 1
 network 10.0.0.0 0.255.255.255 area 0
```

This changes routing participation on every matching interface. The broad range is appropriate to the stated lab because all its internal interfaces begin with `10`. In another topology, first confirm which interfaces the range would include.

The instructor reports that R1 initially has no routing information sources while adjacencies are forming. Later, R1 forms adjacencies with R2 and R5 and learns the other lab networks. No exact command output or complete address plan is included in the transcript.

## Verification and Troubleshooting

Use these commands from privileged EXEC mode after configuration:

| Command | What to inspect |
| --- | --- |
| `show running-config \| section ospf` | Configuration sections matching `ospf` |
| `show ip protocols` | Active routing protocols, OSPF process, configured ranges, and routing information sources |
| `show ip ospf interface brief` | Participating interfaces, process, area, address/mask, cost, and neighbor counts |
| `show ip ospf neighbor` | Discovered neighbors and adjacency state |
| `show ip ospf database` | LSAs in the OSPF database |
| `show ip route` | Routes installed in the routing table and their selected paths |

Command spellings are normalized from the transcript, including `ospf` in the interface command and singular `neighbor`.

### Check in Protocol Order

1. **Check neighbors first.** Run `show ip ospf neighbor` after configuring both sides. Verify that the expected adjacency forms; a neighbor entry alone does not prove database synchronization.
2. **Check installed routes.** Run `show ip route` and compare the learned networks and paths with the lab's expectations.
3. **Inspect the LSDB when needed.** If the adjacency forms but an expected route or path is missing, use `show ip ospf database` to investigate whether the relevant information was learned.
4. **Check interface participation and configuration.** Use the interface summary, protocol summary, and running configuration to confirm the intended interfaces, process, and area.

The lecture's separate verification example shows neighbor ID `10.0.2.1` reachable through FastEthernet0/0. This is not enough information to assign that address to a router in the five-router diagram.

If the expected adjacency is absent, resolve that problem before expecting routes from that neighbor. An LSDB entry and an installed route answer different questions, so inspect both when troubleshooting missing routes.

## My Takeaways

- A process ID identifies a local OSPF instance; it is not a value that neighbors must share.
- Two working adjacencies on R2 do not automatically connect routes across two separate OSPF processes.
- I should evaluate a network statement by the interfaces it selects, not by treating its range as an advertised summary.
- A broad wildcard mask saves commands but requires checking the interface scope.
- My first checks are the expected adjacency and installed routes. I use the LSDB to investigate the gap between learned information and route selection.
- Reviewing a demonstration gives me a configuration reference. A completed personal lab would need separate execution evidence.
