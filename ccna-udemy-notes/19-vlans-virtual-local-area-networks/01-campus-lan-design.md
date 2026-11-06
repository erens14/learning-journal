# Campus LAN Design: Core, Distribution, and Access Layers

## Overview

A campus LAN connects devices within a building or nearby buildings on the same local campus. Its design should support growth, performance, security, and resilience. The hierarchical model separates responsibilities into access, distribution, and core layers.

This topic concerns local connectivity, rather than WAN connections between distant sites.

## The Three Layers

| Layer | Main responsibility | Design priorities |
| --- | --- | --- |
| Access | Connect end hosts to the network. | Many ports at an affordable cost, with client access security. |
| Distribution | Aggregate access switches. | Redundant uplinks, scalability, and policy enforcement. |
| Core | Connect distribution blocks across the campus. | Fast forwarding and resilient connectivity. |

### Access Layer

Desktop computers, servers, and IP phones enter the network through the access layer. Access switches provide a high port count because many hosts need connections.

- A typical desktop has one NIC and connects to one switch, or connects wirelessly through an access point.
- A server can have two NICs connected to redundant access switches.
- Client access controls, such as port security, belong near the hosts at this layer.

The lecture places multiple access switches in both the Main Building and Building 1. Each switch serves its local hosts, such as devices on a particular floor.

### Distribution Layer

Access switches uplink to distribution switches, rather than normally connecting directly to other access switches. Distribution provides an aggregation point so the campus can grow without connecting every access switch to every other switch.

Distribution switches are typically deployed in redundant pairs. Each access switch connects to both members of the pair, allowing an alternative path if one distribution switch fails.

End hosts do not normally connect directly to distribution switches. The lecture places policies such as Quality of Service (QoS) at this layer.

### Core Layer

Distribution switches uplink to the core. The core carries traffic between different parts of the campus, including buildings.

In the lecture example, the core pair is in the Main Building, while both buildings have their own access and distribution layers. Distribution switches connect to both core switches for redundancy.

The core prioritizes speed and resilience. Keep unnecessary software processing and policy complexity out of this transit layer; the lecture assigns policy work to distribution instead.

## Campus Topology

Conceptual reconstruction of the two-building example. Individual switch names and interface numbers were not supplied.

```text
                    MAIN BUILDING
                 [Core A]   [Core B]
                      \       /
                       \     /
       Both core switches connect to each distribution switch
                    /                   \
                   /                     \
     MAIN BUILDING                         BUILDING 1
 [Distribution A / B]                  [Distribution A / B]
          |                                     |
 Each access switch uplinks             Each access switch uplinks
 to both distribution switches          to both distribution switches
          |                                     |
   [Access switches]                      [Access switches]
          |                                     |
   PCs, servers, phones                    PCs, servers, phones
```

The paired devices and dual uplinks reduce single points of failure. They do not give a single-NIC desktop a second physical connection; host connectivity still depends on its own attachment.

## Collapsed Distribution and Core

A smaller campus may not need three separate physical layers. A collapsed design combines distribution and core functions on the same hardware.

```text
       [Combined distribution/core A]
       [Combined distribution/core B]
                       |
        Access switches connect to both
                       |
                [Access switches]
                       |
                   End hosts
```

The design still separates host access from aggregation and campus transit responsibilities, but avoids maintaining separate distribution and core devices when their scalability is unnecessary.

## My Takeaways

- Start at the host connection, then identify where access switches aggregate and where campus traffic crosses between buildings.
- Redundant distribution and core pairs need corresponding uplinks to provide alternative paths.
- A collapsed core combines functions; it does not remove the need to plan aggregation and resilience.
- Match the number of physical layers to campus size and growth requirements.
