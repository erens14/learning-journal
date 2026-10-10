# OSPF Areas

## Overview

OSPF areas divide a routing domain into smaller topology and flooding scopes. Routers keep detailed link-state information for their own areas and learn reachability information for destinations in other areas through Area Border Routers (ABRs).

These notes use the supplied **OSPF Areas** lecture transcript as the primary source. They cover the design explanation and the single-area-to-multiarea lab demonstration. Reported lab observations belong to the instructor, not to a lab I executed.

## Why Divide OSPF into Areas?

A large topology creates more link-state information to store and more work when paths change. Areas limit the detailed topology each router needs to understand. Route aggregation at an ABR can further reduce the number of advertised prefixes.

Keep two benefits separate:

- **Area boundaries:** separate detailed topology flooding and area SPF calculations.
- **Route aggregation:** replace several prefixes with a larger summary, reducing route entries outside the source area.

An LSDB and a routing table are different structures. Areas can reduce topology information without reducing the number of destination prefixes in the routing table.

**Transcript correction:** multiple areas still provide topology separation without manual aggregation. They do not behave exactly like one large area. Changes can nevertheless affect other areas when advertised reachability or cost changes. See [RFC 2328, Section 3](https://www.rfc-editor.org/rfc/rfc2328.html#section-3).

## The Two-Level Hierarchy

- **Area 0:** the backbone that connects the nonbackbone areas.
- **Nonbackbone areas:** areas such as Area 1 and Area 2, typically containing access networks and end users in the lecture's design.

Conceptual hierarchy from the lecture:

```text
                 Area 0: backbone
                 /              \
               ABR              ABR
                |                |
             Area 1           Area 2

Inter-area path: Area 1 -- ABR -- Area 0 -- ABR -- Area 2
```

In this standard design, inter-area routing uses the backbone. Area 1 and Area 2 are not connected as an independent hierarchy that bypasses Area 0.

For a small network, the lecture recommends one area using Area 0. Starting with the backbone area makes later expansion easier. Treat this as the design used in the course, rather than interpreting "single area is always Area 0" as an unconditional protocol requirement.

The backbone often serves transit traffic in a multiarea design. The lecture's placement of end users in nonbackbone areas is a design choice, not a prohibition on users in Area 0.

## Assigning Interfaces to Areas

An OSPF `network` statement is entered under the routing process. It selects interfaces by their IP addresses and assigns those interfaces to an area:

```text
router ospf 1
 network 10.0.0.0 0.0.255.255 area 0
```

This matches interface addresses beginning with `10.0` and places them in Area 0. It does not create an advertised `/16` summary by itself.

Both ends of an OSPF link must agree on the area. An area mismatch prevents the expected adjacency. The process IDs remain locally significant; the area ID on the shared link does not.

## Router Roles

| Role | Meaning | Area knowledge |
| --- | --- | --- |
| Internal router | All OSPF interfaces belong to one area | Detailed LSDB for that area |
| Backbone router | Has an interface in Area 0 | Participates in the backbone LSDB |
| ABR | Connects Area 0 and a nonbackbone area in this design | Separate LSDB for each attached area |
| ASBR | Introduces routes from another routing source into OSPF | Advertises external routing information |

**Definition correction:** a backbone router does not need every interface in Area 0. An ABR attached to Area 0 is also a backbone router. ASBR is an independent role that can overlap the other classifications. See [RFC 2328, Section 3.3](https://www.rfc-editor.org/rfc/rfc2328.html#section-3.3).

### ABR Responsibilities

An ABR separates the detailed flooding scopes of its attached areas. It knows their local topologies and advertises inter-area reachability information.

The lecture recommends connecting an ABR to the backbone and one nonbackbone area as a simple design. That recommendation does not mean an ABR can only connect two areas.

An ABR does not automatically combine all individual prefixes into a larger aggregate. The `area range` commands below explicitly configure that aggregation. Inter-area information without aggregation can still describe individual destination prefixes.

ABRs can also provide defaults in appropriate area configurations. An ordinary nonbackbone area does not automatically receive a default merely because it has an ABR.

### ASBR Responsibilities

The lecture gives RIP routes, EIGRP routes, and static routes as examples of information introduced into OSPF. A router performing that redistribution is an Autonomous System Boundary Router (ASBR).

An external route means that its information originated outside OSPF's internal routing calculation. It does not mean that the destination belongs to another organization.

**Scope correction:** inter-area aggregation belongs on ABRs. Summarizing redistributed external routes is a separate function associated with ASBRs; "all OSPF summarization happens only on ABRs" is too broad. Default origination also requires the relevant configuration. See [Cisco's OSPF Configuration Guide](https://www.cisco.com/c/en/us/td/docs/routers/ios/config/17-x/ip-routing/b-ip-routing/m_iro-cfg-0.html).

## Reading OSPF Route Codes

| Code | Meaning |
| --- | --- |
| `O` | OSPF intra-area route |
| `O IA` | OSPF inter-area route |
| `O E1` | OSPF external Type 1 route |
| `O E2` | OSPF external Type 2 route |
| `O*E2` | OSPF external Type 2 route marked as a candidate default |

Intra-area and inter-area describe the destination's area relationship to the router. They are not determined merely by whether the immediate neighbor is in the same area.

**Transcript correction:** `*` means candidate default, not external. An external route need not have an asterisk. These codes follow [Cisco's `show ip route` command reference](https://www.cisco.com/c/en/us/td/docs/ios-xml/ios/iproute_pi/command/iri-cr-book/iri-cr-s1.html).

## Inter-Area Summarization Example

The theory example uses R2 as an ABR:

```text
Area 0                         R2 ABR                         Area 1
R1                             FastEthernet1/0: Area 0        R3, R4
10.1.0.0/24                    FastEthernet0/0: Area 1        10.0.0.0/24
10.1.1.0/24                                                   10.0.1.0/24
                                                              10.0.2.0/24

Area membership view only; complete physical links are not supplied.
```

R2's configuration in this example:

```text
router ospf 1
 network 10.1.0.0 0.0.255.255 area 0
 network 10.0.0.0 0.0.255.255 area 1
 area 0 range 10.1.0.0 255.255.0.0
 area 1 range 10.0.0.0 255.255.0.0
```

The area number on `area range` identifies the **source area** whose routes are summarized:

- `area 0 range` aggregates the `10.1` networks for advertisement into Area 1.
- `area 1 range` aggregates the `10.0` networks for advertisement into Area 0.

### Why These Summaries Are /16

The lecture chooses aggregates that preserve the shared first two octets:

```text
Area 1 prefixes:
10.0.0.0/24
10.0.1.0/24
10.0.2.0/24

Shared first two octets: 10.0
Fixed bits: 8 + 8 = 16
Chosen summary: 10.0.0.0/16
Subnet mask: 255.255.0.0
Covered range: 10.0.0.0 through 10.0.255.255

Area 0 prefixes:
10.1.0.0/24
10.1.1.0/24

Shared first two octets: 10.1
Chosen summary: 10.1.0.0/16
Subnet mask: 255.255.0.0
```

These are the lecture's chosen aggregates, not the smallest possible ranges for only the listed prefixes. A `/16` includes addresses beyond those examples. Plan address allocation so the summary represents the intended area.

| Command | Mask type | Purpose |
| --- | --- | --- |
| `network 10.0.0.0 0.0.255.255 area 1` | Wildcard mask | Select participating interfaces |
| `area 1 range 10.0.0.0 255.255.0.0` | Subnet mask | Aggregate routes from Area 1 |

### A Link Failure Behind a Summary

If `10.0.0.0/24` fails, Area 1 routers must update their local topology and paths. R1 in Area 0 may continue to see the same `10.0.0.0/16` summary while other component routes remain reachable through R2.

This can reduce changes outside Area 1, but it does not guarantee that every remote router remains unaffected. A summary can change cost or be withdrawn if its supporting reachability disappears. An unchanged summary also does not make the failed `/24` reachable. See [Cisco's OSPF summarization discussion](https://www.cisco.com/c/en/us/td/docs/solutions/Enterprise/Campus/routed-ex.html).

## Lab: Convert Five Routers to Multiple Areas

The lab uses the same physical topology as the earlier demonstrations. Initially, R1 through R5 participate in Area 0, and their internal interface addresses begin with `10`.

The target roles are:

| Router | Target role | Area assignments stated in the transcript |
| --- | --- | --- |
| R1 | Internal router in Area 1 | All participating interfaces in Area 1 |
| R2 | ABR | FastEthernet1/0 in Area 0; FastEthernet0/0 in Area 1 |
| R3 | Internal backbone router | Remains in Area 0 |
| R4 | Internal backbone router | Remains in Area 0 |
| R5 | ABR | FastEthernet2/0 in Area 0; FastEthernet3/0 in Area 1 |

The theory and lab examples assign different roles to R1, R3, and R4. Keep their diagrams separate.

Partial lab view using only stated connections:

```text
Area 0: R3 and R4; internal links not supplied

R2 ABR: FastEthernet1/0 in Area 0
R5 ABR: FastEthernet2/0 in Area 0

R2 FastEthernet0/0 ---- R1 ---- R5 FastEthernet3/0
       Area 1                     Area 1

R1 interface toward R2: FastEthernet0/0, Area 1
R1 interface toward R5: name not supplied, Area 1

R1 forms Area 1 adjacencies with both R2 and R5.
```

### 1. Review the Existing Configuration

The instructor checks these commands before the change:

```text
show running-config | section ospf
show ip route
```

The original configuration uses process 1 and a statement matching all `10` addresses into Area 0. The instructor reports that R1 and R4 initially show intra-area `O` routes for the learned internal networks.

### 2. Configure the ABRs: R2 and R5

Apply the following under process 1 on **both R2 and R5**:

```text
configure terminal
router ospf 1
 no network 10.0.0.0 0.255.255.255 area 0
 network 10.1.0.0 0.0.255.255 area 0
 network 10.0.0.0 0.0.255.255 area 1
```

The replacement ranges do not overlap: `10.1.X.X` belongs to Area 0, and `10.0.X.X` belongs to Area 1. The transcript briefly says `10.0` while describing the first statement; the command and the later explanation consistently specify `10.1`.

At this intermediate stage, R1 still uses Area 0. The instructor reports area-mismatch messages on its links to the newly configured ABRs. This is an incomplete migration state, not evidence that the final configuration works.

**Disruption:** changing interface area assignments interrupts the affected adjacencies until both ends agree. Review the existing statements before removing them and plan a maintenance window for a live migration.

### 3. Move R1 into Area 1

On R1, replace the original statement with a broad match into Area 1:

```text
configure terminal
router ospf 1
 no network 10.0.0.0 0.255.255.255 area 0
 network 10.0.0.0 0.255.255.255 area 1
```

R3 and R4 retain their Area 0 configuration. Once R1's area matches its neighbors, the instructor reports that its adjacencies with R2 and R5 return.

### 4. Inspect Routes Before Aggregation

From privileged EXEC mode, check R4:

```text
show ip route
```

R4 is in Area 0. Its learned `10.0.X.X` destinations in Area 1 now appear as `O IA` routes rather than `O` routes. The instructor reports four individual prefixes at this stage, but the transcript does not list all four addresses.

The prefix count has not yet fallen. This shows that area assignment and route aggregation are separate changes.

### 5. Configure Summaries on Both ABRs

Under OSPF process 1 on **R2 and R5**, configure:

```text
router ospf 1
 area 0 range 10.1.0.0 255.255.0.0
 area 1 range 10.0.0.0 255.255.0.0
```

Both ABRs use the same source-area ranges. The summary commands use subnet masks, not wildcard masks.

### 6. Verify the Reported Result

Check `show ip route` on R4 and R1 after convergence:

- **R4 in Area 0:** the instructor reports one `10.0.0.0/16` inter-area summary instead of the four individual Area 1 `/24` prefixes.
- **R1 in Area 1:** the instructor reports one `10.1.0.0/16` inter-area summary for the Area 0 networks.

These are narrated observations. Exact output, metrics, timers, and full next-hop addresses are not supplied, so they are not reconstructed as execution evidence.

## My Takeaways

- I should distinguish a smaller topology database from fewer route entries; area separation and aggregation solve related but different problems.
- The area on a shared link must agree at both ends, even though local process IDs may differ.
- Router roles can overlap: an ABR participating in Area 0 is also a backbone router.
- In `area range`, I name the source area and use a subnet mask. In `network`, I select interfaces with a wildcard mask.
- A summary hides component prefixes, but it does not restore a failed destination or guarantee complete isolation from every change.
- I need to label theory and lab topologies separately when the same router names have different area assignments.
