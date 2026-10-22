# OSPF DR and BDR Designated Routers

## Overview

On a shared Ethernet segment, OSPF elects a Designated Router (DR) and a Backup Designated Router (BDR). These roles reduce repeated database exchange and flooding while providing a replacement if the DR fails.

The election applies to a network segment and its participating interfaces. A router can hold different roles on different segments.

## Why Shared Segments Use Designated Routers

On an OSPF point-to-point network, the two routers form a full adjacency. On a broadcast multiaccess network, such as Ethernet with its default OSPF network type, forming a full mesh of adjacencies would repeat work across the same segment.

The lecture's first example connects four routers through one switch:

```text
R1: 10.0.0.1/24                 R2: 10.0.0.2/24
       |                              |
       +----------[Switch]------------+
       |                              |
R3: 10.0.0.3/24                 R4: 10.0.0.4/24

              Shared subnet: 10.0.0.0/24
```

The DR coordinates update flooding on this segment. The BDR maintains full adjacencies so it can take over if the DR disappears. The remaining routers are called DROTHERs.

The OSPF network type determines whether an election occurs. Broadcast Ethernet elects a DR and BDR; point-to-point networks do not. [Cisco: OSPF network types](https://www.cisco.com/c/en/us/support/docs/ip/open-shortest-path-first-ospf/13689-17.html)

## Election Rules

The election considers neighbors with bidirectional communication, at least the 2-Way state, before deciding which full adjacencies to form.

For a fresh election with the eligible routers participating together:

1. The highest interface priority wins the DR role.
2. The next preferred eligible router becomes the BDR.
3. If priorities tie, the highest Router ID wins the tie.

| Priority | Meaning |
| --- | --- |
| 1 | Default interface priority. |
| 0 | Ineligible to become either DR or BDR. |
| 1-255 | Eligible; a higher value is preferred. |
| 255 | Highest possible priority. |

With default priority 1 everywhere, Router IDs decide a fresh election. The current roles also depend on election history, so the highest Router ID does not necessarily identify the current DR.

### Existing Roles Are Not Preempted

A higher-priority newcomer or DROTHER does not replace an established DR or BDR. Restarting only that DROTHER does not force it into the DR role. A fresh election requires the existing roles to be removed. [RFC 2328, Section 9.4](https://www.rfc-editor.org/rfc/rfc2328.html#section-9.4)

Set priorities before the initial election when a particular result is required. If changing an operating segment, account for the disruption of resetting existing roles and for the order in which routers rejoin.

## Interface Priority Configuration

The lecture uses priority 100 for a preferred DR candidate:

```text
Router# configure terminal
Router(config)# interface FastEthernet0/0
Router(config-if)# ip ospf priority 100
Router(config-if)# end
```

Its example priority plan is 100 for the intended DR, 50 for the intended BDR, and the default 1 for other eligible routers. These values influence election preference; they do not preempt existing roles.

To exclude an interface from both designated-router roles:

```text
Router# configure terminal
Router(config)# interface FastEthernet0/0
Router(config-if)# ip ospf priority 0
Router(config-if)# end
```

Priority 0 does not disable OSPF. The router can still participate as a DROTHER.

The lecture mentions rebooting, cycling an interface, or clearing the OSPF process to restart participation. Each action can interrupt connectivity, and restarting one router does not guarantee the desired segment-wide election result.

```text
Router# clear ip ospf process
```

A process reset drops the affected OSPF relationships and interrupts learned-route availability while the router reconverges.

## Full Adjacencies and 2-Way Neighbors

Suppose R1 is the DR and R2 is the BDR in the four-router example:

| Router pair | Stable neighbor state |
| --- | --- |
| R1 and R2 | Full |
| R1 and R3 | Full |
| R1 and R4 | Full |
| R2 and R3 | Full |
| R2 and R4 | Full |
| R3 and R4 | 2-Way |

Both designated routers form full adjacencies with every other OSPF router on the segment. Two DROTHERs remain 2-Way with each other and receive the needed topology information through the DR's flooding.

Therefore, a stable `2WAY/DROTHER` relationship between two DROTHERs is expected. The same state should not remain the final result for a router's relationship with the DR or BDR. [Cisco OSPF FAQ](https://www.cisco.com/c/en/us/support/docs/ip/open-shortest-path-first-ospf/9237-9.html)

## Update Flooding and Multicast Addresses

| Address | Receivers | Use discussed in the lecture |
| --- | --- | --- |
| 224.0.0.5 | All OSPF routers on the link | Hello packets and LSU flooding from the DR. |
| 224.0.0.6 | DR and BDR on the link | LSU packets sent by a DROTHER toward the designated routers. |

For a change reported by R3, using the earlier roles:

```text
R3 (DROTHER)
     |
     | LSU to 224.0.0.6
     +------------------> R1 (DR)
     +------------------> R2 (BDR)

R1 (DR)
     |
     | LSU to 224.0.0.5
     +------------------> All OSPF routers on the segment
```

The BDR receives the update, but the DR normally performs the onward flooding. This avoids both designated routers repeating the same forwarding work. The diagram describes a DROTHER-originated update; the DR itself floods to `224.0.0.5`.

## Transcript Lab: R6, R7, R8, and R9

This section reconstructs the supplied lab demonstration. No router commands were executed while writing these notes.

### Topology and Initial State

All four routers share `172.16.0.0/24` and have /32 loopbacks:

```text
R6                                    R7
Loopback: 192.168.0.6/32               Loopback: 192.168.0.7/32
Ethernet: 172.16.0.6                   Ethernet: address not stated
              |                              |
              +---- Shared Ethernet ---------+
              |      172.16.0.0/24            |
              |                              |
R8                                    R9
Loopback: 192.168.0.8/32               Loopback: 192.168.0.9/32
Ethernet: address not stated           Ethernet: address not stated
```

The transcript explicitly gives R6's Ethernet address. It identifies the shared subnet but does not individually state the other Ethernet addresses.

Initially, OSPF has matching network statements only for the loopbacks. OSPF is not yet active on the shared Ethernet interfaces. The loopback addresses serve as Router IDs in this lab.

On R6, inspect the interfaces, OSPF configuration, and Router ID:

```text
R6# show ip interface brief
R6# show running-config | section ospf
R6# show ip protocols
```

### Enable OSPF on the Shared Segment

The instructor enters OSPF process 1 on R6, R7, R8, and R9, then adds a network statement matching `172.16.0.0/24` on each router.

```text
Router# configure terminal
Router(config)# router ospf 1
```

The exact pasted network statement and area are not spoken in the transcript, so a complete command is not invented here.

With all four routers participating in the initial election at priority 1, the expected roles are:

| Router | Router ID | Initial expected role |
| --- | --- | --- |
| R9 | 192.168.0.9 | DR |
| R8 | 192.168.0.8 | BDR |
| R7 | 192.168.0.7 | DROTHER |
| R6 | 192.168.0.6 | DROTHER |

These are also the roles reported in the demonstration after convergence. During startup, temporary 2-Way entries can appear before the required full adjacencies finish.

### Verify Roles and Neighbor States

```text
Router# show ip ospf neighbor
Router# show ip ospf interface
Router# show ip ospf interface FastEthernet0/0
```

`show ip ospf neighbor` identifies each neighbor by Router ID and shows its state and role. `show ip ospf interface` shows the local interface's role, priority, and the DR/BDR identities. The neighbor role suffix describes the neighbor, not the local router.

The demonstration reports these stable relationships:

| View from | Neighbor | State and role |
| --- | --- | --- |
| R9, the DR | R8 | FULL/BDR |
| R9, the DR | R6 and R7 | FULL/DROTHER |
| R8, the BDR | R9 | FULL/DR |
| R8, the BDR | R6 and R7 | FULL/DROTHER |
| R7, a DROTHER | R9 | FULL/DR |
| R7, a DROTHER | R8 | FULL/BDR |
| R7, a DROTHER | R6 | 2WAY/DROTHER |

The two parts of the display answer different questions: `FULL` or `2WAY` describes the relationship, while `DR`, `BDR`, or `DROTHER` identifies the neighbor's role on that segment.

### Change R7's Priority

The lecture introduction mentions making R6 the DR, but the actual command sequence changes R7:

```text
R7# configure terminal
R7(config)# interface FastEthernet0/0
R7(config-if)# ip ospf priority 100
R7(config-if)# end
R7# show ip ospf interface FastEthernet0/0
```

Immediately after the change, R7 has priority 100, while R9 remains DR and R8 remains BDR. This illustrates the absence of preemption.

The Packet Tracer demonstration then clears OSPF on R7 and reports R7 as DR with R8 still BDR. Treat that as the simulator result described in the transcript, not a reliable procedure for replacing a live DR. Restarting only R7 normally leaves the existing R9/R8 roles intact under the standard election rules. [RFC 2328, Section 9.4](https://www.rfc-editor.org/rfc/rfc2328.html#section-9.4)

If the existing roles are removed and all four routers participate together in a fresh election with R7 at priority 100, the expected result is R7 as DR and R9 as BDR. Startup order can affect the outcome if a role is established before the other candidates join.

### Observe DR Failure

For the final demonstration, the reported starting roles are R7 as DR and R8 as BDR. The instructor powers off R7, then checks R8:

```text
R8# show ip ospf interface FastEthernet0/0
```

After the failure is detected:

1. R8, the existing BDR, takes over as DR.
2. R9 becomes the new BDR among the remaining candidates.

R8 takes over even though R9 has a higher Router ID. The existing BDR provides the orderly transition; OSPF does not discard that role and rank every remaining router for DR from scratch.

## My Takeaways

- Determine the interface's OSPF network type before expecting a DR/BDR election.
- Use priority and Router ID to predict a fresh election, then check existing roles and startup history.
- Read a 2-Way entry in context: two DROTHERs can remain there without a fault.
- Verify the current DR and BDR with interface output instead of assuming the highest Router ID still holds the DR role.
- Plan priority changes around non-preemption and the disruption required to remove established roles.
- During DR failure, expect the current BDR to take over before a replacement BDR is chosen.
