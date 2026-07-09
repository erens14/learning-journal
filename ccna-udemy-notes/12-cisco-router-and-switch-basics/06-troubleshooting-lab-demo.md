# CCNA Self Notes — Layer 1 and Layer 2 Lab Diagnostics

## Overview

This note captures practical lab observations detailing how Cisco IOS interfaces respond to live Physical Layer (Layer 1) and Data-Link Layer (Layer 2) failure states. By explicitly manipulating interface administrative states, speed constraints, and duplex properties between a core router (`R1`) and a local switch (`SW1`), this session demonstrates how line status pairs shift dynamically and how to diagnose layer-specific communication blocks using real-time console behaviors.

## Key Concepts

### Remote Shutdown Reflection

When a physical interface on one side of a link is manually disabled (`shutdown`), the local interface transitions to `administratively down / down`. However, the adjacent peer interface on the opposite end of the cable—which remains unconfigured and active—drops to a `down/down` state due to an immediate loss of physical layer signaling.

### Speed Mismatch Link Drop

Statically setting opposing interfaces to different communication speeds (e.g., 10Mbps vs. 100Mbps) corrupts physical layer clocking synchronization. This mismatch breaks the line signaling completely, causing a total link drop where one side reports `down/down` and the other side hangs at `up/down`.

### Duplex Mismatch Operational Traps

Statically setting one side of a link to `half` duplex while the other runs at `full` duplex does *not* drop the physical line status pair; interfaces on both sides typically remain `up/up`. Instead, data transfer drops into a highly degraded state due to chronic frame collisions, which are actively audited and flagged by the Cisco Discovery Protocol (CDP).

## How It Works

### Lab Baseline Topology Reference

- **Router R1 Interface Fa0/0:** Connected to SW1 Fa0/1 (`IP: 192.168.0.1`)
- **Switch SW1 Interface Fa0/1:** Connected to R1 Fa0/0 (`SVI VLAN 1 Management IP: 192.168.0.10`)

### State Transition Operational Logic

```text
  [ SCENARIO 1: LINK OPERATIONAL ]
  R1 (Fa0/0): up/up     <====================================> SW1 (Fa0/1): up/up
  
  [ SCENARIO 2: ADMIN SHUTDOWN ON ROUTER ]
  R1 (Fa0/0): administratively down/down (Shut)  X==========X  SW1 (Fa0/1): down/down (Loss of Signal)

  [ SCENARIO 3: SPEED MISMATCH INJECTED ]
  R1 (Fa0/0): up/down (Speed: 100)               X==========X  SW1 (Fa0/1): down/down (Speed: 10)

  [ SCENARIO 4: DUPLEX MISMATCH INJECTED ]
  R1 (Fa0/0): up/up (Duplex: Full)      <-- CDP Mismatch Alert --> SW1 (Fa0/1): up/up (Duplex: Half)
```

## Components / Structure

### Observed Lab Link States Matrix

| Experimental Action Performed | R1 Fa0/0 Line Status Pair | SW1 Fa0/1 Line Status Pair | Link Traffic State | Primary Diagnostic Indicator |
| --- | --- | --- | --- | --- |
| **Baseline Configuration** | `up` / `up` | `up` / `up` | **Functional** | Standard ICMP pings succeed with 100% reliability. |
| **Shutdown R1 Fa0/0 Port** | `administratively down` / `down` | `down` / `down` | **Total Outage** | Peer node senses immediate Layer 1 failure profile. |
| **Speed Mismatch (10 vs 100)** | `up` / `down` | `down` / `down` | **Total Outage** | Physical clock synchronization fails completely. |
| **Duplex Mismatch (Half vs Full)** | `up` / `up` | `up` / `up` | **Severely Degraded** | Console issues real-time `%CDP-4-DUPLEX_MISMATCH` alert. |

## Comparison

### Lab Error State Characteristics

| Diagnostic Parameter | Speed Mismatch Condition | Duplex Mismatch Condition |
| --- | --- | --- |
| **Impact on Status / Protocol Pair** | Immediately forces a line split (**up/down** vs **down/down**). | Both endpoints maintain an active **up/up** state status. |
| **Traffic Impact** | Absolute failure; zero packet throughput across the link. | Performance drops sharply under load due to constant collisions. |
| **Syslog Alert Generation** | No active console system logs generated (link is down). | Real-time console popups generated automatically by CDP. |
| **Administrative Fix Action** | Lock matching speed values and perform a link flap. | Align matching duplex parameters across both interface submodes. |

## Commands (If Applicable)

### Cisco IOS

#### 1. Simulating an Administrative Outage on Router R1

```text
Router-R1# configure terminal
Router-R1(config)# interface fastEthernet 0/0
Router-R1(config-if)# shutdown
```

#### 2. Injecting a Speed Mismatch Condition

```text
! On Switch SW1 side (Interface dropped to 10Mbps)
Switch-SW1(config)# interface fastEthernet 0/1
Switch-SW1(config-if)# speed 10

! On Router R1 side (Interface kept at 100Mbps)
Router-R1(config)# interface fastEthernet 0/0
Router-R1(config-if)# speed 100
Router-R1(config-if)# no shutdown
```

#### 3. Flapping a Link to Force Interface Re-Synchronization

```text
Switch-SW1(config)# interface fastEthernet 0/1
Switch-SW1(config-if)# speed 100
Switch-SW1(config-if)# shutdown
Switch-SW1(config-if)# no shutdown
```

#### 4. Injecting a Duplex Mismatch Condition

```text
! Hardcoding mismatched duplex variables across the endpoints
Switch-SW1(config)# interface fastEthernet 0/1
Switch-SW1(config-if)# duplex half

Router-R1(config)# interface fastEthernet 0/0
Router-R1(config-if)# duplex full

```

## Example

### Real-Time Lab CLI Output Captures

#### Speed Mismatch Verification (R1 View)

```text
Router-R1# show ip interface brief
Interface                  IP-Address      OK? Method Status                Protocol
FastEthernet0/0            192.168.0.1     YES manual up                    down    
```

*Observation:* The router registers active Layer 1 voltage (`up`), but the Layer 2 software protocol layer fails to initialize (`down`) due to the timing framing conflict.

#### Duplex Mismatch CDP Notification Capture

```text
Router-R1#
%CDP-4-DUPLEX_MISMATCH: duplex mismatch discovered on FastEthernet0/0 (not half duplex), with SW1 FastEthernet0/1 (half duplex).
```

*Observation:* The interface remains up/up, but CDP intercepts the neighbor's configuration advertisement and warns the administrator of the mismatch.

## Important Notes

- **Terminal Logging Constraint:** Automatic CDP duplex mismatch console warnings appear by default only on active **physical console connections**. If managing a device remotely via Telnet or SSH, these alerts must be read manually by issuing the `show logging` execution command.
- **The Post-Fix Link Flap Routine:** When fixing an active speed mismatch, the line can occasionally lock up or delay synchronization. Explicitly cycling the interface (`shutdown` followed immediately by `no shutdown`) forces the hardware components to clean out error states and cleanly re-negotiate.
- **Diagnostic Command Isolation:** Using `show ip interface brief` gives a quick overview of line availability, whereas executing `show interface <id>` exposes the explicit input/output error blocks and collision counters needed to confirm a duplex mismatch.

## My Takeaways

- A line state showing `down/down` on an active port is a strong indicator of a Layer 1 problem, such as a loose cable or a shutdown interface on the remote peer.
- Hardcoding different link speeds on adjacent ports breaks physical synchronization, completely bringing down the Layer 2 protocol layer.
- Duplex mismatches hide within operational `up/up` link states, making deep interface counter inspection or tracking CDP logs essential for detection.
- Running a duplex mismatch on an active link causes heavy frame collisions, severely degrading data transfer speeds.
- Consistently hardcoding matching speed and duplex properties across all core infrastructure connections eliminates auto-negotiation timing loops and configuration errors.
