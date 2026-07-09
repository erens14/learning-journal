# OSI Layer 1 — Physical Layer

## Overview

The **Physical Layer (Layer 1)** is the lowest layer of the OSI Model. Its primary responsibility is transmitting and receiving **raw bits** across the physical medium.

Unlike higher layers that deal with logical communication, Layer 1 focuses on the **electrical, optical, and mechanical characteristics** of network communication.

Its primary responsibilities include:

- Transmitting and receiving raw bits
- Defining physical media (copper, fiber, wireless)
- Defining connectors and interfaces
- Specifying signaling methods
- Supporting physical network connectivity

Layer 1 does **not** understand frames, packets, or IP addresses—it only handles **bits (0s and 1s)**.

## Responsibilities of Layer 1

The Physical Layer is responsible for the actual transmission of data across the network medium.

- Converts bits into electrical, optical, or radio signals
- Receives signals and converts them back into bits
- Defines cable types
- Defines connector types
- Defines transmission speed
- Defines maximum cable distance
- Defines physical interface standards

```text
Layer 2 Frame
      │
      ▼
+----------------------+
| 01010101010101010101 |
| 11001100110011001100 |
| 00110011001100110011 |
+----------------------+
      │
      ▼
Electrical Signal
Light Signal
Radio Signal
```

## Physical Transmission Media

Layer 1 can transmit data using different physical media depending on the network environment.

| Media | Signal Type | Typical Usage |
| -------- | ------------- | --------------- |
| Copper Cable | Electrical | LAN |
| Fiber Optic Cable | Light | LAN Backbone, Campus |
| Wireless | Radio Waves | Wi-Fi |

## Copper (UTP) Cable

The most common cable used in Ethernet LANs is **UTP (Unshielded Twisted Pair)**.

Characteristics:

- Uses RJ-45 connectors
- Maximum cable length: **100 meters**
- Commonly connects:
  - PCs
  - Printers
  - IP Phones
  - Switches
  - Routers

Example:

```text
PC ─────────── Switch
      UTP Cable
```

## UTP Cable Categories

Over time, Ethernet speeds have increased, requiring higher-quality copper cabling.

| Category | Maximum Speed |
| ---------- | --------------- |
| Cat5 | 100 Mbps |
| Cat5e | 1 Gbps |
| Cat6 | 10 Gbps |
| Cat6a | 10 Gbps |
| Cat7 | 10 Gbps |
| Cat8 | 40 Gbps |

> Always ensure the installed cable category supports the bandwidth required by your network equipment.

## Straight-Through vs Crossover Cable

UTP cables can be wired in two different ways.

### Straight-Through Cable

Most commonly used.

Used to connect **different device types**.

Examples:

- PC → Switch
- Router → Switch
- Server → Switch

```text
PC ───────── Switch
```

### Crossover Cable

Used to connect **same device types** directly.

Examples:

- Switch ↔ Switch
- PC ↔ PC
- Router ↔ Router

```text
Switch ─────── Switch
```

Today, most modern switches support **Auto MDI-X**, allowing either straight-through or crossover cables to work automatically.

## Auto MDI-X

Modern Ethernet devices can automatically detect transmit (TX) and receive (RX) pairs.

Benefits:

- No need to manually choose crossover cables
- Simplifies network installation
- Automatically adjusts wiring internally

## Fiber Optic Cable

Fiber optic cables transmit data using **light** instead of electricity.

Advantages:

- Higher bandwidth
- Longer transmission distances
- Immune to electromagnetic interference (EMI)

Common uses:

- Building-to-building connections
- Campus networks
- Data centers
- High-speed switch uplinks

## Fiber Types

There are two major types of fiber optic cable.

| Type | Distance | Bandwidth | Cost |
| ------ | ---------- | ----------- | ------ |
| Multi Mode (MMF) | Hundreds of meters | High | Lower |
| Single Mode (SMF) | Hundreds of kilometers | Very High | Higher |

### Multi Mode Fiber (MMF)

Characteristics:

- Shorter distance
- Less expensive
- Common inside buildings and campuses

Typical maximum distance:

- Around **150–400 meters** depending on Ethernet standard.

### Single Mode Fiber (SMF)

Characteristics:

- Extremely long distance
- Highest bandwidth
- More expensive optics

Typical uses:

- ISP backbone
- Long-distance links
- Inter-city connectivity

## Fiber Connectors

Unlike copper cables, fiber cables usually connect to a **transceiver module** before connecting to the switch.

```text
Fiber Cable
      │
      ▼
Transceiver
      │
      ▼
Switch Port
```

Different fiber standards require different connector and transceiver types.

## Power over Ethernet (PoE)

**Power over Ethernet (PoE)** allows electrical power and network connectivity to be delivered through the same Ethernet cable.

Instead of requiring:

- Network cable
- Separate power adapter

only **one Ethernet cable** is needed.

## Devices That Commonly Use PoE

| Device | Uses PoE |
| --------- | ----------- |
| IP Phone | ✅ |
| Wireless Access Point | ✅ |
| IP Camera | ✅ |
| VoIP Phone | ✅ |

## Benefits of PoE

Advantages include:

- Less cabling
- Easier installation
- Cleaner workspaces
- Centralized power management
- Useful where electrical outlets are unavailable

Example:

```text
PoE Switch
      │
      ├──────── IP Phone
      │
      ├──────── Wireless AP
      │
      └──────── IP Camera
```

## PoE Injector

If an existing switch does **not** support PoE, a **PoE Injector** can be used.

The injector adds power to the Ethernet cable while preserving network connectivity.

```text
Switch
   │
   ▼
PoE Injector
   │
   ▼
Wireless Access Point
```

This is especially useful when deploying devices in locations where power outlets are difficult to install.

## Copper vs Fiber Comparison

| Feature | Copper (UTP) | Fiber Optic |
| ---------- | -------------- | ------------- |
| Signal Type | Electrical | Light |
| Max Typical Distance | 100 m | Hundreds of meters to hundreds of kilometers |
| Maximum Speed | Up to 40 Gbps (Cat8) | 100+ Gbps |
| EMI Resistance | No | Yes |
| Cost | Lower | Higher |
| Common Usage | PCs, Switches | Backbone, Campus, Data Center |

## Layer 1 vs Layer 2

| Feature | Layer 1 | Layer 2 |
| ---------- | ---------- | ---------- |
| PDU | Bits | Frame |
| Primary Responsibility | Physical transmission | Framing & MAC addressing |
| Addressing | None | MAC Address |
| Media | Copper, Fiber, Wireless | Ethernet |
| Error Detection | None | FCS (CRC) |

## My Takeaways

- Layer 1 is the **Physical Layer** of the OSI Model.
- Layer 1 transmits **raw bits** over physical media.
- Physical media include **Copper (UTP), Fiber Optic, and Wireless**.
- UTP cables use **RJ-45 connectors** and have a maximum length of **100 meters**.
- Common cable categories include **Cat5, Cat5e, Cat6, Cat6a, Cat7, and Cat8**, supporting increasing bandwidth.
- **Straight-through cables** connect different device types, while **crossover cables** connect similar device types.
- Modern devices support **Auto MDI-X**, reducing the need for crossover cables.
- Fiber optic cables provide **higher bandwidth** and **longer transmission distances** than copper.
- **Multi Mode Fiber (MMF)** is suitable for shorter distances, while **Single Mode Fiber (SMF)** supports much longer distances.
- Fiber connections typically require **transceivers** between the cable and the switch.
- **Power over Ethernet (PoE)** allows both power and data to be delivered through a single Ethernet cable.
- Common PoE devices include **IP Phones, Wireless Access Points, and IP Cameras**.
- A **PoE Injector** can provide power to Ethernet devices when using a non-PoE switch.
- Layer 1 handles only **physical transmission**, while Layer 2 is responsible for **framing and MAC addressing**.
