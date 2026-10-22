# OSPF Adjacencies

## Overview

OSPF routers discover neighbors with Hello packets, then form adjacencies to synchronize their Link-State Databases (LSDBs). Each router uses that topology information to calculate its shortest paths and install the best routes in its routing table. Network changes trigger further updates and route recalculation.

A neighbor appearing in the neighbor table does not prove that database synchronization has finished. The neighbor state shows how far the relationship has progressed.

## OSPF Packets and Advertisements

OSPF runs directly over IP using protocol number **89**, rather than TCP or UDP. TCP uses protocol number 6; UDP uses 17.

| Type | Packet | Purpose |
| --- | --- | --- |
| 1 | Hello | Discover neighbors, maintain neighbor relationships, and carry election information. |
| 2 | Database Description (DBD) | Summarize the LSDB so a neighbor can identify missing or newer information. |
| 3 | Link State Request (LSR) | Request the full information for particular LSAs. |
| 4 | Link State Update (LSU) | Carry one or more LSAs during synchronization or flooding. |
| 5 | Link State Acknowledgment (LSAck) | Acknowledge received LSAs. |

An LSA is a Link-State Advertisement, not a sixth OSPF packet type. LSAs travel inside LSU packets.

The lecture's packet fields can be represented conceptually as follows. This is an OSPFv2 layout, not a bit-level diagram or an OSPFv3 header.

```text
IPv4 header: Protocol = 89
              |
              v
OSPFv2 common header
+------------------------------------------------------+
| Version | Packet type | Packet length                |
| Router ID | Area ID                                  |
| Checksum | Authentication type | Authentication data  |
+------------------------------------------------------+
| Packet-specific payload: Hello, DBD, LSR, LSU, LSAck   |
+------------------------------------------------------+
```

The authentication modes discussed are none, simple password, and MD5. Authentication data is not always a password: MD5 uses an appended digest and does not transmit the secret key. [RFC 2328, Appendix D](https://www.rfc-editor.org/rfc/rfc2328.html#appendix-D)

## Hello Packets and Neighbor Discovery

In the lecture's configuration method, OSPF is enabled globally, then a matching `network` statement enables it on an interface and assigns that interface to an area.

On an active OSPF interface, the router sends and receives Hellos. On a passive interface, it does not form OSPF neighbor relationships, but the interface's network can still be advertised through other OSPF interfaces. The lecture uses third-party-facing links and loopbacks as examples of passive interfaces.

On broadcast and physical point-to-point networks, Hellos go to **224.0.0.5**, the AllSPFRouters multicast address. They continue after adjacency formation to detect whether neighbors remain reachable.

### Information Used During Hello Processing

| Information | Meaning |
| --- | --- |
| Router ID | A unique 32-bit OSPF identifier, written like an IPv4 address. |
| Hello interval | How often the interface sends Hello packets. |
| Dead interval | How long a neighbor can remain unheard before OSPF declares it down. |
| Neighbor list | Router IDs recently heard on this link. |
| Area ID | The area assigned to the sending interface. |
| Network mask | The subnet mask used on the link. |
| Router priority | An 8-bit value used in DR/BDR elections. |
| DR and BDR | The interface addresses of the elected designated routers, when known. |
| Stub-area capability | Indicates whether the area accepts external routing information. |
| Authentication | Packet authentication settings that the receiving router validates. |

Router ID, Area ID, and authentication belong to the common OSPFv2 header. The neighbor list is specific to the outgoing link, not a list of neighbors across every interface. [RFC 2328, Section 9.5](https://www.rfc-editor.org/rfc/rfc2328.html#section-9.5)

### Hello and Dead Timers

The Ethernet defaults discussed in the lecture are:

```text
Hello interval = 10 seconds
Dead interval  = 40 seconds
Default relationship: 4 x 10 = 40 seconds
```

The lecture also illustrates a 20-second Hello interval with an 80-second Dead interval: `4 x 20 = 80`. Both timers are configurable. Check the effective values instead of assuming that changing one setting produced the intended pair.

Shorter timers detect failures sooner, but delays or missed Hellos can cause unnecessary neighbor loss. Match both timers among neighbors on the same link; separate links do not all need identical timers. [Cisco OSPF interface configuration](https://www.cisco.com/c/en/us/td/docs/switches/lan/c9000/lyr3-fwd/ospf/ospf-configuration-guide/ospf.html)

## Requirements for Adjacency Formation

For the numbered IPv4 links in these examples, check the following:

| Requirement | What to check |
| --- | --- |
| Bidirectional Hello communication | Each router sees its own Router ID in the other router's Hello neighbor list. |
| Matching timers | Both Hello intervals match, and both Dead intervals match. |
| Matching area | The two interfaces on the shared link belong to the same area. |
| Compatible addressing | The link addresses and masks place the routers in the same subnet. |
| Matching authentication | Both sides use compatible authentication settings and matching credentials when enabled. |
| Matching stub-area settings | Routers agree on the area's stub capability. |
| Compatible MTU | Database exchange can complete without an MTU mismatch. |

An ABR can have interfaces in different areas. The area must match across a particular neighbor link, rather than across every interface on the router.

Authentication helps prevent an unauthorized or accidentally connected router from injecting routing information. The lecture introduces the concept without providing authentication configuration commands.

A standard stub area excludes external LSAs and uses an ABR-provided default route for external destinations. It can still learn inter-area routes; it does not require exactly one ABR. [RFC 2328, Section 3.6](https://www.rfc-editor.org/rfc/rfc2328.html#section-3.6)

## Neighbor States and Database Synchronization

### Two-Router Example

The lecture uses these addresses, with no loopback interfaces or explicit Router IDs in this example:

```text
172.16.1.0/24                                       172.16.2.0/24
       |                                                  |
172.16.1.1/24                                      172.16.2.1/24
      [R1] -- 10.0.0.1/30 -------- 10.0.0.2/30 -- [R2]

R1 Router ID: 172.16.1.1         R2 Router ID: 172.16.2.1
                  Shared link: 10.0.0.0/30
```

Each router selects its highest active physical-interface IPv4 address as its Router ID in this example. R1 needs to learn `172.16.2.0/24`; R2 needs to learn `172.16.1.0/24`.

R1 sends from interface address `10.0.0.1`, while identifying itself as Router ID `172.16.1.1`. The Router ID does not need to equal the sending interface's address.

### State Progression

For a pair that proceeds to full adjacency:

```text
DOWN --> INIT --> 2-WAY --> EXSTART --> EXCHANGE --> LOADING --> FULL
```

| State | Meaning |
| --- | --- |
| Down | No recent Hello has been received from the neighbor. |
| Init | A Hello has arrived, but it does not yet list the local Router ID. |
| 2-Way | The neighbor's Hello lists the local Router ID, confirming bidirectional communication. |
| ExStart | The routers negotiate DBD exchange roles and sequence numbering. |
| Exchange | The routers exchange DBD summaries of their LSDBs. |
| Loading | The routers request and receive missing or newer LSAs. |
| Full | Database synchronization with this neighbor has completed. |

The lecture compresses negotiation into Exchange; its precise state is ExStart. [Cisco: OSPF neighbor states](https://www.cisco.com/c/en/us/td/docs/ios-xml/ios/iproute_ospf/command/iro-cr-book/ospf-s1.html)

### Hello Exchange

Conceptual sequence for the two-router example:

```text
R1 Hello: Router ID 172.16.1.1; no neighbor listed yet
R2 Hello: Router ID 172.16.2.1; lists 172.16.1.1
R1 Hello: Router ID 172.16.1.1; lists 172.16.2.1

Both routers now recognize bidirectional communication: 2-WAY
```

These Hellos use `224.0.0.5` on the broadcast or physical point-to-point links discussed here. The transcript's unicast Hello replies are not the normal behavior for those network types. [RFC 2328, Section 9.5](https://www.rfc-editor.org/rfc/rfc2328.html#section-9.5)

### DBD Exchange and Loading

1. R1 and R2 negotiate DBD exchange roles. R2 has the higher Router ID, `172.16.2.1`, so it becomes the DBD master.
2. They exchange LSDB summaries rather than immediately sending every LSA in full.
3. R2 identifies missing information for `172.16.1.0/24` and sends an LSR to R1.
4. R1 responds with an LSU containing the requested LSA information.
5. R1 requests the information for `172.16.2.0/24`, and R2 sends the corresponding LSU.
6. The routers acknowledge received LSAs. Once synchronization finishes, the relationship reaches Full.

The transcript's isolated `176.16.2.0` reference is a typo; the topology consistently uses `172.16.2.0/24`. DBD exchange acknowledgment uses DBD sequencing; LSAck packets acknowledge LSAs. [RFC 2328, Section 10.6](https://www.rfc-editor.org/rfc/rfc2328.html#section-10.6)

On an OSPF point-to-point network, the pair forms a full adjacency. On broadcast Ethernet, DR/BDR roles determine which neighbors synchronize fully, as covered in the next note.

## MTU Mismatches

MTU is the maximum packet size supported on an interface. The lecture distinguishes the general interface MTU from the IP MTU, which applies specifically to IP packets.

Its configuration example uses two separate settings to show the distinction:

```text
Router# configure terminal
Router(config)# interface GigabitEthernet0/0
Router(config-if)# mtu 1480
Router(config-if)# ip mtu 1460
Router(config-if)# end
```

These commands change packet-size limits for the interface, not just OSPF. The example illustrates the settings; it is not a recommendation to change both.

Use the corresponding verification commands:

```text
Router# show interfaces GigabitEthernet0/0
Router# show ip interface GigabitEthernet0/0
```

The first shows the interface MTU. The second shows the IP MTU. An unchanged interface MTU does not prove that the IP MTU is unchanged.

```text
R1                                           R2
IP MTU 1500 -------- same OSPF link -------- IP MTU 1460
              Hellos can discover neighbors
              Database exchange can fail
```

An MTU mismatch can leave a visible neighbor stuck in ExStart or Exchange rather than Full. MTU is a common cause, but these states alone do not prove the cause. [Cisco: ExStart/Exchange troubleshooting](https://www.cisco.com/c/en/us/support/docs/ip/open-shortest-path-first-ospf/13684-12.html)

## Transcript Lab: Adjacency Troubleshooting

This is a reconstruction of the supplied demonstration, not a newly executed lab. R2 already runs OSPF and acts as an ABR. R1 is configured as an internal router in Area 1. Both use GigabitEthernet0/0 for the link between them.

The transcript does not provide the complete initial OSPF configuration, wildcard masks, or reference-bandwidth value, so those details are not reconstructed.

### 1. Inspect the Initial Configuration

On R2, inspect the OSPF configuration and interfaces:

```text
R2# show running-config | section ospf
R2# show ip interface brief
```

The demonstration shows OSPF process 1, reference-bandwidth configuration, network statements, and a loopback in the `192.168.0.0` range.

On R1, check the protocol configuration and enable adjacency debugging before applying the prepared OSPF configuration:

```text
R1# show ip protocols
R1# debug ip ospf adj
```

After enabling OSPF, the demonstration shows the relationship progressing through discovery and database exchange to Full. Stop debugging and verify the neighbor:

```text
R1# undebug all
R1# show ip ospf neighbor
```

### 2. Introduce Two Mismatches on R2

The lab changes R2's Hello interval from 10 to 5 seconds and its IP MTU from 1500 to 1460 bytes:

```text
R2# configure terminal
R2(config)# interface GigabitEthernet0/0
R2(config-if)# ip ospf hello-interval 5
R2(config-if)# ip mtu 1460
R2(config-if)# end
```

These changes deliberately break the working relationship. After the relevant timers expire, the neighbor goes down.

Inspect the affected interface, rather than assuming every interface inherited the changes:

```text
R2# show ip ospf interface
R2# show interfaces GigabitEthernet0/0
R2# show ip interface GigabitEthernet0/0
```

The demonstration shows Hello 5 on GigabitEthernet0/0, interface MTU 1500, and IP MTU 1460.

### 3. Diagnose and Correct the Hello Mismatch

R1 initially has no neighbor entry because the Hello parameters do not match.

```text
R1# show ip ospf neighbor
R1# debug ip ospf hello
R1# undebug all
```

The debug identifies mismatched Hello parameters from `10.0.0.2`.

Compare both routers' interface settings and the intended design before changing them. `show running-config | section ospf` helps inspect the routing process, but also inspect interface configuration because timers are interface settings.

The lab adopts a 5-second Hello interval on R1:

```text
R1# configure terminal
R1(config)# interface GigabitEthernet0/0
R1(config-if)# ip ospf hello-interval 5
R1(config-if)# end
```

Verify that both effective Hello and Dead intervals match. The neighbor then becomes visible, but the demonstration shows it stuck in Exchange because the MTU problem remains.

### 4. Diagnose and Correct the MTU Mismatch

```text
R1# debug ip ospf adj
R1# undebug all
R1# show interfaces GigabitEthernet0/0
R1# show ip interface GigabitEthernet0/0
```

The adjacency debug reports an MTU difference. R1 still has IP MTU 1500; R2 has IP MTU 1460. The lab's intended value is 1460, so R1 is changed to match:

```text
R1# configure terminal
R1(config)# interface GigabitEthernet0/0
R1(config-if)# ip mtu 1460
R1(config-if)# end
R1# show ip ospf neighbor
```

Allow time for discovery and synchronization. The demonstration briefly shows Init before the relationship reaches Full.

### Process Resets and Debugging

The instructor uses this command after each fix to accelerate the lab:

```text
R1# clear ip ospf process
```

This resets the OSPF process and disrupts its neighbor relationships and learned routes. It is not a required repair step; allow reconvergence when a process reset is unnecessary. Repeatedly resetting the process can also prevent useful observation of the natural state progression.

Use configuration and interface checks before debugging. Stop debugging with `undebug all` after collecting the needed evidence.

## My Takeaways

- A neighbor entry proves discovery, while Full confirms completed database synchronization for that relationship.
- If discovery fails, compare the link's Hello parameters before investigating database exchange.
- If discovery succeeds but synchronization stalls, inspect both interface MTU and IP MTU.
- Router IDs identify OSPF participants; interface addresses identify the endpoints carrying their packets.
- Fix the intended configuration and allow convergence before considering a disruptive process reset.
