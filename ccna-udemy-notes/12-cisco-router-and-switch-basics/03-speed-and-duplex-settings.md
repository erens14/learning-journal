# Speed and Duplex Settings

## Overview

Both ends of an Ethernet link need compatible speed and duplex settings. These notes cover auto-negotiation, manual settings, duplex mismatches, and IOS commands for checking interface status and counters.

## Key Concepts

### Auto-Negotiation

The default state (`auto`) where two connected endpoints automatically negotiate the highest mutually supported speed and optimal duplex setting (typically full-duplex).

### Duplex Mismatch

The lab demonstrates a duplex mismatch with one side set manually to full-duplex and the other left on `auto`. The auto side falls back to half-duplex, and traffic produces collisions and interface errors.

### Line Status vs. Protocol Status

In verification outputs, interface operational states are evaluated using two distinct layers:

- **Status (Layer 1):** Indicates physical layer connectivity (e.g., cable plugged in, receiving signal).
- **Protocol (Layer 2):** Indicates data-link layer health (e.g., keepalives, matching framing protocols).

## How It Works

### Duplex Settings Configuration and Mismatch Traps

```text
CORRECT APPROACH 1: BOTH SIDE AUTO (Default)
[ Switch Port: AUTO ] <--- Auto-Negotiation Exchange ---> [ Server NIC: AUTO ]
Result: Link successfully resolves to optimal speed/duplex (e.g., 100Mbps / Full)

CORRECT APPROACH 2: BOTH SIDE MANUAL (Best Practice for Infrastructure)
[ Switch Port: 100/Full ] <====== Hardcoded Static Link ======> [ Router Port: 100/Full ]
Result: Stable, highly reliable link; avoids auto-negotiation timing loops.

INCORRECT MISMATCH TRAP: MIXING CONFIGURATIONS
[ Switch Port: 100/Full ] <====== Manual vs Auto Break ======> [ Server NIC: AUTO ]
Result: Server fails to negotiate, defaults to Half-Duplex. Massive collisions occur!
```

*Note: When hardcoding speed or duplex parameters on a live Cisco interface, the link will temporarily flap (turn completely down and come back up) to apply the hardware signaling changes.*

## Components / Structure

### Essential Cisco IOS Verification Toolset

| Verification Command | Operational Target | Key Output Data Fields Provided |
| --- | --- | --- |
| `show running-config` | Entire Device Profile | Absolute visual layout of all configured commands currently active in RAM. |
| `show ip interface brief` | Quick Status Overview | Interface names, assigned IPv4 addresses, Layer 1 Status, and Layer 2 Protocol health. |
| `show run interface <id>` | Specific Component | Isolated configuration parameters applied strictly to the chosen interface slot. |
| `show interface <id>` | Advanced Physical Layer | Dynamic hardware MAC addresses, packet input/output counters, and interface error tracking. |
| `show version` | System Hardware/Software | Active IOS daemon release version, continuous hardware uptime, and installed system memory. |

## Comparison

### Auto-Negotiation vs. Manual Configuration

| Feature / Metric | Auto-Negotiation (`auto`) | Manual Configuration |
| --- | --- | --- |
| **Default Cisco State** | Yes, enabled across all ports out of the box. | No, requires explicit manual administrative intervention. |
| **Deployment Target** | End-user client machines (PCs, laptops, printers). | Critical network core infrastructure (Routers, Switches, Firewalls, Servers). |
| **Administration** | Negotiates settings without configuring each link manually. | Requires compatible settings at both ends. |
| **Mismatch risk** | Can mismatch with a manually configured peer in the demonstrated case. | A wrong setting can mismatch with the peer. |

## Commands (If Applicable)

### Cisco IOS

#### 1. Configuring Infrastructure Speed and Duplex Settings Manually

```text
Switch# configure terminal
Switch(config)# interface FastEthernet0/1
Switch(config-if)# description Connection Link to Core Router R1
Switch(config-if)# duplex full
Switch(config-if)# speed 100
Switch(config-if)# end
```

#### 2. Matching the Configuration on the Adjoining Router Gateway Port

```text
Router# configure terminal
Router(config)# interface FastEthernet0/0
Router(config-if)# speed 100
Router(config-if)# duplex full
Router(config-if)# end
```

#### 3. Utilizing Context-Filtered Inspection Utilities

```text
! View only the operational profile of the targeted interface
Switch# show run interface fastEthernet0/1

! Check the runtime traffic stats, hardware counters, and collision tracking
Switch# show interface fastEthernet0/1

! Perform a rapid status audit of all internal system interface interfaces
Switch# show ip interface brief
```

## Example

### Troubleshooting an Interface Status Disruption Audit

When auditing a router link that isn't passing traffic cleanly, running `show ip interface brief` maps out the operational state of the slots:

```text
Router# show ip interface brief
Interface                  IP-Address      OK? Method Status                Protocol
FastEthernet0/0            192.168.0.1     YES manual up                    up      
FastEthernet0/1            unassigned      YES unset  administratively down down    
```

*Diagnostic Breakdown:*

- `FastEthernet0/0` reports `up/up`: the physical interface and line protocol are up. This does not establish error-free forwarding; check counters and end-to-end traffic separately.
- `FastEthernet0/1` shows `administratively down`. This indicates a human error: the administrator forgot to issue the `no shutdown` command on this specific port block.

If an operational link has a duplex mismatch, inspecting the detailed hardware statistics reveals the performance drop:

```text
Router# show interface fastEthernet0/0
FastEthernet0/0 is up, line protocol is up 
  Hardware is GigaBus, address is 000c.294f.a11a
  571 packets input, 45680 bytes, 0 no buffer
  0 input errors, 0 CRC, 0 frame, 0 overruns, 0 aborted
  97 packets output, 7760 bytes, 0 underruns
  342 output errors, 128 collisions, 0 interface resets
```

*Analysis:* Output errors and collisions warrant checking speed and duplex at both ends. In the demonstrated lab, the configured mismatch explains the errors; these counters alone are not unique proof of that cause.

## Important Notes

- **Duplex Configuration:** Use compatible settings at both ends. On the demonstrated 10/100 link, forcing one end while leaving its peer on auto can cause a duplex mismatch even when the interface stays `up/up`. Follow the platform and link requirements.
- When reviewing paginated `show running-config` output, press **Spacebar** for the next page or **Ctrl+C** to stop.
- **Error Counters Investigation:** Healthy network links should maintain flat `0 input errors` and `0 output errors`. Incrementing error counters are prime symptoms of failing cabling lines or duplex mismatches.

## My Takeaways

- The lesson uses auto-negotiation for end-user ports and demonstrates matching manual settings on infrastructure links. This is the lab's configuration choice, not a universal stability guarantee.
- Hardcoding speed and duplex settings triggers a temporary port state reset, so these changes should ideally be scheduled during standard maintenance windows.
- `show ip interface brief` provides a high-level view of Layer 1 status and Layer 2 protocols, making it an essential first-step command for everyday monitoring.
- Use `show interface` to inspect error and collision counters when investigating a duplex mismatch.
- Use `show version` to check the running IOS version and device uptime.
