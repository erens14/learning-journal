# VLAN Access Ports

## Overview

An access port places an ordinary end host in one data VLAN. The switch assigns the VLAN membership; the host normally sends and receives untagged Ethernet frames without needing to understand VLANs.

Hosts in the same IP subnet should be placed in the same VLAN in these examples. A matching IP subnet does not restore connectivity if their switch ports belong to different VLANs.

## Access-Port Membership

The lecture separates Engineering and Sales:

| Group | VLAN | Name |
| --- | --- | --- |
| Engineering | 10 | Eng |
| Sales | 20 | Sales |

The router interface serving each subnet also belongs to that subnet's VLAN. Inter-VLAN communication requires routing; the Layer 2 switch does not directly bridge the two VLANs.

If Sales PC1 at `10.10.20.11` is accidentally placed in the Engineering VLAN, other Sales hosts cannot reach it through ordinary same-subnet switching. The problem is its VLAN assignment, even though its IP address still looks correct for Sales.

By default, the ordinary access-port membership shown in the lecture is VLAN 1. Leaving all ports there preserves one shared broadcast domain.

## Configuration Example

The theory example uses the following switch ports. This is separate from the later three-PC lab.

| Ports | Connected devices | VLAN |
| --- | --- | --- |
| FastEthernet0/1 | Engineering router interface | 10 |
| FastEthernet0/3 through 0/5 | Engineering PCs | 10 |
| FastEthernet0/2 | Sales router interface | 20 |
| FastEthernet0/6 through 0/7 | Sales PCs | 20 |

The transcript initially includes FastEthernet0/6 in Engineering, but its final configuration and verification place that port in Sales. The table follows the completed configuration.

### Create the VLANs

```text
Switch# configure terminal
Switch(config)# vlan 10
Switch(config-vlan)# name Eng
Switch(config-vlan)# exit
Switch(config)# vlan 20
Switch(config-vlan)# name Sales
Switch(config-vlan)# exit
```

The VLAN number defines the VLAN. A descriptive name makes its purpose easier to recognize.

### Assign the Ports

```text
Switch(config)# interface FastEthernet0/1
Switch(config-if)# switchport mode access
Switch(config-if)# switchport access vlan 10
Switch(config-if)# exit
Switch(config)# interface range FastEthernet0/3 - 5
Switch(config-if-range)# switchport mode access
Switch(config-if-range)# switchport access vlan 10
Switch(config-if-range)# exit
Switch(config)# interface FastEthernet0/2
Switch(config-if)# switchport mode access
Switch(config-if)# switchport access vlan 20
Switch(config-if)# exit
Switch(config)# interface range FastEthernet0/6 - 7
Switch(config-if-range)# switchport mode access
Switch(config-if-range)# switchport access vlan 20
Switch(config-if-range)# end
```

`switchport mode access` fixes the port's role as an access port. `switchport access vlan` selects its data VLAN. Changing that membership can interrupt the attached host's connectivity.

The range syntax above applies the same commands to several ports. It preserves the interface-range form used in the lecture rather than repeating the commands on each interface.

### Verify Membership

```text
Switch# show vlan brief
Switch# show interfaces FastEthernet0/1 switchport
```

`show vlan brief` lists the VLANs and their access-port assignments. The interface-specific command shows the port's administrative and operational modes and its access VLAN.

In this example, VLAN 10 contains ports 0/1 and 0/3-5; VLAN 20 contains ports 0/2 and 0/6-7. Untouched access ports remain in VLAN 1.

## Transcript Lab: Separate Engineering and Sales

The supplied demonstration uses one switch and three PCs:

```text
ENG1: 10.10.10.10 -- Fa0/1 [SW1]
ENG2: 10.10.10.11 -- Fa0/2 [SW1]
SALES3: 10.10.20.12 -- Fa0/3 [SW1]

All three connections terminate on the same SW1.
Engineering subnet: 10.10.10.0/24
Sales subnet:       10.10.20.0/24
No router is present.
```

The following outcomes come from the transcript, not a newly executed lab.

### 1. Observe the Default VLAN

```text
SW1# show interfaces FastEthernet0/1 switchport
SW1# show vlan brief
```

The PC ports initially belong to VLAN 1.

From ENG1:

```text
ping 10.10.10.11
ping 10.10.20.12
ping 10.10.10.255
```

| Test | Result reported in the demo | Explanation |
| --- | --- | --- |
| ENG1 to ENG2 | Succeeds. | Same subnet and VLAN. |
| ENG1 to SALES3 | Fails. | Different subnets with no router. |
| Subnet broadcast | ENG2 replies; the frame also reaches SALES3's port. | All three ports share the Layer 2 broadcast domain. |

Receiving a broadcast frame does not require SALES3 to answer it. Broadcast ping responses also depend on the receiving system; the reply above is the demonstration's observation.

### 2. Move Only ENG1 into VLAN 10

```text
SW1# configure terminal
SW1(config)# vlan 10
SW1(config-vlan)# name Eng
SW1(config-vlan)# exit
SW1(config)# vlan 20
SW1(config-vlan)# name Sales
SW1(config-vlan)# exit
SW1(config)# interface FastEthernet0/1
SW1(config-if)# switchport mode access
SW1(config-if)# switchport access vlan 10
SW1(config-if)# end
```

ENG1 is now in VLAN 10, while ENG2 and SALES3 remain in VLAN 1. ENG1 can no longer ping ENG2, despite their matching IP subnet. An ENG1 broadcast has no other host to reach in VLAN 10.

The transcript's `10.10.10.10.255` is a typo. The /24 broadcast address used here is `10.10.10.255`.

### 3. Complete the Port Assignments

```text
SW1# configure terminal
SW1(config)# interface FastEthernet0/2
SW1(config-if)# switchport mode access
SW1(config-if)# switchport access vlan 10
SW1(config-if)# exit
SW1(config)# interface FastEthernet0/3
SW1(config-if)# switchport mode access
SW1(config-if)# switchport access vlan 20
SW1(config-if)# end
SW1# show vlan brief
```

Final membership is VLAN 10 on FastEthernet0/1-2 and VLAN 20 on FastEthernet0/3. ENG1 and ENG2 regain same-VLAN connectivity. Engineering and Sales broadcasts stay separated.

### Packet Tracer Interface Flap

The demonstration temporarily uses `shutdown` followed by `no shutdown` on the Engineering ports after a ping does not immediately succeed. The instructor identifies this as a Packet Tracer workaround, not a normal requirement when changing an access VLAN.

These commands interrupt the link. Allow the interface to become ready and check the VLAN configuration before considering a flap.

## My Takeaways

- Creating a VLAN and assigning a port to it are separate steps.
- Compare both the IP subnet and the access VLAN when a same-subnet ping fails.
- Keep the router-facing access port in the VLAN it serves.
- A broadcast can reach a host's port without producing a reply from that host.
- Distinguish the theory port map from the lab port map before copying configuration.
