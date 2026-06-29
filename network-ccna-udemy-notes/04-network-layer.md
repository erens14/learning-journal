# Network Layer

> **Progress:** 3/7 

---

# 1. The IP Header

## Overview

This lecture introduces **Layer 3 (Network Layer)** of the OSI Model and explains how IP addressing enables communication between different networks.

The lecture also introduces the IPv4 header and explains the purpose of each important field.

---

# Layer 3 Responsibilities

The Network Layer is responsible for:

* Routing packets between different networks.
* Providing logical addressing through IP addresses.
* Supporting Quality of Service (QoS).
* Dividing large networks into smaller subnets.

Unlike TCP, IP is **connectionless**, meaning it does not guarantee packet delivery or acknowledgements.

Reliability is handled by upper-layer protocols such as TCP.

---

# Common Layer 3 Protocols

| Protocol | Purpose                            |
| -------- | ---------------------------------- |
| IPv4     | Logical addressing and routing     |
| IPv6     | Next-generation IP addressing      |
| ICMP     | Network diagnostics (e.g., `ping`) |
| IPsec    | Secure encrypted communication     |

---

# Why Use Subnets?

Instead of placing every device inside one large network, IP addressing allows the network to be divided into **subnets**.

Benefits include:

* Better network performance.
* Improved security through logical separation.
* Easier troubleshooting.
* Simpler access control.

Example:

* Accounting servers can be placed on their own subnet.
* Only authorized users are allowed to access that subnet.

---

# Layer 2 vs Layer 3 Addressing

|   Layer | Address Type | Device |
| ------: | ------------ | ------ |
| Layer 3 | IP Address   | Router |
| Layer 2 | MAC Address  | Switch |

Key difference:

* **IP Address** is a **logical address** and can change depending on the network.
* **MAC Address** is a hardware address assigned to the network interface.

---

# OSI Review

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

---

# IPv4 Header

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

---

## Time To Live (TTL)

Every router decreases the TTL value by **1**.

If TTL reaches **0**, the router discards the packet.

Purpose:

* Prevent packets from looping forever because of routing errors.
* Reduce unnecessary network traffic.

---

## Fragmentation

Different network technologies have different **Maximum Transmission Unit (MTU)** values.

Example:

* Ethernet default MTU = **1500 bytes**

If a packet exceeds the MTU, it is divided into multiple **fragments** before transmission.

The fragmentation fields in the IP header allow the receiving host to reconstruct the original packet.

---

# My Takeaways

* Layer 3 is responsible for logical addressing and routing between networks.
* IP itself is connectionless; reliable communication is provided by TCP.
* Subnetting improves performance, security, and network management.
* Routers forward packets using IP addresses, while switches forward frames using MAC addresses.
* TTL is a simple but effective mechanism for preventing routing loops.
* Understanding the IPv4 header is essential before learning routing, subnetting, and packet analysis.

---

# 2. Traffic Types

## Overview

This lecture introduces the three primary traffic delivery methods used in IP networks:

* Unicast
* Broadcast
* Multicast

Each traffic type serves a different purpose depending on how many destination devices should receive the data.

---

## Unicast

Unicast communication sends data from one sender to one specific destination.

Characteristics:

* One sender
* One receiver
* Most common traffic type on modern networks

Examples:

* Opening a website
* SSH connection
* Downloading a file
* API communication

Diagram : 

![Unicast Traffic Diagram](../images/network-traffic-diagrams/unicast-traffic-diagram.jpg)

![Unicast Traffic with Multiple Host Diagram](../images/network-traffic-diagrams/unicast-multiple-host-diagram.jpg)
---

## Broadcast

Broadcast communication sends one packet to **every host within the same subnet**.

Characteristics:

* One sender
* All devices on the local network receive the packet
* Routers do **not** forward broadcast traffic

Reason:

Limiting broadcast traffic to a single subnet helps improve performance and prevents unnecessary traffic from spreading across larger networks such as the Internet.

---

## Multicast

Multicast sends **one copy of data** to **multiple subscribed receivers**.

Unlike broadcast, only devices that have joined the multicast group receive the traffic.

Benefits:

* Saves bandwidth
* Reduces duplicate traffic
* More efficient than sending multiple unicast streams

Example:

A server streaming a live video to multiple users.

Instead of transmitting three separate streams, the server sends one multicast stream that is delivered only to interested receivers.

---

## Traffic Comparison

| Traffic Type | Destination           | Router Forwarding   | Typical Use                        |
| ------------ | --------------------- | ------------------- | ---------------------------------- |
| Unicast      | One host              | Yes                 | Web browsing, SSH, Email           |
| Broadcast    | All hosts on a subnet | No                  | ARP, DHCP Discover                 |
| Multicast    | Selected hosts        | Yes (if configured) | IPTV, Video Streaming, Live Events |

---

## Key Concept

Broadcast and multicast may appear similar because both deliver data to multiple devices.

The main difference is:

* **Broadcast** reaches every device on the subnet.
* **Multicast** reaches only devices that explicitly join the multicast group.

This makes multicast much more bandwidth-efficient for one-to-many communication.

---

## My Takeaways

* Unicast is the default communication model used by most applications.
* Broadcast is limited to a single subnet because routers intentionally stop broadcast traffic.
* Multicast reduces bandwidth usage by sending one stream to multiple subscribed receivers.
* Choosing the appropriate traffic type is important for network efficiency and scalability.

---

# 3. Decimal to Binary Conversion

## Overview

Although IP addresses are commonly written in **decimal notation**, computers process them in **binary**.

Understanding binary is essential because IPv4 addresses, subnet masks, and subnetting calculations are all based on binary values.

---

## Decimal vs Binary

Humans naturally count using the **decimal (base-10)** number system.

Decimal digits:

```text
0 1 2 3 4 5 6 7 8 9
```

Each column increases by a factor of **10**.

| 1000 | 100 | 10 |  1 |
| ---: | --: | -: | -: |

Computers, however, use the **binary (base-2)** number system.

Binary digits:

```text
0 1
```

Each column increases by a factor of **2**.

| 128 | 64 | 32 | 16 |  8 |  4 |  2 |  1 |
| --: | -: | -: | -: | -: | -: | -: | -: |

---

## Binary Conversion Process

The conversion follows a simple rule:

Starting from the largest value, ask:

> **Can this value fit into the remaining decimal number?**

* Yes → Write **1** and subtract the value.
* No → Write **0** and move to the next column.

Continue until reaching the last column (1).

---

## Example 1 — Convert 236 to Binary

```text
Decimal = 236

128 ✓   Remaining = 108
 64 ✓   Remaining = 44
 32 ✓   Remaining = 12
 16 ✗
  8 ✓   Remaining = 4
  4 ✓   Remaining = 0
  2 ✗
  1 ✗
```

Result:

```text
236 = 11101100₂
```

Verification:

```text
128 + 64 + 32 + 8 + 4

= 236 ✓
```

---

## Example 2 — Convert 179 to Binary

```text
Decimal = 179

128 ✓   Remaining = 51
 64 ✗
 32 ✓   Remaining = 19
 16 ✓   Remaining = 3
  8 ✗
  4 ✗
  2 ✓   Remaining = 1
  1 ✓   Remaining = 0
```

Result:

```text
179 = 10110011₂
```

Verification:

```text
128 + 32 + 16 + 2 + 1

= 179 ✓
```

---

## Quick Reference
[!TIP]

| Decimal | Binary   |
| ------: | :------- |
|       1 | 00000001 |
|       2 | 00000010 |
|       4 | 00000100 |
|       8 | 00001000 |
|      16 | 00010000 |
|      32 | 00100000 |
|      64 | 01000000 |
|     128 | 10000000 |

Memorizing these eight values makes subnetting much easier later.

---

## Tips

When converting decimal to binary:

1. Always start from the **largest binary value**.
2. Subtract the value whenever possible.
3. Continue until the remaining value becomes **0**.
4. Verify the answer by adding every column that contains **1**.

---

## Why This Matters

Binary conversion is one of the most important prerequisites for:

* IPv4 Addressing
* CIDR Notation
* Subnet Masks
* Subnetting
* Route Summarization

A solid understanding of binary makes subnetting much easier to understand.

---

## My Takeaways

* Computers interpret IP addresses in binary, even though humans write them in decimal.
* Binary uses only two digits (0 and 1), with each column representing a power of two.
* Converting decimal to binary follows a simple "fit or not fit" approach.
* Checking the result by adding all active bit values helps verify the conversion.
* Memorizing the values **128, 64, 32, 16, 8, 4, 2, 1** will significantly speed up subnetting calculations.
