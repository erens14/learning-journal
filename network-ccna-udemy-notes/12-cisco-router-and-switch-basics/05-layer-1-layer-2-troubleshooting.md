# Layer 1 and Layer 2 Troubleshooting

## Overview

Troubleshooting at the Physical Layer (Layer 1) and Data-Link Layer (Layer 2) of the OSI stack forms the baseline of network diagnostics. Layer 1 issues involve physical components like copper or fiber cabling, connector integrity, power delivery, and electromagnetic interference (EMI). Layer 2 issues typically manifest as logical configuration disparities between adjoining systems. Isolating these errors requires a deep understanding of operational status indicators and interface counters to differentiate between physical media degradation and systematic configuration mismatches.

## Key Concepts

### Physical Layer Integrity (Layer 1)

Physical infrastructure is vulnerable to physical stress. Bending, over-stretching, or bundling cables tightly can fracture internal copper wires or glass fibers. Furthermore, broken RJ45 retention clips lead to loose or unseated connections, while proximity to high-power motors or microwaves introduces Electromagnetic Interference (EMI), causing frame corruption.

### Interface Status Pairs

Cisco IOS reports interface states as a pair: **Status** (Layer 1 Physical Layer) and **Protocol** (Layer 2 Data-Link Layer). Interpreting these states directly guides the engineer toward the correct layer of the OSI model to investigate.

### Speed and Duplex Mismatch Anomalies

- **Speed Mismatches:** Occur when two endpoints are statically configured to run at different speeds (e.g., 10Mbps vs. 100Mbps). This disparity completely breaks the physical link signaling, causing the interface state to drop entirely.
- **Duplex Mismatches:** Occur when one side is hardcoded (typically full-duplex) and the other is set to auto-negotiate. When the automated side fails to detect negotiation signals, it falls back to half-duplex. The link remains operational but suffers from extreme collision rates and packet drops under heavy loads.

## How It Works

### Interface Diagnostic Decision Tree

```text
                  [ Execute: show ip interface brief ]
                                    |
       +----------------------------+----------------------------+
       |                            |                            |
[ State: Admin Down ]       [ State: Down/Down ]         [ State: Up/Down ]
       |                            |                            |
  (Layer 1 Fix)                (Layer 1 Fix)                (Layer 2 Fix)
       |                            |                            |
Run 'no shutdown'           - Check cable seating.       - Check for VLAN mismatch.
on the interface interface. - Confirm peer is powered.   - Inspect Duplex settings.
                            - Swap out patch cord.       - Run 'show interface'
                                                           to track collision logs.
```

## Components / Structure

### Interpreting 'show ip interface brief' Line States

| Status (Layer 1) | Protocol (Layer 2) | Diagnostic Interpretation | Primary Action Plan |
| --- | --- | --- | --- |
| **administratively down** | **down** | The interface has been manually disabled by an administrator. | Enter interface mode and issue the `no shutdown` command. |
| **down** | **down** | A physical layer fault is present; the interface is enabled but detects no signaling. | Check cables, ensure the remote device is powered on, and check for broken clips. |
| **up** | **down** | Physical connection is successful, but Data-Link framing or parameters mismatch. | Check for speed/duplex settings, encapsulation differences, or native VLAN mismatches. |
| **up** | **up** | The interface is fully functional across both physical and logical layers. | Normal state; proceed to layer 3 diagnostics if connectivity issues persist. |

## Comparison

### Speed Mismatch vs. Duplex Mismatch Profiles

| Characteristic | Speed Mismatch | Duplex Mismatch |
| --- | --- | --- |
| **Link State Impact** | Direct Outage (Interface transitions to **down/down**). | Degraded State (Interface remains **up/up** or **up/down**). |
| **Performance Symptom** | Zero throughput; total layer 1 packet drop. | High input/output error counts, collisions, and sluggish performance. |
| **Cisco Discovery Protocol (CDP)** | Unable to log warnings due to link down state. | Actively detects anomalies and logs syslog warning alerts to the CLI console. |
| **Root Cause Trap** | Hardcoding differing metric limits on opposing nodes. | Mixing an automated endpoint with a statically configured peer node. |

## Commands (If Applicable)

### Cisco IOS

#### 1. Checking Global Interface Line States

```text
Router# show ip interface brief
Interface                  IP-Address      OK? Method Status                Protocol
FastEthernet0/0            192.168.0.1     YES manual up                    up      
FastEthernet0/1            unassigned      YES unset  administratively down down    
FastEthernet0/2            unassigned      YES unset  down                  down    
FastEthernet0/3            unassigned      YES unset  up                    down    
```

#### 2. Detailed Interface Statistics Auditing

```text
! Target a specific interface to prevent overwhelming text output
Router# show interface fastEthernet 0/2
FastEthernet0/2 is up, line protocol is up 
  Full-duplex, 100Mbps, media type is 10/100BaseTX
  0 input errors, 0 CRC, 0 frame, 0 overruns, 0 ignored
  0 output errors, 0 collisions, 0 interface resets
```

#### 3. Resolving Duplex and Speed Lockups on Infrastructure Interfaces

```text
Router# configure terminal
Router(config)# interface fastEthernet 0/0
Router(config-if)# speed 100
Router(config-if)# duplex full
Router(config-if)# no shutdown
Router(config-if)# end
```

## Example

### Real-World Duplex Mismatch System Log Output

When an interface is hardcoded to full-duplex while its neighbor is left on auto-negotiation, the Cisco Discovery Protocol (CDP) will automatically catch the mismatch and generate a clear syslog notification on the console terminal:

```text
%CDP-4-DUPLEX_MISMATCH: duplex mismatch discovered on FastEthernet0/0 (not half duplex), with Switch Fas 0/1 (half duplex).
```

If you audit the interface stats during this condition, the error counters will rise continuously under load:

```text
Router# show interface fastEthernet 0/0
FastEthernet0/0 is up, line protocol is up
  Half-duplex, 100Mbps
  2459 input errors, 1842 CRC, 0 frame
  3814 output errors, 2941 collisions, 0 interface resets
```

*Analysis:* The high counts of **CRC errors**, **output errors**, and **collisions** prove that a duplex mismatch is forcing frames to collide on the wire. Statically defining `duplex full` and `speed 100` on both ends of the cable will immediately resolve the issue.

## Important Notes

- **Security Best Practice:** Unused ports on enterprise switches should always be manually placed into an `administratively down` state via the `shutdown` command to prevent unauthorized physical network access.
- **The Auto-Negotiation Rule:** Never mix configuration styles. Keep both endpoints of a cable segment set to `auto` or hardcode both sides manually to ensure stable link parameters.
- **Cabling Hygiene:** Avoid bending or tightly binding network patch cords. Modern high-category cabling relies heavily on precise internal twisting and structural shielding to defend against data corruption and cross-talk.

## My Takeaways

- `show ip interface brief` is the best starting command for physical path troubleshooting, allowing engineers to instantly pinpoint layer 1 or layer 2 faults.
- Statically hardcoding different speeds on opposing sides of a cable drops the entire link down, whereas a duplex mismatch leaves the link up but causes terrible performance.
- Core infrastructure links (routers, switches, firewalls, and servers) should be manually configured for speed and duplex to prevent auto-negotiation failures.
- End-user access ports (PCs and laptops) should remain configured for auto-negotiation to seamlessly accommodate a wide variety of client network interface cards.
- CDP acts as a valuable background layer 2 auditor, automatically logging duplex configuration errors to the console terminal to save engineers manual troubleshooting time.
