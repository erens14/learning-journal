# Why We Have VLANs

## Overview

A Virtual Local Area Network (VLAN) divides a switched LAN into separate Layer 2 broadcast domains. This limits where broadcast traffic travels and allows logical groups to share physical switches while remaining separated at Layer 2.

Different IP subnets alone do not divide a shared Layer 2 broadcast domain. VLANs provide that separation on the switches.

## Routers and Switches Have Different Boundaries

| Behavior | Router | Layer 2 switch |
| --- | --- | --- |
| Main forwarding decision | Destination IP address. | Destination MAC address within a VLAN. |
| Communication between IP subnets | Routes traffic between them. | Does not provide routing in the lecture's examples. |
| Broadcast handling | Does not forward local broadcasts between subnets by default. | Floods broadcasts within the incoming frame's VLAN, except back through its ingress port. |
| Security role discussed | Apply rules between IP subnets. | Separate Layer 2 groups using VLAN membership. |

Before VLAN separation, the lecture assumes interconnected switch ports belong to the same default VLAN. That produces one shared broadcast domain, even if hosts use different IP subnets.

## IP Subnets and Known Unicast Traffic

The lecture uses these department networks:

| Department | IP subnet |
| --- | --- |
| Engineering | 10.10.10.0/24 |
| Sales | 10.10.20.0/24 |

It also gives Engineering and Accounts as an example of groups whose traffic a router or firewall could restrict. Department labels illustrate the policy requirement; the switching example below uses Sales and Engineering.

### Within One Subnet

Sales PC2, `10.10.20.10`, sends to Sales PC1, `10.10.20.11`.

```text
Sales PC2                         Sales PC1
10.10.20.10 -- [Switch] -------- 10.10.20.11
```

If the switch has learned Sales PC1's MAC address, it sends the frame only through the appropriate port. The destination is local to the sender's subnet, so a router is unnecessary.

### Between Subnets

When Sales PC2 sends to Engineering, it uses the destination host's IP address but its default gateway's MAC address for the first frame.

```text
Sales PC2
    |
    | Frame addressed to the Sales default gateway's MAC
    v
 [Switch] -- [Router: Sales interface]
    ^                    |
    |             Route to Engineering
    |                    |
 [Switch] -- [Router: Engineering interface]
    |
    v
Engineering PC
```

The two switch labels represent the same physical switch in this conceptual packet path. The router uses separate interfaces for the two subnets in the lecture's example.

The switch forwards based on the frame's destination MAC, rather than selecting a router because it inspected the destination IP subnet. Router or firewall rules can then control the routed traffic.

## The Problem with a Shared Broadcast Domain

A broadcast such as an ARP request does not follow the same narrow path as a known unicast frame. The switch floods it through the other ports in that VLAN.

Without department VLANs, a Sales broadcast also reaches the Engineering ports. With another switch attached, the flood can extend to Accounts hosts elsewhere in the building:

```text
Sales PC -- [Switch 1] -- [Switch 2] -- Accounts PCs
                 |
           Engineering PCs

All shown ports share one Layer 2 broadcast domain.
A Sales broadcast reaches the other groups too.
```

This has two consequences:

- Hosts and links carry broadcasts that their department does not need.
- Layer 3 rules on a router do not isolate traffic that stays inside the shared Layer 2 domain.

This does not mean that a broadcast automatically bypasses every routed security rule. It means Layer 3 policy alone does not separate hosts that still share a Layer 2 segment.

## VLANs Separate the Broadcast Domains

The lecture creates an Engineering VLAN and a Sales VLAN on the same switch:

```text
                  One physical switch
        +---------------------------------------+
        | Engineering VLAN                      |
        | Engineering PCs + Engineering gateway |
        |                                       |
        | Sales VLAN                            |
        | Sales PCs + Sales gateway             |
        +---------------------------------------+

The two gateway interfaces connect to the router.
Layer 2 switching stays inside each VLAN.
```

There is typically one IP subnet per VLAN. Put hosts and their gateway interface in the VLAN associated with that subnet.

### Effect on Traffic

| Traffic | Result after VLAN separation |
| --- | --- |
| Sales PC2 to Sales PC1 | Switched within the Sales VLAN. |
| Sales PC2 to Engineering | Sent to the Sales gateway, routed, then delivered through the Engineering VLAN. |
| Sales broadcast | Flooded only to other Sales VLAN ports, including the Sales gateway interface. |

The known-unicast paths remain similar. The major change is that broadcasts no longer spread across unrelated department ports.

VLANs provide Layer 2 separation; routing and its associated policy determine whether different VLAN subnets may communicate.

## My Takeaways

- Different IP addresses or subnets do not automatically create separate Layer 2 domains.
- A switch's broadcast scope follows VLAN membership.
- Same-subnet traffic can stay on the switch, while traffic to another subnet needs a Layer 3 path.
- Department separation requires consistent VLAN membership for hosts and their gateway interfaces.
- VLAN boundaries and routed security rules address different parts of the traffic path.
