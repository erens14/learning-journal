# VLAN Trunk Ports

## Overview

An access port normally carries one data VLAN. An IEEE 802.1Q trunk carries traffic for multiple VLANs over a shared link while preserving their Layer 2 separation.

Trunking extends a VLAN between switches. It does not provide routing between different VLANs or IP subnets.

## Why Inter-Switch Links Need Trunks

If an inter-switch link is an access link in VLAN 1, it does not carry the Engineering and Sales VLANs configured on the host-facing ports. Moving that link into Engineering would carry Engineering alone, leaving Sales disconnected across the switches.

An 802.1Q trunk solves this by identifying which VLAN each tagged frame belongs to. The receiving switch keeps forwarding within that VLAN.

The lecture also mentions ISL, the older Cisco-proprietary Inter-Switch Link protocol. Its configurations use 802.1Q rather than ISL.

## Tagging and Frame Forwarding

Conceptual frame transformation:

```text
Ordinary host to access port:
[Ethernet header] [Payload]

Across a trunk, for a tagged VLAN:
[Ethernet header including 802.1Q VLAN tag] [Payload]

Access port to ordinary destination host:
[Ethernet header] [Payload]
```

The source host normally sends an untagged frame. The switch associates it with the access VLAN and adds the VLAN information when sending it across a tagged trunk. The final switch removes the tag when delivering the frame to an ordinary access-port host.

### Sales Broadcast Across Several Switches

The lecture describes this path. Addresses, VLAN numbers, and interface numbers are not specified for this particular diagram.

```text
Sales PC2 -- [SW1] == [SW2] == [SW3] == [SW4] == [SW5]
                        |        |        |
                 Engineering   Router   Sales PC1
                     PC      Sales port

-- Access connection
== Trunk connection
```

1. SW1 receives the Sales broadcast and sends it across its trunk as Sales VLAN traffic.
2. SW2 does not deliver it to the Engineering access port, but carries it onward through the trunk.
3. SW3 delivers an untagged copy to the router's Sales access interface and sends a tagged copy toward SW4.
4. SW4 delivers an untagged copy to Sales PC1 and carries the broadcast onward over its trunk toward SW5.

The switch does not strip the tag merely because it passes through an intermediate switch. Tagged and untagged treatment follows each outgoing port's configuration.

## Other Links That Carry Multiple VLANs

### Virtualization Hosts

A VMware or Hyper-V host can run virtual machines in different subnets and VLANs. Its physical switch connection can therefore need a trunk even though the connected device is a server.

```text
[Switch: Fa0/1 trunk] == [Virtualization host]
                            |           |
                      Engineering VM   Sales VM
```

The host's virtual networking handles the VLAN association. This is different from an ordinary desktop or single-VLAN server connected through an access port.

### IP Phone with a PC Behind It

```text
[Switch: Fa0/10] -- [IP phone] -- [PC]
       |
       +-- Data VLAN 10
       +-- Voice VLAN 20
```

The phone and PC share one physical switch connection, while voice and data use separate VLANs and subnets. The lecture separates them for traffic treatment, including voice prioritization, and to reduce unnecessary exposure between voice and data devices.

Its configuration is:

```text
Switch# configure terminal
Switch(config)# interface FastEthernet0/10
Switch(config-if)# description IP Phone
Switch(config-if)# switchport mode access
Switch(config-if)# switchport access vlan 10
Switch(config-if)# switchport voice vlan 20
Switch(config-if)# end
```

This is an **access port with a voice VLAN**, rather than an ordinary `switchport mode trunk` port. It carries untagged PC data and tagged voice traffic for the configured voice VLAN. The transcript's description of it as a trunk refers loosely to carrying multiple VLANs. [Cisco: configuring voice VLANs](https://www.cisco.com/c/en/us/td/docs/switches/lan/catalyst_microswitches/software/releases/15_2_8_e/configuration_guide/vlan/b_1528e_vlan_cms_cg/configuring_voice_vlans.html)

These voice/data VLAN numbers are a separate example from the Engineering/Sales assignment elsewhere in the notes.

## Configure a Static Trunk

The lecture first uses FastEthernet0/24:

```text
Switch# configure terminal
Switch(config)# interface FastEthernet0/24
Switch(config-if)# description Trunk to SW2
Switch(config-if)# switchport trunk encapsulation dot1q
Switch(config-if)# switchport mode trunk
Switch(config-if)# end
```

The encapsulation command applies to platforms that support selecting between encapsulations. On a switch that supports only 802.1Q, the command can be unavailable and should be omitted. On a platform with encapsulation set to automatic negotiation, select 802.1Q before forcing trunk mode if IOS requires it.

Configure both ends consistently. A change from access to trunk mode alters which VLAN traffic the link can carry and can interrupt connectivity.

## Native VLAN

The native VLAN classifies untagged traffic received on an 802.1Q trunk. Under the default tagging behavior discussed here, native-VLAN traffic also leaves the trunk untagged.

The default native VLAN is VLAN 1. The lecture replaces it with a dedicated unused VLAN, **199**, named `Native`, with no production end hosts assigned to it.

```text
Switch# configure terminal
Switch(config)# vlan 199
Switch(config-vlan)# name Native
Switch(config-vlan)# exit
Switch(config)# interface GigabitEthernet0/1
Switch(config-if)# description Trunk to SW2
Switch(config-if)# switchport mode trunk
Switch(config-if)# switchport trunk native vlan 199
Switch(config-if)# end
Switch# show interfaces GigabitEthernet0/1 switchport
```

On a platform requiring encapsulation selection, enter `switchport trunk encapsulation dot1q` before `switchport mode trunk`.

The native VLAN must match at both ends. A mismatch can cause incorrect VLAN handling and consistency problems; a physically up link does not prove the native VLANs match. [Cisco: VLAN trunk configuration](https://www.cisco.com/c/en/us/td/docs/switches/lan/c9000/lyr2-fwd/vlan/vlan-configuration-guide/configure-vlan-trunks.html)

Do not treat an `inactive` indication as proof of a healthy unused VLAN. Check that the referenced VLAN exists and is active; having no access ports is not itself a reason for a created VLAN to be inactive. [Cisco: inactive switch ports](https://www.cisco.com/c/en/us/support/docs/switches/catalyst-6500-series-switches/12027-53.html)

## Limit the Allowed VLANs

By default, the trunk allows all VLANs. The allowed list can restrict ordinary VLAN traffic to the groups that need the link.

In the lecture's separate filtering example, the lower switch has Engineering, Sales, and Accounts PCs, while the upper switch needs only Engineering and Accounts:

```text
Upper switch: Engineering + Accounts
                  ||
        Trunk allows VLANs 10,30
                  ||
Lower switch: Engineering + Sales + Accounts
```

```text
Switch(config)# interface GigabitEthernet0/1
Switch(config-if)# switchport trunk allowed vlan 10,30
```

Apply the intended list at both ends. This command sets the list to VLANs 10 and 30; it excludes Sales VLAN 20 and can interrupt any traffic that depended on an excluded VLAN. Do not copy this filtering example into the following lab, which needs both VLANs 10 and 20.

## Transcript Lab: Three-Switch Trunking

The supplied demo continues the access-port lab. The results below are transcript observations, not a new execution.

### Topology and VLANs

```text
ENG1 10.10.10.10 -- Fa0/1 [SW1]
ENG2 10.10.10.11 -- Fa0/2 [SW1]
SALES3 10.10.20.12 -- Fa0/3 [SW1]
                             |
                         Gi0/1
                             ||
                         Gi0/1
                           [SW2]
                         Gi0/2
                             ||
                         Gi0/2
                           [SW3]
                             |
       +---------------------+----------------------+
       |                     |                      |
     Fa0/1                 Fa0/2                  Fa0/3
     Sales                 Sales                   ENG3
                                                10.10.10.12

VLAN 10: Eng       VLAN 20: Sales       VLAN 199: Native
No router is present.
```

SW1 already has its PC access ports configured. SW2 and SW3 still need their production VLANs and port configuration.

### 1. Configure SW1

```text
SW1# show vlan brief
SW1# show interfaces GigabitEthernet0/1 switchport
SW1# configure terminal
SW1(config)# vlan 199
SW1(config-vlan)# name Native
SW1(config-vlan)# exit
SW1(config)# interface GigabitEthernet0/1
SW1(config-if)# switchport mode trunk
SW1(config-if)# switchport trunk native vlan 199
SW1(config-if)# end
```

SW1 is an 802.1Q-only switch in the demo, so it rejects the optional encapsulation-selection command. That does not prevent its supported trunk configuration.

### 2. Configure SW2

```text
SW2# configure terminal
SW2(config)# vlan 10
SW2(config-vlan)# name Eng
SW2(config-vlan)# exit
SW2(config)# vlan 20
SW2(config-vlan)# name Sales
SW2(config-vlan)# exit
SW2(config)# vlan 199
SW2(config-vlan)# name Native
SW2(config-vlan)# exit
SW2(config)# interface GigabitEthernet0/1
SW2(config-if)# description Trunk to SW1
SW2(config-if)# switchport trunk encapsulation dot1q
SW2(config-if)# switchport mode trunk
SW2(config-if)# switchport trunk native vlan 199
SW2(config-if)# exit
SW2(config)# interface GigabitEthernet0/2
SW2(config-if)# switchport trunk encapsulation dot1q
SW2(config-if)# switchport mode trunk
SW2(config-if)# switchport trunk native vlan 199
SW2(config-if)# end
```

SW2 supports encapsulation selection. The instructor first encounters a rejection when forcing trunk mode while encapsulation is automatic, then selects 802.1Q and retries successfully.

### 3. Resolve SW2's Administratively Down Port

The configured trunk toward SW1 initially remains operationally down:

```text
SW2# show interfaces GigabitEthernet0/1 switchport
SW2# show ip interface brief
```

The second command shows GigabitEthernet0/1 as administratively down. The demo enables it:

```text
SW2# configure terminal
SW2(config)# interface GigabitEthernet0/1
SW2(config-if)# no shutdown
SW2(config-if)# end
```

After the link becomes ready, the operational mode is trunk with native VLAN 199. Meanwhile, CDP reports a native VLAN mismatch on the other trunk toward the still-unconfigured SW3.

### 4. Configure SW3

```text
SW3# configure terminal
SW3(config)# vlan 10
SW3(config-vlan)# name Eng
SW3(config-vlan)# exit
SW3(config)# vlan 20
SW3(config-vlan)# name Sales
SW3(config-vlan)# exit
SW3(config)# vlan 199
SW3(config-vlan)# name Native
SW3(config-vlan)# exit
SW3(config)# interface GigabitEthernet0/2
SW3(config-if)# switchport mode trunk
SW3(config-if)# switchport trunk native vlan 199
SW3(config-if)# exit
SW3(config)# interface range FastEthernet0/1 - 2
SW3(config-if-range)# switchport mode access
SW3(config-if-range)# switchport access vlan 20
SW3(config-if-range)# exit
SW3(config)# interface FastEthernet0/3
SW3(config-if)# switchport mode access
SW3(config-if)# switchport access vlan 10
SW3(config-if)# end
```

SW3 also supports only 802.1Q in the demo. Once its native VLAN matches, the reported port-consistency problem is resolved.

### 5. Verify the Switches and Hosts

```text
SW3# show ip interface brief
SW3# show interfaces GigabitEthernet0/2 switchport
SW3# show vlan brief
```

Check link state, operational trunk mode, native VLAN, VLAN existence, and access-port membership.

| Test in the demonstration | Reported result | What it checks |
| --- | --- | --- |
| ENG1 to 10.10.10.11, ENG2 | Succeeds. | Local switching on SW1. |
| ENG1 to 10.10.10.12, ENG3 | Succeeds. | VLAN 10 across both trunks. |
| SALES1 on SW3 to 10.10.20.12, SALES3 on SW1 | Succeeds. | VLAN 20 across both trunks. |
| ENG1 to 10.10.20.11, a Sales PC | Fails. | Different subnets have no routing path. |

Successful same-VLAN communication across the campus does not imply that inter-VLAN routing exists.

## My Takeaways

- Follow VLAN membership across every switch and trunk in the path.
- Verify operational trunk state as well as the configured administrative mode.
- A native VLAN and an allowed-VLAN list solve different problems and need separate checks.
- A phone's voice-VLAN access port is a distinct configuration from a general-purpose trunk.
- Working trunks extend Layer 2 connectivity; they do not replace a router between subnets.
