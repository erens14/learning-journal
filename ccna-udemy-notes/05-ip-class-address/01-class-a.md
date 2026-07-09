# IP Address Classes (Class A)

## Overview

This lesson introduces the original **IPv4 Classful Addressing** model, focusing on **Class A addresses**. It explains why IPv4 addresses were divided into classes, how Class A networks allocate network and host bits, and why IPv4 eventually ran out of public addresses.

The lesson also introduces the roles of **IANA**, reserved address ranges, loopback addresses, and subnetting within large enterprise networks.

## Key Concepts

### Classful Addressing

Originally, IPv4 addresses were divided into different classes (A, B, C, D, and E) to accommodate organizations of different sizes.

Each class provides a different balance between:

- Number of networks
- Number of hosts per network

A smaller network portion allows more hosts, while a larger network portion allows more networks.

### Network vs Host Trade-off

The subnet mask determines how many bits belong to the network and host portions.

| Subnet | Network Bits | Host Bits | Result |
| --------- | -------------: | ----------: | -------- |
| /8 | 8 | 24 | Few networks, many hosts |
| /24 | 24 | 8 | Many networks, fewer hosts |

### IPv4 Address Allocation

Originally, organizations requested public IPv4 address ranges from regional Internet authorities.

Address allocation hierarchy:

```text
IANA
   │
Regional Internet Registries
   │
Organizations
   │
Hosts
```

Large organizations received address blocks that could later be divided into smaller subnets.

### IPv4 Address Exhaustion

When IPv4 was designed, its creators did not anticipate the explosive growth of the Internet.

As a result:

- IPv4 uses only **32 bits**
- Public IPv4 addresses eventually became exhausted

Today, organizations mainly rely on:

- Private IP addressing
- Network Address Translation (NAT)

The long-term solution is **IPv6**, which provides a much larger **128-bit** address space.

## Class A Addresses

Characteristics:

| Property | Value |
| ---------- | ------- |
| First bit | Always **0** |
| Default subnet mask | **255.0.0.0 (/8)** |
| Network range | **1.0.0.0 – 126.0.0.0** |
| Hosts per network | **16,777,214** |

Binary format:

```text
0xxxxxxx.HHHHHHHH.HHHHHHHH.HHHHHHHH
│
└── Network Portion (/8)
```

## Reserved Class A Addresses

Some Class A ranges cannot be assigned to hosts.

| Address Range | Purpose |
| -------------- | --------- |
| 0.0.0.0/8 | Reserved ("This Network") |
| 127.0.0.0/8 | Loopback testing |

Example:

```text
127.0.0.1
```

Loopback allows a computer to test its own TCP/IP stack without using a physical network connection.

## Subnetting Class A Networks

Although a Class A network supports over 16 million hosts, organizations typically divide it into smaller subnets.

Example:

```text
Assigned Network

15.0.0.0/8
│
├── 15.0.1.0/24 → Sales (New York)
├── 15.0.2.0/24 → Accounting
└── 15.0.9.0/24 → Sales (Boston)
```

This process is called **subnetting**, which improves network organization, scalability, performance, and security.

## Lesson Learned

- Classful addressing originally divided IPv4 into different address classes based on organization size.
- Class A networks use a **/8** subnet mask, allowing a very large number of hosts.
- IPv4 address exhaustion occurred because the original design underestimated Internet growth.
- Reserved ranges such as **0.0.0.0/8** and **127.0.0.0/8** cannot be assigned to normal hosts.
- Large address blocks are commonly divided into smaller subnets through subnetting.
