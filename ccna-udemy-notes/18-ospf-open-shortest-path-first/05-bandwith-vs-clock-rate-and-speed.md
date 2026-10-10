# Bandwidth vs Clock Rate and Speed

## Overview

Physical transmission speed and the IOS interface bandwidth setting are different things. Ethernet `speed` and serial clocking affect the physical link. The `bandwidth` command supplies a value used by software features such as routing metrics and some QoS calculations.

These notes use the bandwidth section of the supplied **OSPF Cost Metric** transcript. The examples are study references, not configurations I have executed.

## Command Comparison

| Command | Context | Unit in the lecture example | Effect |
| --- | --- | --- | --- |
| `speed 10` | Supported Ethernet interface | Mbps | Sets the Ethernet speed to 10 Mbps |
| `clock rate 64000` | Supported serial interface providing clocking | Bits per second | Sets a clock rate of 64,000 bps, or 64 Kbps |
| `bandwidth 768` | Interface configuration | Kilobits per second | Sets the software bandwidth value to 768 Kbps |

These are interface-level commands. Supported settings depend on the interface hardware.

## Ethernet Speed

The lecture uses FastEthernet at 100 Mbps and GigabitEthernet at 1,000 Mbps as examples. On a supported FastEthernet interface, `speed 10` changes the physical rate to 10 Mbps.

```text
speed 10
```

This changes link behavior and can interrupt connectivity. Configure compatible settings at both ends. The named interface capacity does not prove the actual operating speed; Ethernet interfaces may negotiate a supported rate.

## Serial Clock Rate

In a directly connected serial lab, the DCE side provides clocking and the DTE side uses that clock. The transcript's instruction to configure a clock rate on both ends is too broad: do not assume both ends independently generate the clock.

```text
clock rate 64000
```

The unit is **bits per second**, not kilobits per second:

```text
64,000 bps / 1,000 = 64 Kbps
```

The lecture's T1 example uses `1.544 Mbps`, which equals `1,544 Kbps`. That is not a universal physical clock rate for every serial interface. Clocking and defaults depend on the hardware and service. See [Cisco's `clock rate` reference](https://www.cisco.com/c/en/us/td/docs/ios-xml/ios/interface/command/ir-cr-book/ir-c2.html).

Changing the clock rate changes physical timing. It is not a way to adjust only OSPF's route preference.

## Interface Bandwidth

The IOS `bandwidth` setting does **not** change physical transmission speed. The command takes a value in Kbps. See [Cisco's `bandwidth` reference](https://www.cisco.com/E-Learning/bulk/public/tac/cim/cib/using_cisco_ios_software/cmdrefs/bandwidth.htm).

The transcript gives two examples:

- A FastEthernet link operating at 100 Mbps still operates at that speed if its software bandwidth value is set to 50 Mbps.
- Changing a serial interface's bandwidth from 1,544 Kbps to 768 Kbps does not change its physical clock rate.

The supplied serial configuration example is:

```text
R1(config)# interface Serial1/0
R1(config-if)# bandwidth 768
```

Inspect the bandwidth reported for that interface with:

```text
show interfaces Serial1/0
```

### Why Software Features Use This Value

The lecture identifies these consumers of interface bandwidth:

- **OSPF:** automatically calculates cost from reference bandwidth divided by interface bandwidth.
- **EIGRP:** uses bandwidth as an input to its metric.
- **QoS:** some percentage-based policies use the bandwidth value when calculating allocations.

For the lecture's example of a policy assigning one third of interface bandwidth to video traffic, the configured bandwidth supplies the basis for that calculation. This is policy configuration, not proof of measured throughput or an unconditional end-to-end guarantee.

Normally, set bandwidth to represent the link capacity used for planning those features. For a 64 Kbps or 128 Kbps serial link, leaving a reported bandwidth of 1,544 Kbps can misrepresent that capacity to routing and policy calculations.

Deliberately changing bandwidth can influence path selection, but it can also affect other software features. If the goal is only to change OSPF preference, the lecture recommends setting `ip ospf cost` instead.

## My Takeaways

- I need to inspect actual link operation separately from the bandwidth value used by IOS software.
- `clock rate` uses bps, while `bandwidth` uses Kbps. Confusing their units changes the intended value by a factor of 1,000.
- DCE and DTE have different clocking roles; serial defaults are not universal physical speeds.
- Adjusting interface bandwidth can affect both routing and policy calculations without slowing the physical interface.
- For an OSPF-only change, I should prefer an explicit OSPF cost over altering bandwidth metadata.
