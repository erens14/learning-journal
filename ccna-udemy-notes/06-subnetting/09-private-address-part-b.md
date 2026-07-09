# Private IP Addressing & NAT (RFC 1918)

## Table of Contents

- [Private IP Addressing \& NAT (RFC 1918)](#private-ip-addressing--nat-rfc-1918)
  - [Table of Contents](#table-of-contents)
  - [Overview](#overview)
  - [Why IPv6 Didn't Replace IPv4 Quickly](#why-ipv6-didnt-replace-ipv4-quickly)
  - [Why Companies Still Prefer IPv4 + NAT](#why-companies-still-prefer-ipv4--nat)
    - [1. Built-in Security](#1-built-in-security)
    - [2. Easier Migration](#2-easier-migration)
    - [3. Engineers Already Know IPv4](#3-engineers-already-know-ipv4)
  - [Where IPv6 Is Common Today](#where-ipv6-is-common-today)
  - [IPv4 Public Addresses Were Exhausted](#ipv4-public-addresses-were-exhausted)
  - [Subnetting Is Still Important](#subnetting-is-still-important)
  - [Common Subnet Sizes in Enterprise Networks](#common-subnet-sizes-in-enterprise-networks)
  - [Why /24 Is So Popular](#why-24-is-so-popular)
  - [When Is Complex VLSM Used?](#when-is-complex-vlsm-used)
  - [Route Summarization Still Matters](#route-summarization-still-matters)
  - [Good Address Planning (Contiguous Networks)](#good-address-planning-contiguous-networks)
    - [Region A](#region-a)
    - [Region B](#region-b)
  - [Poor Address Planning (Non-Contiguous)](#poor-address-planning-non-contiguous)
    - [Region A](#region-a-1)
    - [Region B](#region-b-1)
  - [Best Practices for Enterprise Address Planning](#best-practices-for-enterprise-address-planning)
  - [Comparison](#comparison)
  - [My Takeaways](#my-takeaways)

## Overview

As the Internet grew rapidly, the available **IPv4 public address space** became insufficient. To solve this problem temporarily while waiting for IPv6 adoption, the networking industry introduced **private IP addressing (RFC 1918)** and **Network Address Translation (NAT)**.

Today, almost every enterprise network uses **private IPv4 addresses internally** and translates them to **public IP addresses** when accessing the Internet.

## Why IPv6 Didn't Replace IPv4 Quickly

During the early 2000s, many experts predicted that IPv6 would replace IPv4 within a few years.

In reality, most organizations still primarily use:

```text
Private IPv4 + NAT
```

instead of fully migrating to IPv6.

## Why Companies Still Prefer IPv4 + NAT

Several practical reasons explain why IPv4 remains dominant.

### 1. Built-in Security

Private IP addresses **cannot be routed over the Internet**.

If a router on the Internet receives traffic destined for:

```text
10.x.x.x
172.16.x.x – 172.31.x.x
192.168.x.x
```

the packet is discarded.

This means internal devices are naturally hidden from the public Internet.

### 2. Easier Migration

IPv6 is **not backward compatible** with IPv4.

Existing networks already have:

- IPv4 addressing plans
- Routing
- Firewalls
- Applications
- Monitoring systems

Migrating requires significant effort, cost, and planning.

Many organizations therefore continue using IPv4 because:

> "If it isn't broken, don't fix it."

### 3. Engineers Already Know IPv4

Most network engineers have years of experience with IPv4.

Although IPv6 is becoming more common, many enterprise environments still rely almost entirely on IPv4.

## Where IPv6 Is Common Today

Although enterprises still heavily use IPv4, IPv6 is widely deployed in several environments.

Examples include:

- Internet Service Providers (ISPs)
- Mobile carrier networks
- Large countries with later Internet adoption
  - India
  - China

Most service providers now support:

```text
IPv4
+
IPv6
(Dual Stack)
```

## IPv4 Public Addresses Were Exhausted

Public IPv4 addresses officially ran out in:

```text
2011
```

This does **not** mean IPv4 stopped working.

Instead, organizations continue extending IPv4 using:

- Private Addressing
- NAT
- Careful subnet planning

IPv6 remains the long-term solution.

## Subnetting Is Still Important

Using private addresses does **not** eliminate subnetting.

Subnetting is still required for:

- Organizing networks
- Separating departments
- Routing between networks
- Troubleshooting
- Security segmentation

## Common Subnet Sizes in Enterprise Networks

Because private address space is abundant, companies often choose **simple subnet designs** instead of maximizing every address.

| Purpose | Common Subnet |
| ---------- | --------------- |
| User LAN | `/24` |
| Point-to-Point Link | `/30` |
| Loopback Interface | `/32` |

Using `/24` simplifies:

- IP planning
- Troubleshooting
- Documentation
- Configuration

## Why /24 Is So Popular

A `/24` network is extremely easy to recognize.

Example:

```text
192.168.10.0/24
```

Immediately tells us:

```text
Network:
192.168.10

Hosts:
Last Octet
```

No complex calculations are required.

Compared to VLSM:

```text
/27
/28
/29
```

a `/24` greatly reduces configuration mistakes.

## When Is Complex VLSM Used?

Variable Length Subnet Masking (VLSM) is mainly used when address conservation is important.

Typical scenario:

- Public IPv4 allocations
- Limited address space
- Service Provider environments

Goal:

```text
Use every available IP efficiently.
```

With private addressing, organizations rarely need such optimization.

## Route Summarization Still Matters

Even with private addresses, **route summarization** remains an important design principle.

Good addressing allows routers to advertise **one summary route** instead of hundreds of individual routes.

## Good Address Planning (Contiguous Networks)

Example:

### Region A

```text
10.0.0.0/24
10.0.1.0/24
...
10.0.255.0/24
```

### Region B

```text
10.1.0.0/24
10.1.1.0/24
...
10.1.255.0/24
```

Summary advertisements:

```text
Region A
↓
10.0.0.0/16
```

```text
Region B
↓
10.1.0.0/16
```

Benefits:

- Smaller routing tables
- Faster routing decisions
- Less memory usage
- Easier troubleshooting
- Better scalability

## Poor Address Planning (Non-Contiguous)

Example:

### Region A

```text
10.0.0.0/24
10.1.0.0/24
10.0.2.0/24
10.1.3.0/24
```

### Region B

```text
10.1.1.0/24
10.0.1.0/24
...
```

Problem:

```text
10.0.x.x
exists on BOTH sides
```

As a result:

- Route summarization is impossible.
- Every subnet must be advertised individually.

Consequences:

- Larger routing tables
- Higher memory usage
- More CPU utilization
- More complex troubleshooting
- Reduced network stability

## Best Practices for Enterprise Address Planning

When designing an enterprise network:

- Allocate address blocks sequentially.
- Keep regions in contiguous ranges.
- Leave room for future expansion.
- Use route summarization whenever possible.
- Prefer simple subnetting (`/24`) unless address conservation is required.

## Comparison

| Feature | Private IPv4 + NAT | IPv6 |
| ---------- | ------------------- | ------- |
| Widely used today | ✅ Yes | Growing |
| Conserves public IPv4 | ✅ Yes | Not required |
| Easy for existing networks | ✅ Yes | Migration required |
| Native Internet addressing | ❌ No | ✅ Yes |
| Long-term solution | ❌ Temporary | ✅ Yes |

## My Takeaways

- Most enterprise networks still use **RFC 1918 private IPv4 addresses with NAT**.
- Private IP addresses provide **address conservation** and **basic security** because they are not Internet-routable.
- IPv6 is the long-term replacement for IPv4 but has seen slower adoption due to migration complexity.
- Subnetting remains essential for network organization, routing, and troubleshooting.
- Enterprises commonly use **/24 for LANs**, **/30 for point-to-point links**, and **/32 for loopback interfaces**.
- Route summarization improves scalability and depends on **contiguous IP address planning**.
- Poor address planning prevents summarization and increases routing complexity.
