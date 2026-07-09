# Hubs vs Switches

## Table of Contents

- [Hubs vs Switches](#hubs-vs-switches)
  - [Table of Contents](#table-of-contents)
  - [Overview](#overview)
  - [Hub vs Switch](#hub-vs-switch)
    - [Hub](#hub)
    - [Switch](#switch)
  - [Half-Duplex vs Full-Duplex](#half-duplex-vs-full-duplex)
    - [Half-Duplex](#half-duplex)
    - [Full-Duplex](#full-duplex)
  - [Collision Domain](#collision-domain)
    - [Hub](#hub-1)
    - [Switch](#switch-1)
  - [CSMA/CD](#csmacd)
  - [MAC Address Awareness](#mac-address-awareness)
    - [Hub](#hub-2)
    - [Switch](#switch-2)
  - [Unknown Unicast vs Broadcast](#unknown-unicast-vs-broadcast)
    - [Unknown Unicast](#unknown-unicast)
    - [Broadcast Frame](#broadcast-frame)
  - [Hub vs Switch Comparison](#hub-vs-switch-comparison)
  - [Why Switches Replaced Hubs](#why-switches-replaced-hubs)
  - [My Takeaways](#my-takeaways)

## Overview

Both **hubs** and **switches** are networking devices used to connect end devices such as PCs, servers, and printers within a **Local Area Network (LAN)**.

Although they serve a similar purpose, switches are significantly more efficient, intelligent, and secure than hubs. Today, **switches have completely replaced hubs** in modern networks.

## Hub vs Switch

### Hub

A **hub** is a **Layer 1 (Physical Layer)** device.

It does **not understand MAC addresses** and simply repeats incoming electrical signals to every connected device.

Characteristics:

- Operates at **Layer 1**
- Half-duplex only
- All devices share one collision domain
- No MAC address learning
- Floods traffic to every port
- Uses **CSMA/CD** to detect and recover from collisions

```text
        +------+
PC1 ----|      |
PC2 ----| Hub  |---- PC3
PC4 ----|      |
        +------+

Incoming Frame
      │
      ▼
Flooded to ALL ports
```

### Switch

A **switch** is primarily a **Layer 2 (Data Link Layer)** device.

Unlike a hub, a switch examines the **MAC address** inside the Ethernet frame and forwards traffic only to the correct destination port.

Characteristics:

- Operates at **Layer 2**
- Normally operates in **Full-Duplex**
- Dedicated collision domain per port
- Learns MAC addresses automatically
- Forwards traffic only where needed
- Better performance and security

```text
        +---------+
PC1 ----|         |
PC2 ----| Switch  |---- PC3
PC4 ----|         |
        +---------+

Incoming Frame
      │
      ▼
Forwarded only to destination port
```

## Half-Duplex vs Full-Duplex

### Half-Duplex

Devices can either:

- Send data
- Receive data

But **cannot perform both simultaneously**.

Used by:

- Hubs

```text
Host A
   │ Send
   ▼

Host B

OR

Host A
   ▲ Receive
   │

Host B
```

### Full-Duplex

Devices can:

- Send data
- Receive data

At the same time.

Used by:

- Modern Ethernet switches

```text
Host A
 ⇄
Host B

Send and Receive simultaneously
```

Benefits:

- Higher throughput
- No collisions
- Better performance

## Collision Domain

A **collision domain** is a network segment where multiple devices compete to transmit data.

If two devices transmit simultaneously, a **collision** occurs.

### Hub

```text
PC1
   \
PC2 ---- Hub ---- PC3
   /
PC4
```

All devices belong to **one collision domain**.

Only one device can successfully transmit at a time.

### Switch

```text
PC1 ---- Switch
PC2 ---- Switch
PC3 ---- Switch
PC4 ---- Switch
```

Each switch port forms its **own collision domain**.

Result:

- No shared collisions
- Higher network efficiency

## CSMA/CD

**CSMA/CD** stands for:

```text
Carrier Sense Multiple Access with Collision Detection
```

Used only on:

- Half-duplex Ethernet
- Hubs

Process:

1. Listen before transmitting.
2. If the medium is busy, wait.
3. Transmit when idle.
4. Detect collisions.
5. Stop transmitting.
6. Wait a random amount of time.
7. Retransmit.

Modern switched Ethernet running in **full-duplex** does **not require CSMA/CD** because collisions do not occur.

## MAC Address Awareness

### Hub

A hub is **not MAC-aware**.

Whenever a frame arrives:

```text
Receive Frame
      │
      ▼
Send to EVERY port
```

Every connected device receives the frame and checks whether it is intended for itself.

### Switch

A switch is **MAC-aware**.

When a frame arrives:

1. Read the **Source MAC Address**.
2. Learn which port that MAC belongs to.
3. Store the mapping in the **MAC Address Table**.

Example:

| MAC Address | Switch Port |
| ------------- | ------------- |
| AA:AA:AA:AA:AA:01 | Fa0/1 |
| BB:BB:BB:BB:BB:02 | Fa0/2 |
| CC:CC:CC:CC:CC:03 | Fa0/3 |

When another frame arrives:

- If the destination MAC exists in the table → Forward only to the correct port.
- If the destination MAC is unknown → Flood all ports except the incoming port.
- If the destination is a broadcast address → Flood all ports except the incoming port.

## Unknown Unicast vs Broadcast

### Unknown Unicast

The switch has **not yet learned** the destination MAC address.

Action:

```text
Flood to every port
(except incoming port)
```

Once the destination replies, the switch learns its MAC address.

### Broadcast Frame

Destination MAC:

```text
FF:FF:FF:FF:FF:FF
```

Action:

```text
Flood to every port
(except incoming port)
```

All devices receive and process the broadcast frame.

## Hub vs Switch Comparison

| Feature | Hub | Switch |
| ---------- | ----- | -------- |
| OSI Layer | Layer 1 | Layer 2 |
| MAC Address Awareness | No | Yes |
| Duplex Mode | Half-Duplex | Full-Duplex (normally) |
| Collision Domain | Shared | One per Port |
| Collision Detection | CSMA/CD Required | Not Required |
| Frame Forwarding | Flood All Ports | Forward to Destination Port |
| Performance | Low | High |
| Security | Lower | Better |
| Modern Usage | Obsolete | Standard |

## Why Switches Replaced Hubs

Switches became the standard because they provide:

- Higher bandwidth
- Dedicated collision domains
- Full-duplex communication
- Intelligent frame forwarding
- Better security
- Lower cost over time

Today, **hubs are considered obsolete** and are rarely found in production networks.

## My Takeaways

- A **hub** is a Layer 1 device that blindly repeats signals to every connected device.
- A **switch** is a Layer 2 device that learns MAC addresses and forwards frames intelligently.
- Hubs operate only in **half-duplex**, while switches normally operate in **full-duplex**.
- Hubs create **one shared collision domain**, whereas switches provide **one collision domain per port**.
- **CSMA/CD** is only required for half-duplex Ethernet because collisions can occur.
- Switches maintain a **MAC Address Table** to determine the correct forwarding port.
- Unknown unicast and broadcast frames are flooded, but known unicast frames are forwarded only to the destination port.
- Modern Ethernet networks exclusively use **switches** due to their superior performance, efficiency, and security.
