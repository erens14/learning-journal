# OSPF Cost Metric

## Overview

OSPF uses cost to compare paths. For the internal path examples in this lecture, the total is the sum of the outgoing interface costs, including the final interface toward the destination subnet. A lower total is preferred among the competing paths.

These notes use the cost and lab sections of the supplied **OSPF Cost Metric** transcript. The instructor's reported route changes are not results from a lab I executed.

## How Path Cost Works

Within an area, the router uses its link-state information and the Shortest Path First (SPF) algorithm to select paths. A path with more router hops can win if its cumulative cost is lower.

The calculation uses interfaces in the direction of travel. The same physical link can therefore contribute a different cost in the reverse direction if its two interface costs differ.

### Multiarea Clarification

An ABR maintains information for each attached area. A router outside the destination area learns inter-area reachability information rather than that area's complete topology.

The transcript simplifies this to choosing the lowest-cost path to an ABR. More precisely, an inter-area candidate includes **the cost to the advertising ABR plus the cost that ABR advertises for the destination**. Choosing the nearest ABR alone is insufficient. See [RFC 2328, Section 16.2](https://www.rfc-editor.org/rfc/rfc2328.html#section-16.2).

Inter-area summary information need not be a manually aggregated prefix; individual prefixes can also be advertised between areas.

## Outgoing Interfaces in Each Direction

The transcript describes two paths between the networks behind R4 and R1:

```text
                      R3 ---- R2
                     /          \
10.1.2.0/24 ---- R4                R1 ---- 10.0.1.0/24
                     \          /
                          R5

Top path: R4 -- R3 -- R2 -- R1
Bottom path: R4 -- R5 -- R1
```

The diagram preserves the stated router connections. Host addresses and link subnets are not supplied for this explanation.

| Direction | Path | Outgoing interfaces included in the cost |
| --- | --- | --- |
| R4 toward `10.0.1.0/24` | Top | R4 FastEthernet0/0; R3 FastEthernet1/0; R2 FastEthernet0/0; R1 FastEthernet1/0 |
| R4 toward `10.0.1.0/24` | Bottom | R4 FastEthernet2/0; R5 FastEthernet3/0; R1 FastEthernet1/0 |
| R1 toward `10.1.2.0/24` | Top | R1 FastEthernet0/0; R2 FastEthernet1/0; R3 FastEthernet0/0; R4 FastEthernet1/0 |
| R1 toward `10.1.2.0/24` | Bottom | R1 FastEthernet3/0; R5 FastEthernet2/0; R4 FastEthernet1/0 |

These explicit interface lists resolve the transcript's later confused sentence about which router owns the reverse-direction interface.

### Cost Consistency and Asymmetric Routing

The lecture recommends matching costs at both ends of a link when the intention is comparable routing in both directions. Different outgoing costs can cause forward and return traffic to use different paths.

Matching link costs is a design choice, not an OSPF adjacency requirement. It also should not be treated as a universal guarantee that every forward and reverse path will match.

## Calculation Example: Cost Beats Hop Count

In a separate three-router example, R2 can reach `10.0.1.0/24` directly through R1 or through R3:

```text
R2 -------- cost 50 -------- R1 ---- cost 10 ---- 10.0.1.0/24
 \                          /
  cost 10              cost 10
       \                /
               R3

Costs shown are for travel from R2 toward the destination.
```

1. Direct path: `50 + 10 = 60`.
2. Path through R3: `10 + 10 + 10 = 30`.
3. OSPF prefers the path through R3 because `30 < 60`.

The destination-facing interface cost is included in both totals. Fewer hops do not necessarily mean a lower metric. These costs alone do not prove measured link quality or latency.

## Automatic Interface Cost

Cisco IOS derives an interface's OSPF cost from its bandwidth setting unless an explicit OSPF cost overrides it:

```text
Calculated cost = reference bandwidth / interface bandwidth

Use the same units for both bandwidth values.
Default reference bandwidth in this lecture: 100 Mbps
Minimum interface cost: 1
```

The calculation uses the **IOS interface bandwidth value**, not a measurement of current throughput. Higher bandwidth can lower an interface's calculated cost, but OSPF still compares total path costs.

### Default Examples

| Interface example | Calculation with 100 Mbps reference | Resulting cost |
| --- | --- | --- |
| FastEthernet, 100 Mbps | `100 / 100 = 1` | 1 |
| T1 example, 1.544 Mbps | `100 / 1.544 = 64.7668...` | 64 |
| GigabitEthernet, 1,000 Mbps | `100 / 1000 = 0.1` | 1, the minimum |
| 10 GigabitEthernet, 10,000 Mbps | `100 / 10000 = 0.01` | 1, the minimum |

**Calculation correction:** `100 / 1.544` is approximately `64.77`, not exactly 64. The IOS integer cost in the lecture's T1 example is 64. Fractional values below 1 do not produce fractional OSPF interface costs.

With this reference value, 100 Mbps and faster interfaces all have cost 1. Faster Ethernet links therefore lose their distinction in the metric.

## Increasing Reference Bandwidth

The reference-bandwidth command takes **Mbps**:

```text
router ospf 1
 auto-cost reference-bandwidth 100000
```

Here, `100000 Mbps = 100 Gbps`. Configure the same reference bandwidth on all routers in the OSPF domain so the automatic costs use a consistent scale.

| Reference bandwidth | FastEthernet: 100 Mbps | GigabitEthernet: 1,000 Mbps |
| --- | --- | --- |
| 100 Mbps | `100 / 100 = 1` | `100 / 1000 = 0.1`, minimum 1 |
| 1,000 Mbps | `1000 / 100 = 10` | `1000 / 1000 = 1` |
| 100,000 Mbps | `100000 / 100 = 1000` | `100000 / 1000 = 100` |

Choose a value that distinguishes the current link speeds and allows for planned upgrades. The lecture's `100000` is an example, not a universally suitable setting for every network. Check resulting costs on slower interfaces as well.

Cisco documents the command units, automatic calculation, and explicit-cost override in its [OSPF command reference](https://www.cisco.com/c/en/us/td/docs/ios-xml/ios/iproute_ospf/command/iro-cr-book/m_ospf-a1.html).

### FastEthernet Direct Path vs Gigabit Detour

Another lecture example uses a direct FastEthernet link between R2 and R1, with a two-link GigabitEthernet alternative through R3.

At the default reference bandwidth:

```text
Direct: 1 + 1 = 2
Via R3: 1 + 1 + 1 = 3

Both paths include the same destination-facing interface cost of 1.
The direct FastEthernet path wins.
```

At a reference bandwidth of 100,000 Mbps:

```text
Direct transit interface: 100000 / 100 = 1000
Each Gigabit transit interface: 100000 / 1000 = 100

Let C be the common destination-facing interface cost.
Direct total: 1000 + C
Via R3 total: 100 + 100 + C = 200 + C

The Gigabit path wins because 200 + C is lower than 1000 + C.
```

Using `C` avoids assigning an unstated interface speed to the shared destination link. These are path-cost calculations, not throughput measurements.

## Manually Changing Cost

The lecture gives a high-bandwidth but high-latency satellite link as a reason to override the automatic choice. Automatic cost uses bandwidth, not latency. An administrator can raise cost to make another path preferable.

There are two methods:

| Method | Example | Scope of effect |
| --- | --- | --- |
| Change interface bandwidth | `bandwidth 768` on Serial1/0 | Can affect OSPF, other routing metrics, and software policies |
| Set OSPF cost directly | `ip ospf cost 50` on FastEthernet0/0 | Changes that interface's OSPF cost |

The lecture recommends explicit OSPF cost when only OSPF preference needs to change:

```text
interface FastEthernet0/0
 ip ospf cost 50
```

An explicit cost overrides the automatic bandwidth-derived value. Raising a reference bandwidth therefore does not recalculate an interface that already has an explicit cost.

## Verification Commands

Run these from privileged EXEC mode, or use the transcript's `do` prefix when running a show command from configuration mode:

```text
show ip route
show ip ospf interface
show ip ospf interface FastEthernet0/0
show ip ospf interface brief
show interfaces Serial1/0
```

- The routing table shows the selected next hop, administrative distance, and metric.
- Detailed OSPF interface output shows the active cost on a selected interface.
- The brief output makes it easier to compare costs across interfaces.
- Serial interface output shows the software bandwidth value; it does not by itself mean the clock rate equals that value.

## Lab: Change the R1-to-R4 Path

The lab uses R1 through R5 with FastEthernet interfaces. R1 is reaching `10.1.2.0/24` behind R4.

```text
Top:    R1 -- R2 -- R3 -- R4 -- 10.1.2.0/24
Bottom: R1 -- R5 ------- R4 -- 10.1.2.0/24

R1 next hop toward R2: 10.0.0.2
R1 next hop toward R5: 10.0.3.2
```

### 1. Inspect the Initial Route

The instructor runs `show ip route` on R1 and reports:

- Destination: `10.1.2.0/24`.
- Selected next hop: `10.0.3.2`, R5 on the bottom path.
- OSPF administrative distance: 110.
- Path cost: 3, from `1 + 1 + 1`.

The three cost contributions are R1 toward R5, R5 toward R4, and R4 toward the destination subnet. Administrative distance 110 and cost 3 are separate values.

### 2. Set the Same Reference Bandwidth on All Five Routers

Apply this configuration to R1, R2, R3, R4, and R5:

```text
configure terminal
router ospf 1
 auto-cost reference-bandwidth 100000
```

Each FastEthernet interface now has calculated cost 1,000:

```text
100000 / 100 = 1000 per interface
Bottom path: 1000 + 1000 + 1000 = 3000
Top path: 1000 + 1000 + 1000 + 1000 = 4000
```

The instructor reports that R1 still uses R5, with the bottom path's cost now 3,000. Scaling all the equal-speed interfaces does not change their relative path preference.

One paste into R2 is corrupted in the demonstration. The instructor copies the commands again and verifies they are accepted. Check command feedback even when deploying identical text to several routers.

### 3. Raise Costs on the Bottom Transit Links

The instructor sets both directions of the R1–R5 and R5–R4 links to 2,000.

On R1:

```text
interface FastEthernet3/0
 ip ospf cost 2000
```

On R5:

```text
interface FastEthernet2/0
 ip ospf cost 2000
interface FastEthernet3/0
 ip ospf cost 2000
```

On R4:

```text
interface FastEthernet2/0
 ip ospf cost 2000
```

These commands are entered from global/interface configuration mode on the named routers. The correct command is `ip ospf cost 2000`; the failed `ip cost ospf` wording in the transcript is not a valid configuration step.

For R1 toward the destination:

```text
Bottom: 2000 + 2000 + 1000 = 5000
Top:    1000 + 1000 + 1000 + 1000 = 4000

4000 < 5000, so the top path becomes preferred.
```

The destination-facing interface on R4 remains at cost 1,000. The configuration changes the four transit interfaces at the two ends of the bottom links.

**Routing impact:** changing reference bandwidth or interface cost can trigger recalculation and move traffic to another path. Apply and verify such changes deliberately on a live network.

### 4. Verify the New Next Hop

The instructor checks `show ip route` on R1 again and reports that the next hop changes from `10.0.3.2` through R5 to `10.0.0.2` through R2.

The expected top-path cost from the stated settings is 4,000. This is a calculation; the transcript does not quote the final full routing-table entry. No packet capture, throughput result, or personal lab execution is claimed.

## My Takeaways

- I should sum outgoing interface costs, including the interface toward the destination subnet, instead of counting only router hops.
- Default reference bandwidth makes 100 Mbps and faster links indistinguishable; a consistent higher value restores useful differences.
- Interface bandwidth is a configured input, not measured throughput or the physical clock rate.
- Inter-area cost includes the ABR's advertised destination cost, not only the path to that ABR.
- An explicit OSPF cost has a narrower effect than changing bandwidth and takes precedence over automatic calculation.
- I need to check both interface costs and the selected next hop after a routing change; accepted configuration text alone is insufficient.
