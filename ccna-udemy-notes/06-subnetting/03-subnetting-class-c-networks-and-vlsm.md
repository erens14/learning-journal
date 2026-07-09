# Subnetting Class C Network & VLSM

## Table Of Contents

- [Subnetting Class C Network \& VLSM](#subnetting-class-c-network--vlsm)
  - [Table Of Contents](#table-of-contents)
  - [Overview](#overview)
  - [Key Concepts](#key-concepts)
    - [/31 Subnet](#31-subnet)
      - [Calculation](#calculation)
      - [Address Pattern](#address-pattern)
      - [Practical Notes](#practical-notes)
    - [/30 Subnet](#30-subnet)
      - [Calculation](#calculation-1)
      - [Finding Network Increment](#finding-network-increment)
      - [Example](#example)
    - [/29 Subnet](#29-subnet)
      - [Calculation](#calculation-2)
      - [Finding Network Increment](#finding-network-increment-1)
      - [Example](#example-1)
  - [Quick Reference](#quick-reference)
  - [Fixed Length Subnet Mask (FLSM)](#fixed-length-subnet-mask-flsm)
  - [Variable Length Subnet Mask (VLSM)](#variable-length-subnet-mask-vlsm)
  - [My Takeaways](#my-takeaways)

## Overview

This lesson continues the subnetting fundamentals by exploring common subnet masks used in IPv4 networks and how to calculate the number of subnets, usable hosts, network addresses, and broadcast addresses.

It also introduces **Variable Length Subnet Masking (VLSM)**, which allows different subnet sizes within the same network, improving IP address utilization compared to Fixed Length Subnet Masking (FLSM).

## Key Concepts

### /31 Subnet

A **/31** subnet leaves only **1 host bit**.

Normally, IPv4 subnets require:

- 1 Network Address
- 1 Broadcast Address

However, **RFC 3021** allows Cisco devices to use **/31** for **Point-to-Point links**, where only two devices communicate directly.

#### **Subnet Mask**

```text
/31
255.255.255.254
```

Binary:

```text
11111111.11111111.11111111.11111110
```

#### Calculation

Default Class C:

```text
/24
```

Borrowed bits:

```text
31 - 24 = 7 bits
```

Number of subnets:

```text
2^7
= 128 subnets
```

Host bits remaining:

```text
32 - 31
= 1 bit
```

Possible host combinations:

```text
0 1
```

Normally:

```text
2^1 - 2
= 0 hosts
```

However, Cisco allows both addresses to be used on **Point-to-Point links**, so a /31 supports **2 usable addresses**.

#### Address Pattern

Network increments by **2**.

```text
200.15.10.0 - 200.15.10.1

200.15.10.2 - 200.15.10.3

200.15.10.4 - 200.15.10.5

...
```

#### Practical Notes

- Used only for Point-to-Point links.
- Saves IP address space.
- Rarely used for LAN segments.
- For the CCNA exam, only use /31 if explicitly requested.

---

### /30 Subnet

A **/30** subnet is the most common subnet for Point-to-Point connections because it provides exactly two usable host addresses.

**Subnet Mask**

```text
/30
255.255.255.252
```

Binary:

```text
11111111.11111111.11111111.11111100
```

#### Calculation

Borrowed bits:

```text
30 - 24
= 6 bits
```

Number of subnets:

```text
2^6
= 64 subnets
```

Host bits:

```text
32 - 30
= 2 bits
```

Usable hosts:

```text
2^2
= 4

4 - 2
= 2 usable hosts
```

#### Finding Network Increment

Look at the last octet:

```text
252
```

Increment:

```text
256 - 252
= 4
```

Therefore, every subnet starts every **4 addresses**.

```text
0
4
8
12
16
20
...
```

#### Example

Subnet 1

```text
Network = 200.15.10.0

Broadcast = 200.15.10.3

Usable
200.15.10.1
200.15.10.2
```

Subnet 2

```text
Network = 200.15.10.4

Broadcast = 200.15.10.7

Usable
200.15.10.5
200.15.10.6
```

Subnet 3

```text
Network = 200.15.10.8

Broadcast = 200.15.10.11

Usable
200.15.10.9
200.15.10.10
```

---

### /29 Subnet

A **/29** subnet provides six usable host addresses.

**Subnet Mask**

```text
/29
255.255.255.248
```

Binary:

```text
11111111.11111111.11111111.11111000
```

#### Calculation

Borrowed bits:

```text
29 - 24
= 5 bits
```

Number of subnets:

```text
2^5
= 32 subnets
```

Host bits:

```text
32 - 29
= 3 bits
```

Usable hosts:

```text
2^3
= 8

8 - 2
= 6 usable hosts
```

#### Finding Network Increment

```text
256 - 248
= 8
```

Network addresses increase every **8 addresses**.

```text
0
8
16
24
32
40
...
```

#### Example

Subnet 1

```text
Network = 200.15.10.0

Broadcast = 200.15.10.7

Usable
200.15.10.1
↓
200.15.10.6
```

Subnet 2

```text
Network = 200.15.10.8

Broadcast = 200.15.10.15

Usable
200.15.10.9
↓
200.15.10.14
```

Subnet 3

```text
Network = 200.15.10.16

Broadcast = 200.15.10.23

Usable
200.15.10.17
↓
200.15.10.22
```

---

## Quick Reference

| Prefix | Subnet Mask | Increment | Subnets (Class C) | Usable Hosts |
|---------|-------------|----------:|------------------:|-------------:|
| /31 | 255.255.255.254 | 2 | 128 | 2 (P2P only) |
| /30 | 255.255.255.252 | 4 | 64 | 2 |
| /29 | 255.255.255.248 | 8 | 32 | 6 |
| /28 | 255.255.255.240 | 16 | 16 | 14 |
| /27 | 255.255.255.224 | 32 | 8 | 30 |
| /26 | 255.255.255.192 | 64 | 4 | 62 |
| /25 | 255.255.255.128 | 128 | 2 | 126 |
| /24 | 255.255.255.0 | 256 | 1 | 254 |

## Fixed Length Subnet Mask (FLSM)

Early routing protocols, such as **RIPv1**, only supported **Fixed Length Subnet Masking (FLSM)**.

With FLSM:

- Every subnet must use the same subnet mask.
- Every subnet has the same number of usable hosts.
- Some IP addresses may be wasted.

Example:

```text
Department A
10 Hosts
↓
Uses /28 (14 Hosts)

Department B
30 Hosts
↓
Must also use /27 (30 Hosts)

OR

Both departments use /27
↓
Unused addresses are wasted.
```

## Variable Length Subnet Mask (VLSM)

Modern routing protocols support **Variable Length Subnet Masking (VLSM)**.

With VLSM:

- Different subnet sizes can exist within the same network.
- Each subnet receives only the number of addresses it actually requires.
- IP address utilization becomes much more efficient.

Example:

```text
Sales

10 Hosts
↓
/28
14 Hosts

Accounting
28 Hosts
↓
/27
30 Hosts
```

Benefits:

- Better IP utilization
- Less address waste
- Greater scalability
- More flexible network design

## My Takeaways

- **/31** is a special subnet designed for Point-to-Point links and is supported by Cisco routers.
- **/30** remains the standard subnet size for Point-to-Point links in most CCNA scenarios.
- The **network increment** can be calculated using **256 − last octet of the subnet mask**.
- As the prefix length increases, the number of subnets increases while the number of usable hosts decreases.
- **FLSM** requires all subnets to have the same size, whereas **VLSM** allows subnet sizes to match actual requirements, resulting in more efficient IP address allocation.
