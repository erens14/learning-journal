# OSI Layer 2 — Data Link Layer (Ethernet & MAC Address)

## Table of Contents

- [OSI Layer 2 — Data Link Layer (Ethernet \& MAC Address)](#osi-layer-2--data-link-layer-ethernet--mac-address)
  - [Table of Contents](#table-of-contents)
  - [Overview](#overview)
  - [Responsibilities of Layer 2](#responsibilities-of-layer-2)
  - [Common Layer 2 Protocols](#common-layer-2-protocols)
  - [Protocol Data Unit (PDU) Naming](#protocol-data-unit-pdu-naming)
    - [Encapsulation Process](#encapsulation-process)
  - [Ethernet Frame Structure](#ethernet-frame-structure)
    - [1. Preamble](#1-preamble)
    - [2. Destination MAC Address](#2-destination-mac-address)
    - [3. Source MAC Address](#3-source-mac-address)
    - [4. EtherType](#4-ethertype)
    - [5. Data](#5-data)
    - [6. FCS (Frame Check Sequence)](#6-fcs-frame-check-sequence)
  - [MAC Address](#mac-address)
  - [MAC Address Structure](#mac-address-structure)
    - [First 24 Bits — OUI](#first-24-bits--oui)
    - [Last 24 Bits](#last-24-bits)
  - [How Many MAC Addresses Exist?](#how-many-mac-addresses-exist)
  - [MAC Addresses Are Flat Addresses](#mac-addresses-are-flat-addresses)
  - [MAC Address vs IP Address](#mac-address-vs-ip-address)
  - [Viewing MAC Addresses](#viewing-mac-addresses)
    - [Windows](#windows)
    - [Linux](#linux)
    - [Cisco IOS](#cisco-ios)
  - [My Takeaways](#my-takeaways)

## Overview

The **Data Link Layer (Layer 2)** is responsible for preparing data for transmission over the **Physical Layer (Layer 1)**.

Its primary responsibilities include:

- Encapsulating Layer 3 packets into **frames**
- Converting frames into bits for transmission
- Error detection (and sometimes correction)
- Physical addressing using **MAC addresses**

For Local Area Networks (LANs), the dominant Layer 2 technology is **Ethernet**.

## Responsibilities of Layer 2

The Data Link Layer performs several important functions before data is transmitted over the network.

- Frame encapsulation
- Physical (MAC) addressing
- Error detection
- Media access control
- Preparing data for Layer 1 transmission

```text
Layer 3 Packet
        │
        ▼
+----------------------+
| Layer 2 Header       |
|      Packet          |
| Layer 2 Trailer      |
+----------------------+
        │
        ▼
Frame
        │
        ▼
Layer 1 (Bits)
```

## Common Layer 2 Protocols

Different network technologies use different Layer 2 protocols.

| Protocol | Typical Usage | Status |
| ---------- | --------------- | -------- |
| Ethernet | LAN | ✅ Most common |
| PPP (Point-to-Point Protocol) | WAN | Common |
| Frame Relay | WAN | Legacy |
| FDDI | LAN Backbone | Legacy |

> **CCNA Focus:** Ethernet is by far the most important Layer 2 protocol for modern LANs.

## Protocol Data Unit (PDU) Naming

As data travels **down the OSI Model**, each layer adds its own header through a process called **encapsulation**.

The actual data remains the same; only the terminology changes depending on the layer being discussed.

| OSI Layer | PDU Name |
| ----------- | ---------- |
| Layer 7–5 | Data |
| Layer 4 | Segment |
| Layer 3 | Packet |
| Layer 2 | Frame |
| Layer 1 | Bits |

### Encapsulation Process

```text
Application Data
        │
        ▼
Layer 4 Header
        │
     Segment
        │
        ▼
Layer 3 Header
        │
      Packet
        │
        ▼
Layer 2 Header
Layer 2 Trailer
        │
      Frame
        │
        ▼
Physical Layer
        │
       Bits
```

> Although we use different names (segment, packet, frame), they all refer to the **same PDU** viewed from different OSI layers.

---

## Ethernet Frame Structure

An Ethernet frame contains several fields.

```text
+-----------+--------------+--------------+-----------+-----------+-----------+
| Preamble  | Destination  | Source MAC   | EtherType |   Data    |    FCS    |
+-----------+--------------+--------------+-----------+-----------+-----------+
```

### 1. Preamble

Purpose:

- Synchronizes sender and receiver before transmission begins.

### 2. Destination MAC Address

Contains the Layer 2 address of the receiving device.

### 3. Source MAC Address

Contains the Layer 2 address of the sending device.

### 4. EtherType

Identifies which Layer 3 protocol is encapsulated inside the Ethernet frame.

Common examples:

| EtherType | Encapsulated Protocol |
| ----------- | ----------------------- |
| IPv4 | Internet Protocol Version 4 |
| IPv6 | Internet Protocol Version 6 |
| ARP | Address Resolution Protocol |

### 5. Data

Contains the Layer 3 packet being transported.

### 6. FCS (Frame Check Sequence)

FCS uses **CRC (Cyclic Redundancy Check)** to detect transmission errors.

Purpose:

- Detect corrupted frames
- Verify frame integrity

If the calculated CRC differs from the received CRC:

```text
Frame is discarded.
```

## MAC Address

MAC stands for:

```text
Media Access Control
```

A MAC address uniquely identifies a network interface at Layer 2.

Characteristics:

- 48 bits
- 6 Bytes
- Written in hexadecimal

Example:

```text
68:50:43:24:58:01
```

or

```text
0018.7374.8D56
```

Both represent the same type of Layer 2 address.

## MAC Address Structure

A MAC address is divided into two equal parts.

```text
48 Bits

+----------------------+----------------------+
|        OUI           |   Vendor Assigned    |
|      24 Bits         |       24 Bits        |
+----------------------+----------------------+
```

### First 24 Bits — OUI

OUI stands for:

```text
Organizationally Unique Identifier
```

The OUI identifies the hardware manufacturer.

Examples:

- Cisco
- IBM
- Intel
- Dell

Every manufacturer receives one or more OUIs from the IEEE.

### Last 24 Bits

The remaining 24 bits are assigned by the manufacturer.

This ensures every NIC receives a globally unique MAC address.

## How Many MAC Addresses Exist?

Formula:

```text
2^48
```

Approximately:

```text
281,474,976,710,656
```

possible MAC addresses.

This enormous address space allows every Ethernet interface to have a unique identifier.

## MAC Addresses Are Flat Addresses

Unlike IP addresses, MAC addresses contain **no logical hierarchy**.

Example:

```text
IBM NIC
    │
    ├── New York
    ├── London
    └── Beijing
```

Although all three devices may share the same manufacturer (IBM), their locations have **no relationship** to their MAC addresses.

Characteristics:

- No subnetting
- No routing hierarchy
- No geographic meaning

This is known as a **flat address space**.

## MAC Address vs IP Address

| Feature | MAC Address | IP Address |
| ---------- | ------------- | ------------ |
| OSI Layer | Layer 2 | Layer 3 |
| Length | 48 bits | 32 bits (IPv4) |
| Address Type | Physical | Logical |
| Assigned By | Hardware Manufacturer | Network Administrator / DHCP |
| Routable | No | Yes |
| Used For | Local Network Communication | Inter-network Communication |

## Viewing MAC Addresses

### Windows

Command:

```bash
ipconfig /all
```

Look for:

```text
Physical Address
```

Example:

```text
68-50-43-24-58-01
```

---

### Linux

Command:

```bash
ifconfig
```

(or modern systems)

```bash
ip addr
```

Look for:

```text
HWaddr
```

or

```text
link/ether
```

Example:

```text
00:0c:29:c4:e8:7e
```

---

### Cisco IOS

Command:

```bash
show interfaces
```

Example output:

```text
address is 0018.7374.8d56
```

You may also see:

```text
BIA
```

which stands for:

```text
Burned-In Address
```

The BIA is the factory-programmed MAC address.

Although Cisco IOS allows the MAC address to be changed via software, the default behavior is to use the BIA.

## My Takeaways

- Layer 2 is the **Data Link Layer** of the OSI model.
- Ethernet is the dominant Layer 2 protocol in modern LANs.
- Layer 2 encapsulates **packets into frames** before transmission.
- Ethernet frames contain **Preamble, Destination MAC, Source MAC, EtherType, Data, and FCS**.
- The **FCS (CRC)** detects transmission errors.
- A MAC address is **48 bits (6 Bytes)** and uniquely identifies a network interface.
- The first **24 bits** are the **OUI (manufacturer)**, while the last **24 bits** are vendor assigned.
- MAC addresses use a **flat addressing scheme** and are **not routable**, unlike IP addresses.
- MAC addresses can be viewed using:
  - Windows: `ipconfig /all`
  - Linux: `ifconfig` or `ip addr`
  - Cisco IOS: `show interfaces`
