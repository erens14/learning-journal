# OSI Layer 3 — Router Basics & Comparison with Switches

## Table of Contents

- [OSI Layer 3 — Router Basics \& Comparison with Switches](#osi-layer-3--router-basics--comparison-with-switches)
  - [Table of Contents](#table-of-contents)
  - [Overview](#overview)
  - [What Does a Router Do?](#what-does-a-router-do)
  - [Router vs Switch](#router-vs-switch)
  - [Router Operation](#router-operation)
  - [Why Routers Are Needed](#why-routers-are-needed)
  - [OSI Layers Used by a Router](#osi-layers-used-by-a-router)
  - [Router Interfaces](#router-interfaces)
  - [Router vs Switch Ports](#router-vs-switch-ports)
  - [Broadcast Handling](#broadcast-handling)
    - [Switch](#switch)
    - [Router](#router)
  - [Layer 3 Switch](#layer-3-switch)
  - [Why Use a Layer 3 Switch?](#why-use-a-layer-3-switch)
  - [When Is a Traditional Router Still Needed?](#when-is-a-traditional-router-still-needed)
  - [Router vs Layer 3 Switch](#router-vs-layer-3-switch)
  - [My Takeaways](#my-takeaways)

## Overview

A **router** is a **Layer 3 (Network Layer)** device responsible for forwarding packets between **different IP networks (subnets)**.

Unlike a switch, which only forwards frames within the same Local Area Network (LAN), a router examines **IP addresses** to determine the best path for packets traveling between networks.

Although routers primarily operate at **Layer 3**, they also interact with Layers **1 and 2** because they use physical interfaces and Ethernet frames. Many enterprise routers can also inspect higher-layer information (up to Layer 7) for advanced services such as firewalls and Quality of Service (QoS).

## What Does a Router Do?

The primary function of a router is to:

- Connect different IP networks
- Route packets between subnets
- Determine the best path for network traffic
- Separate broadcast domains

Example:

```text
Network A                     Network B
10.10.10.0/24              10.10.11.0/24

PC ─────┐                ┌───── PC
        │                │
        └──── Router ────┘
```

Without a router, devices in different IP subnets cannot communicate.

## Router vs Switch

| Feature | Router | Switch |
| ---------- | -------- | --------- |
| Primary OSI Layer | Layer 3 | Layer 2 |
| Main Function | Routes packets between networks | Switches frames within the same LAN |
| Address Used | IP Address | MAC Address |
| Broadcast Forwarding | Does **not** forward broadcasts by default | Forwards broadcast frames |
| Interface Types | Ethernet, Serial, DSL, ISDN, ADSL, etc. | Primarily Ethernet |
| Number of Ports | Usually fewer | Usually many more |
| Typical Deployment | Connecting different networks or WANs | Connecting hosts within a LAN |

## Router Operation

A router examines the **destination IP address** inside an incoming packet.

It then:

1. Determines which network the destination belongs to.
2. Looks up the appropriate route in its routing table.
3. Forwards the packet through the correct outgoing interface.

```text
Incoming Packet
       │
       ▼
Read Destination IP
       │
       ▼
Lookup Routing Table
       │
       ▼
Select Best Route
       │
       ▼
Forward Packet
```

## Why Routers Are Needed

Consider a LAN where every device belongs to the same subnet.

```text
10.10.10.0/24

PC1 ── Switch ── PC2
          │
         PC3
```

All devices can communicate because they are in the same IP network.

---
Now suppose one device is moved to another subnet.

```text
10.10.10.0/24

PC1 ── Switch ── PC2

10.10.11.0/24

PC3
```

Although the devices remain physically connected, they are now in **different Layer 3 networks**.

A Layer 2 switch cannot route between subnets.

Communication will fail.

---

Adding a router solves the problem.

```text
10.10.10.0/24

PC1 ── Switch
            │
         Router
            │
PC3 ── Switch

10.10.11.0/24
```

The router knows both networks and forwards packets between them.

## OSI Layers Used by a Router

Although routers are commonly called **Layer 3 devices**, they interact with multiple OSI layers.

| OSI Layer | Router Function |
| ----------- | ----------------- |
| Layer 1 | Uses physical interfaces and cables |
| Layer 2 | Processes Ethernet frames and MAC addresses |
| Layer 3 | Makes routing decisions using IP addresses |
| Layer 4–7 | May inspect traffic for advanced features (ACLs, QoS, Firewall, NAT, etc.) |

For routing purposes, routers are classified as **Layer 3 devices**.

## Router Interfaces

Unlike switches, routers support many interface types.

Common examples:

- Ethernet
- Serial
- ISDN
- ADSL
- DSL
- Fiber (depending on modules)

Example Cisco router:

```text
+--------------------------------+
| Console | AUX | Fa0/0 | Fa0/1 |
|                                |
| Modular Interface Slots        |
+--------------------------------+
```

Many enterprise routers include expansion slots for installing additional interface modules.

## Router vs Switch Ports

Switches are designed to connect many end devices.

Typical enterprise switch:

- 24 ports
- 48 ports
- Mostly Ethernet

Routers typically have:

- 2–8 built-in interfaces
- Expansion slots for additional modules
- Fewer total ports

## Broadcast Handling

### Switch

Broadcast frames are forwarded to every device in the broadcast domain.

```text
Broadcast
     │
     ▼
All Switch Ports
```

### Router

Routers do **not forward broadcast traffic by default**.

```text
Broadcast
     │
     ▼
Router
     │
Dropped
```

This behavior helps reduce unnecessary traffic between different networks.

## Layer 3 Switch

Modern networks often use **Layer 3 switches**.

A Layer 3 switch combines the capabilities of:

- Layer 2 switching
- Layer 3 routing

Example:

```text
PCs
 │
 ├──── Layer 3 Switch ──── PCs
 │
10.10.10.0           10.10.11.0
```

The Layer 3 switch can route traffic between VLANs or IP subnets without requiring a separate router.

## Why Use a Layer 3 Switch?

Advantages:

- Faster routing within the LAN
- High port density
- Ethernet interfaces only
- Reduced latency
- Simplified campus network design

Most enterprise campus networks today perform **inter-VLAN routing** using Layer 3 switches.

## When Is a Traditional Router Still Needed?

Even if a Layer 3 switch performs routing inside the LAN, a traditional router is still required when:

- Connecting to an ISP
- Using WAN technologies
- Using Serial interfaces
- Using DSL/ADSL connections
- Connecting remote branch offices

Example:

```text
LAN
 │
Layer 3 Switch
 │
Router
 │
Internet / WAN
```

The Layer 3 switch handles internal routing, while the router provides connectivity to external networks.

## Router vs Layer 3 Switch

| Feature | Router | Layer 3 Switch |
| ---------- | -------- | ---------------- |
| Routes Between Subnets | ✅ | ✅ |
| Ethernet Switching | Limited | Excellent |
| WAN Interfaces | ✅ | Usually No |
| Port Density | Low | High |
| LAN Routing Performance | Good | Excellent |
| Typical Use | WAN Edge | Campus Core / Distribution |

## My Takeaways

- A **router** is primarily a **Layer 3 device** that routes packets between different IP networks.
- Routers make forwarding decisions based on **destination IP addresses**, while switches use **MAC addresses**.
- Devices in different IP subnets cannot communicate without a Layer 3 device.
- Routers support multiple interface types, including Ethernet, Serial, DSL, and ADSL, whereas switches primarily use Ethernet.
- Routers do **not forward broadcast traffic by default**, helping separate broadcast domains.
- A **Layer 3 switch** combines switching and routing, making it ideal for routing traffic between VLANs or subnets within a campus LAN.
- Modern enterprise networks commonly use Layer 3 switches for internal routing and traditional routers for WAN or Internet connectivity.
