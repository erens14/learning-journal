# Subnet Masks

## Overview

A subnet mask defines the boundary between the **network** and **host** portions of an IPv4 address. It enables devices to determine whether a destination is on the same subnet or a different subnet, allowing them to decide whether to send traffic directly or forward it to a router.

## Key Concepts

### Same Subnet vs Different Subnet

* Devices on the **same subnet** communicate directly through a switch.
* Devices on **different subnets** communicate through a router (default gateway).
* A host compares the destination IP address with its own subnet mask before forwarding traffic.

```text
Destination IP
      │
      ▼
Compare using Subnet Mask
      │
      ├── Same Network → Send directly
      └── Different Network → Send to Default Gateway
```

### Network and Host Portions

The subnet mask separates an IP address into two parts:

* **Network Portion** → Identifies the subnet.
* **Host Portion** → Identifies an individual device within that subnet.

Example:

```text
IP Address : 192.168.10.15
Subnet Mask: 255.255.255.0

Network Portion : 192.168.10
Host Portion    : .15
```

### Valid Subnet Mask

A valid subnet mask always consists of **contiguous 1s followed by contiguous 0s**.

Valid example:

```text
11111111.11111111.11111111.00000000
```

Invalid example:

```text
11101111.11111111.00000000.00000000
```

### Reserved Addresses

Two addresses in every subnet cannot be assigned to hosts.

| Address           | Purpose           |
| ----------------- | ----------------- |
| All host bits = 0 | Network Address   |
| All host bits = 1 | Broadcast Address |

Example (`192.168.10.0/24`):

| Address Range                 | Usage                 |
| ----------------------------- | --------------------- |
| 192.168.10.0                  | Network Address       |
| 192.168.10.1 – 192.168.10.254 | Usable Host Addresses |
| 192.168.10.255                | Broadcast Address     |

### Host Address Rules

* Every device on the same subnet must have a **unique IP address**.
* Host addresses do **not** need to be sequential.
* Duplicate IP addresses on the same subnet are not allowed.

## My Takeaways

* A subnet mask separates the network and host portions of an IPv4 address.
* Devices use the subnet mask to determine whether traffic is local or must be sent to a router.
* Communication within the same subnet is direct, while different subnets require a default gateway.
* Valid subnet masks always contain contiguous `1`s followed by contiguous `0`s.
* Network and Broadcast addresses are reserved and cannot be assigned to end devices.
