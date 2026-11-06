# DTP: Dynamic Trunking Protocol

## Overview

Dynamic Trunking Protocol (DTP) is Cisco's proprietary mechanism for negotiating whether a link between switch ports operates as a trunk.

The lecture recommends explicitly configuring access or trunk mode instead of relying on negotiation. DTP controls trunk negotiation; it does not create the VLAN database or configure host VLAN membership.

## Switchport Modes

| Configuration | Behavior |
| --- | --- |
| `switchport mode access` | Operate as an access port. |
| `switchport mode trunk` | Operate as a static trunk. |
| `switchport mode dynamic auto` | Become a trunk if the peer is trunk or dynamic desirable. |
| `switchport mode dynamic desirable` | Actively negotiate a trunk with a peer in trunk, desirable, or auto mode. |
| `switchport nonegotiate` | Disable DTP frame generation; this is separate from selecting access or trunk mode. |

### Dynamic Mode Combinations

| Local mode | Peer mode | Expected operational link |
| --- | --- | --- |
| Dynamic auto | Dynamic auto | Access; neither side actively requests trunking. |
| Dynamic auto | Dynamic desirable | Trunk. |
| Dynamic desirable | Dynamic desirable | Trunk. |
| Dynamic auto | Trunk with DTP negotiation | Trunk. |
| Dynamic desirable | Trunk with DTP negotiation | Trunk. |

The lab switches default to dynamic auto. The lecture contrasts this with older switches that defaulted to dynamic desirable. Defaults depend on the platform, so inspect the actual administrative mode rather than relying only on device age.

## Transcript Demo: Auto and Desirable

The demo uses the same three-switch chain as the preceding topic:

```text
[SW1: Gi0/1] == [Gi0/1: SW2: Gi0/2] == [Gi0/2: SW3]

Initially, both ends of each link use their default dynamic auto mode.
```

These observations come from the transcript; the lab was not executed while writing these notes.

### 1. Inspect the Default State

```text
SW1# show interfaces GigabitEthernet0/1 switchport
SW2# show interfaces GigabitEthernet0/1 switchport
```

Both ports show dynamic auto administratively and access operationally. Connecting two auto ports does not automatically produce a trunk. The SW2-SW3 link starts in the same condition.

### 2. Change SW2 to Desirable

```text
SW2# configure terminal
SW2(config)# interface GigabitEthernet0/1
SW2(config-if)# switchport mode dynamic desirable
SW2(config-if)# end
SW2# show interfaces GigabitEthernet0/1 switchport
```

SW2 becomes dynamic desirable administratively and trunk operationally. SW1 remains dynamic auto but also becomes operationally trunk because its peer actively negotiates.

```text
SW1# show interfaces GigabitEthernet0/1 switchport
```

The demonstration reports a temporary interface reset during the transition. Changing link mode can interrupt traffic while the new operating state is established.

## Explicit Trunk Configuration

The lecture's preferred approach creates a dedicated native VLAN and manually configures the inter-switch ports:

```text
Switch# configure terminal
Switch(config)# vlan 199
Switch(config-vlan)# name Native
Switch(config-vlan)# exit
Switch(config)# interface GigabitEthernet0/1
Switch(config-if)# switchport mode trunk
Switch(config-if)# switchport trunk native vlan 199
Switch(config-if)# end
```

On a platform supporting encapsulation selection, use `switchport trunk encapsulation dot1q` before setting trunk mode. On an 802.1Q-only platform, omit that unsupported command.

For a static trunk where DTP is unnecessary, the lecture also introduces the command:

```text
Switch(config-if)# switchport nonegotiate
```

Static trunk mode alone does not necessarily stop DTP frames. Configure the peer statically as well before disabling negotiation, rather than leaving it dependent on dynamic auto. [Cisco: static trunks and DTP](https://www.cisco.com/c/en/us/td/docs/switches/lan/c9000/lyr2-fwd/vlan/vlan-configuration-guide/configure-vlan-trunks.html)

Ordinary host-facing ports should use explicit access mode. Inter-switch trunks should have matching native VLANs and the intended VLAN carriage configured at both ends.

## My Takeaways

- Administrative mode describes the configured behavior; operational mode shows whether a trunk actually formed.
- Auto on both ends leaves the link as access, while desirable can negotiate with auto.
- Explicit trunk mode and disabling DTP are separate decisions.
- Configure both endpoints deliberately so the link does not depend on an unexpected default.
