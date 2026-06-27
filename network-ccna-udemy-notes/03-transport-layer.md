# Transport Layer Notes (TCP & UDP)

---

# Overview

The **Transport Layer (Layer 4)** is responsible for delivering data between applications running on different hosts.

While the Network Layer determines **where** packets should go (using IP addresses), the Transport Layer determines **which application** should receive the data by using **port numbers**.

The two main transport protocols are:

* TCP (Transmission Control Protocol)
* UDP (User Datagram Protocol)

Choosing between them depends on whether reliability or speed is the priority.

---

# Main Responsibilities

## End-to-End Communication

Provides communication between applications running on different devices instead of simply sending packets between networks.

---

## Segmentation & Reassembly

Large pieces of application data are divided into smaller segments before transmission.

The receiving host reassembles those segments into the original data.

---

## Flow Control

TCP prevents the sender from overwhelming the receiver by controlling how much data can be sent at one time.

This helps maintain stable communication.

---

## Multiplexing

A computer can communicate with multiple services simultaneously.

Port numbers allow the operating system to distinguish between those sessions.

Example:

* Browser → HTTPS (443)
* Discord → Voice
* SSH Terminal → 22

Each session remains independent.

---

# Port Numbers

Common ports I should remember:

| Service | Protocol  | Port |
| ------- | --------- | ---: |
| FTP     | TCP       |   21 |
| SSH     | TCP       |   22 |
| Telnet  | TCP       |   23 |
| HTTP    | TCP       |   80 |
| HTTPS   | TCP       |  443 |
| DNS     | TCP / UDP |   53 |
| TFTP    | UDP       |   69 |
| SNMP    | UDP       |  161 |

Interesting note:

The client usually uses a random **ephemeral port**, while the server listens on a **well-known port**.

Example:

```text
Client
192.168.1.10:51234
        │
        ▼
Web Server
192.168.1.100:443
```

---

# Stateful Firewall

A stateful firewall doesn't inspect packets independently.

Instead, it remembers active connections using a **state table**.

Typical information stored includes:

* Source IP
* Destination IP
* Source Port
* Destination Port

If a packet belongs to an existing session, it can be allowed automatically.

This explains why return traffic is usually accepted without creating another firewall rule.

---

# TCP

TCP is designed for **reliable communication**.

Features:

* Connection-oriented
* Reliable delivery
* Sequence numbers
* Acknowledgements
* Retransmission
* Flow control

TCP is slower than UDP because it performs additional checks to ensure data integrity.

Typical use cases:

* Web browsing
* Email
* SSH
* File transfer

---

## TCP Three-Way Handshake

Before sending data, TCP establishes a connection.

```text
Client                  Server

SYN -------------------->

      <----------------- SYN + ACK

ACK -------------------->
```

Once the handshake finishes, both devices can exchange data.

---

# UDP

UDP is designed for **speed**.

Unlike TCP, it does not perform:

* Connection establishment
* Packet ordering
* Acknowledgements
* Retransmission
* Flow control

Because of this, UDP has much lower overhead.

Typical use cases:

* Online games
* Voice calls
* Video streaming
* Live broadcasts

Occasional packet loss is usually acceptable because retransmission would introduce noticeable delays.

---

# TCP vs UDP

| Feature         | TCP    | UDP     |
| --------------- | ------ | ------- |
| Connection      | Yes    | No      |
| Reliable        | Yes    | No      |
| Packet Ordering | Yes    | No      |
| Retransmission  | Yes    | No      |
| Flow Control    | Yes    | No      |
| Speed           | Slower | Faster  |
| Header Size     | Larger | Smaller |

---

# My Takeaways

* The Transport Layer is responsible for communication **between applications**, not just between devices.
* IP addresses identify **where** data should go, while port numbers identify **which application** should receive it.
* TCP prioritizes reliability, whereas UDP prioritizes low latency.
* Not every application requires reliable delivery; choosing the right protocol depends on the application's requirements.
* Understanding TCP and UDP helps explain many real-world networking behaviors, such as API communication, online gaming, VoIP, and firewall rules.
