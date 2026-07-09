# The IP Headers

## Overview

This lecture introduces **Layer 3 (Network Layer)** of the OSI Model and explains how IP addressing enables communication between different networks.

The lecture also introduces the IPv4 header and explains the purpose of each important field.

## Layer 3 Responsibilities

The Network Layer is responsible for:

* Routing packets between different networks.
* Providing logical addressing through IP addresses.
* Supporting Quality of Service (QoS).
* Dividing large networks into smaller subnets.

Unlike TCP, IP is **connectionless**, meaning it does not guarantee packet delivery or acknowledgements.

Reliability is handled by upper-layer protocols such as TCP.

## Common Layer 3 Protocols

| Protocol | Purpose                            |
| -------- | ---------------------------------- |
| IPv4     | Logical addressing and routing     |
| IPv6     | Next-generation IP addressing      |
| ICMP     | Network diagnostics (e.g., `ping`) |
| IPsec    | Secure encrypted communication     |

## Why Use Subnets?

Instead of placing every device inside one large network, IP addressing allows the network to be divided into **subnets**.

Benefits include:

* Better network performance.
* Improved security through logical separation.
* Easier troubleshooting.
* Simpler access control.

Example:

* Accounting servers can be placed on their own subnet.
* Only authorized users are allowed to access that subnet.

## Layer 2 vs Layer 3 Addressing

|   Layer | Address Type | Device |
| ------: | ------------ | ------ |
| Layer 3 | IP Address   | Router |
| Layer 2 | MAC Address  | Switch |

Key difference:

* **IP Address** is a **logical address** and can change depending on the network.
* **MAC Address** is a hardware address assigned to the network interface.

## OSI Review

Packet encapsulation follows the OSI Model:

```text
Application
↓

Presentation
↓

Session
↓

Transport
    • TCP / UDP
    • Port Numbers
↓

Network
    • Source IP
    • Destination IP
↓

Data Link
    • Source MAC
    • Destination MAC
↓

Physical
```

Network devices by layer:

|   Layer | Device       |
| ------: | ------------ |
| Layer 3 | Router       |
| Layer 2 | Switch       |
| Layer 1 | Hub (legacy) |

## IPv4 Header

The IPv4 header contains information required to deliver packets across networks.

Important fields include:

| Field                  | Purpose                               |
| ---------------------- | ------------------------------------- |
| Version                | Indicates IPv4 or IPv6                |
| Header Length          | Length of the IP header               |
| Type of Service (QoS)  | Traffic priority                      |
| Total Length           | Total packet size                     |
| Fragmentation Fields   | Track fragmented packets              |
| TTL (Time To Live)     | Prevent routing loops                 |
| Protocol               | Identifies Layer 4 protocol (TCP/UDP) |
| Header Checksum        | Detect header corruption              |
| Source IP Address      | Sender's IP address                   |
| Destination IP Address | Receiver's IP address                 |
| Options                | Optional additional information       |
| Data                   | Encapsulated payload                  |

## Time To Live (TTL)

Every router decreases the TTL value by **1**.

If TTL reaches **0**, the router discards the packet.

Purpose:

* Prevent packets from looping forever because of routing errors.
* Reduce unnecessary network traffic.

## Fragmentation

Different network technologies have different **Maximum Transmission Unit (MTU)** values.

Example:

* Ethernet default MTU = **1500 bytes**

If a packet exceeds the MTU, it is divided into multiple **fragments** before transmission.

The fragmentation fields in the IP header allow the receiving host to reconstruct the original packet.

## My Takeaways

* Layer 3 is responsible for logical addressing and routing between networks.
* IP itself is connectionless; reliable communication is provided by TCP.
* Subnetting improves performance, security, and network management.
* Routers forward packets using IP addresses, while switches forward frames using MAC addresses.
* TTL is a simple but effective mechanism for preventing routing loops.
* Understanding the IPv4 header is essential before learning routing, subnetting, and packet analysis.
