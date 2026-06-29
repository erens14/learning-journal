# Network Fundamentals

## Table of Contents
- [Network Fundamentals](#network-fundamentals)
  - [Table of Contents](#table-of-contents)
  - [Network Characteristics](#network-characteristics)
    - [Topology](#topology)
    - [Speed](#speed)
    - [Cost](#cost)
    - [Security](#security)
    - [Availability](#availability)
    - [Scalability](#scalability)
    - [Reliability](#reliability)
  - [OSI Model](#osi-model)
    - [Data Transmission Process](#data-transmission-process)
    - [OSI Layers](#osi-layers)
    - [OSI Mnemonic](#osi-mnemonic)
  - [TCP/IP Suite](#tcpip-suite)
    - [OSI vs TCP/IP](#osi-vs-tcpip)
    - [Protocol Data Unit (PDU)](#protocol-data-unit-pdu)
  - [Upper OSI Layers](#upper-osi-layers)
    - [Layer 7 – Application](#layer-7--application)
    - [Layer 6 – Presentation](#layer-6--presentation)
    - [Layer 5 – Session](#layer-5--session)
  - [Lower OSI Layers](#lower-osi-layers)
    - [Layer 4 – Transport](#layer-4--transport)
    - [Layer 3 – Network](#layer-3--network)
    - [Layer 2 – Data Link](#layer-2--data-link)
    - [Layer 1 – Physical](#layer-1--physical)
  - [My Takeaways](#my-takeaways)


## Network Characteristics

A well-designed network should consider the following characteristics:

### Topology

The physical or logical layout of devices within a network.

### Speed

The rate at which data is transmitted across the network.

### Cost

The financial investment required to build and maintain the network infrastructure.

### Security

Protects network resources from unauthorized access and attacks.

Examples:

* Firewall
* IDS (Intrusion Detection System)
* IPS (Intrusion Prevention System)

### Availability

Ensures that network services remain operational and accessible with minimal downtime.

### Scalability

The network should be designed so it can grow without requiring a complete redesign.

### Reliability

The network should consistently provide stable and dependable communication.

## OSI Model

The **OSI (Open Systems Interconnection) Model** is a general-purpose framework that explains how computers communicate over a network.

It consists of **seven layers**, where each layer performs a specific responsibility.

### Data Transmission Process

Example: Sending an email

```text
Sender

↓

Layer 7 (Application)
↓

Layer 6 (Presentation)
↓

Layer 5 (Session)
↓

Layer 4 (Transport)
    • Adds TCP/UDP information
↓

Layer 3 (Network)
    • Adds Source IP
    • Adds Destination IP
↓

Layer 2 (Data Link)
    • Adds Source MAC
    • Adds Destination MAC
↓

Layer 1 (Physical)
    • Transmits bits over the physical medium

──────────────────────────────

Receiver

Layer 1
↓

Layer 2
↓

Layer 3
↓

Layer 4
↓

Layer 5
↓

Layer 6
↓

Layer 7
```

This process is known as:

* **Encapsulation** (Sender)
* **Decapsulation** (Receiver)

---

### OSI Layers

| Layer | Name         | Main Information            | Common Device |
| ----: | ------------ | --------------------------- | ------------- |
|     7 | Application  | Network services            | -             |
|     6 | Presentation | Data formatting, encryption | -             |
|     5 | Session      | Session management          | -             |
|     4 | Transport    | TCP, UDP, Ports             | -             |
|     3 | Network      | IP Address                  | Router        |
|     2 | Data Link    | MAC Address, Ethernet       | Switch        |
|     1 | Physical     | Electrical/Optical Signals  | Cable         |

---

### OSI Mnemonic

Remember the OSI layers from Layer 1 to Layer 7:

> **Please Do Not Throw Sausage Pizza Away**

---

## TCP/IP Suite

The TCP/IP protocol suite was developed by the **U.S. Department of Defense (DoD)** through **ARPA (Advanced Research Projects Agency)**.

TCP/IP is the networking model used by the modern Internet.

---

### OSI vs TCP/IP

| OSI Model    | TCP/IP Stack |
| ------------ | ------------ |
| Application  | Application  |
| Presentation | Application  |
| Session      | Application  |
| Transport    | Transport    |
| Network      | Internet     |
| Data Link    | Link         |
| Physical     | Link         |

---

### Protocol Data Unit (PDU)

When two hosts communicate, they exchange **Protocol Data Units (PDUs)**.

| Layer              | PDU     |
| ------------------ | ------- |
| Application        | Data    |
| Transport          | Segment |
| Internet / Network | Packet  |
| Link / Data Link   | Frame   |

---

## Upper OSI Layers

### Layer 7 – Application

* Provides network services to end-user applications.
* Allows users to interact with network resources.
* May also participate in maintaining data integrity.

---

### Layer 6 – Presentation

Responsible for ensuring that information sent from the Application layer can be correctly interpreted by the receiving device.

Responsibilities include:

* Data translation
* Encryption
* Compression

---

### Layer 5 – Session

Responsible for managing communication sessions between hosts.

Responsibilities include:

* Establishing sessions
* Maintaining sessions
* Terminating sessions

---

## Lower OSI Layers

### Layer 4 – Transport

Responsible for:

* Segmentation
* Data transfer
* Reassembly
* End-to-end communication

Protocols:

* TCP
* UDP

---

### Layer 3 – Network

Responsible for communication between different networks.

Most important information:

* Source IP Address
* Destination IP Address

Responsibilities:

* Logical addressing
* Routing
* Path selection

Device:

* Router

---

### Layer 2 – Data Link

Responsible for communication within the same local network.

Most important information:

* Source MAC Address
* Destination MAC Address

Responsibilities:

* Frame formatting
* Media access control
* Error detection

Device:

* Switch

---

### Layer 1 – Physical

Represents the physical components used to transmit data.

Examples:

* Ethernet cable
* Fiber optic cable
* Connectors
* Network Interface Cards (NIC)

Responsibilities:

* Signal transmission
* Hardware specifications
* Physical connectivity

---

## My Takeaways

* The OSI model provides a conceptual framework for understanding network communication.
* The TCP/IP model is the practical networking model used by the Internet.
* Encapsulation and decapsulation describe how data moves through the OSI layers.
* Layer 3 primarily handles IP addressing and routing, while Layer 2 handles MAC addressing and local network communication.

