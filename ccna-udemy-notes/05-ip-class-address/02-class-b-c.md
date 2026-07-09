# IP Address Classes (Class B & Class C)

## Overview

This lesson continues the discussion of **IPv4 Classful Addressing** by introducing **Class B** and **Class C** addresses. It explains their default subnet masks, network ranges, host capacities, and the concept of **private IP address ranges** reserved for internal networks.

## Key Concepts

### Class B Addresses

Class B addresses were originally designed for **medium to large-sized networks**.

Characteristics:

| Property | Value |
| ---------- | ------- |
| First bits | **10** |
| Default subnet mask | **255.255.0.0 (/16)** |
| Network range | **128.0.0.0 – 191.255.0.0** |
| Number of networks | **16,384** |
| Hosts per network | **65,534** |

Binary format:

```text
10xxxxxx.xxxxxxxx.HHHHHHHH.HHHHHHHH
│───────────────│
 Network (/16)
```

Although a Class B network supports over 65,000 hosts, organizations typically divide it into smaller subnets.

### Class C Addresses

Class C addresses were designed for **small networks**.

Characteristics:

| Property | Value |
| ---------- | ------- |
| First bits | **110** |
| Default subnet mask | **255.255.255.0 (/24)** |
| Network range | **192.0.0.0 – 223.255.255.0** |
| Number of networks | **2,097,152** |
| Hosts per network | **254** |

Binary format:

```text
110xxxxx.xxxxxxxx.xxxxxxxx.HHHHHHHH
│────────────────────────│
      Network (/24)
```

A Class C network is often small enough to be deployed directly, although it can still be subnetted if needed.

### Private IP Address Ranges

Certain IPv4 address ranges are reserved for **private networks**. These addresses:

- Can be assigned to hosts.
- Are **not routable** on the public Internet.
- Are commonly used in homes, schools, and enterprise networks.

Private address ranges:

| Class | Private Range |
| ------- | --------------- |
| Class A | **10.0.0.0 – 10.255.255.255** |
| Class B | **172.16.0.0 – 172.31.255.255** |
| Class C | **192.168.0.0 – 192.168.255.255** |

## Class Comparison

| Class | First Bits | Default Mask | Hosts per Network |
| ------ | ------------ | -------------- | ------------------: |
| A | 0 | /8 | 16,777,214 |
| B | 10 | /16 | 65,534 |
| C | 110 | /24 | 254 |

## My Takeaways

- Class B addresses use a **/16** subnet mask and support medium to large networks.
- Class C addresses use a **/24** subnet mask and are commonly used for small networks.
- Large Class A and B networks are typically divided into smaller subnets for better management.
- Private IP addresses are valid for internal communication but cannot be routed on the public Internet.
- The three private IPv4 ranges (10.x.x.x, 172.16–31.x.x, and 192.168.x.x) are widely used in modern networks
