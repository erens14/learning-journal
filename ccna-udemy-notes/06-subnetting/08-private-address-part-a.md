# Private IP Addresses (RFC 1918)

## Table of Contents

- [Private IP Addresses (RFC 1918)](#private-ip-addresses-rfc-1918)
  - [Table of Contents](#table-of-contents)
  - [Overview](#overview)
  - [Key Concepts](#key-concepts)
    - [What is RFC 1918?](#what-is-rfc-1918)
    - [Purpose of Private IP Addresses](#purpose-of-private-ip-addresses)
  - [RFC 1918 Private Address Ranges](#rfc-1918-private-address-ranges)
  - [Why Private Addresses Can Be Reused](#why-private-addresses-can-be-reused)
  - [Public vs Private Networks](#public-vs-private-networks)
  - [IPv4 Address Exhaustion](#ipv4-address-exhaustion)
  - [IPv6 as the Long-Term Solution](#ipv6-as-the-long-term-solution)
  - [Why IPv6 Was Not Adopted Immediately](#why-ipv6-was-not-adopted-immediately)
  - [Network Address Translation (NAT)](#network-address-translation-nat)
  - [NAT Address Sharing](#nat-address-sharing)
  - [Benefits of NAT](#benefits-of-nat)
  - [My Takeaways](#my-takeaways)

## Overview

This lesson introduces **Private IPv4 Addresses**, which are defined in **RFC 1918** by the Internet Engineering Task Force (IETF).

Originally, private IP addresses were created for devices that **should not be directly reachable from the Internet**. Today, they are also a fundamental component of **Network Address Translation (NAT)**, allowing organizations to conserve scarce public IPv4 addresses.

## Key Concepts

### What is RFC 1918?

RFC stands for **Request For Comments**, the document series published by the IETF that defines Internet standards.

The RFC that defines private IPv4 address ranges is:

```text
RFC 1918
```

Although RFC literally means "Request for Comments", once published it becomes an official Internet standard.

### Purpose of Private IP Addresses

Private IP addresses were originally designed for networks that **did not require Internet connectivity**.

Advantages include:

- No need to purchase public IP addresses
- Improved security because hosts are not directly reachable from the Internet
- Internal addressing can be freely managed by the organization

Example use cases:

- Bank internal secure network
- Internal servers
- Laboratory networks
- School computers without Internet access

## RFC 1918 Private Address Ranges

There are three private IPv4 ranges.

| Class | Private Range | CIDR | Default Mask |
| -------- | --------------- | ------ | -------------- |
| Class A | 10.0.0.0 – 10.255.255.255 | **10.0.0.0/8** | 255.0.0.0 |
| Class B | 172.16.0.0 – 172.31.255.255 | **172.16.0.0/12** | 255.240.0.0 |
| Class C | 192.168.0.0 – 192.168.255.255 | **192.168.0.0/16** | 255.255.0.0 |

> **Important:** Only these three ranges are private. Everything else is considered public unless reserved for another special purpose.

## Why Private Addresses Can Be Reused

Unlike public IP addresses, private addresses **do not exist on the public Internet**.

Therefore, multiple organizations can use exactly the same private network without conflict.

Example:

```text
Bank A
192.168.10.0/24

Bank B
192.168.10.0/24
```

This is perfectly valid because the two networks are isolated from each other.

## Public vs Private Networks

```text
Internet
        │
────────┼────────
        │
Public IP Address
        │
     Router
        │
-------------------------
Private Network (RFC1918)
192.168.x.x
10.x.x.x
172.16-31.x.x
```

Only the router communicates directly with the Internet.

## IPv4 Address Exhaustion

When IPv4 was created, designers believed **32-bit addressing (≈4.3 billion addresses)** would be sufficient.

However, the Internet grew much larger than expected.

Problems include:

- Only about 4.3 billion addresses available
- Inefficient early address allocation
- Large address blocks assigned to organizations that did not fully utilize them
- Special reserved ranges (such as 127.0.0.0/8) further reduced usable space

As a result, IPv4 public addresses eventually became exhausted.

## IPv6 as the Long-Term Solution

To solve IPv4 exhaustion, **IPv6** was developed.

Comparison:

| Feature | IPv4 | IPv6 |
| --------- | ------ | ------- |
| Address Length | 32 bits | 128 bits |
| Address Space | ~4.3 billion | ~7.9 × 10²⁸ times larger than IPv4 |

IPv6 provides an enormous address space that is effectively sufficient for future growth.

## Why IPv6 Was Not Adopted Immediately

Although IPv6 solves the address shortage, migration is difficult because:

- IPv4 and IPv6 use different address formats
- Existing networks already use IPv4
- Infrastructure must be upgraded
- Migration requires careful planning

Organizations cannot simply "flip a switch" to migrate.

## Network Address Translation (NAT)

Because IPv6 adoption has been gradual, **Network Address Translation (NAT)** was introduced as a temporary solution.

NAT allows:

- Internal devices to use private IP addresses
- A router to translate private addresses into public addresses when communicating with the Internet

```text
Private Host
192.168.10.15
        │
        │
   NAT Router
        │
175.11.0.5 (Public)
        │
     Internet
```

From the Internet's perspective, communication appears to come from the public IP address.

## NAT Address Sharing

One of NAT's biggest advantages is that **many internal hosts can share a single public IP address**.

Example:

```text
Office Network

Private Network:
192.168.10.0/24
200 Hosts
↓
NAT
↓
Public Network:
175.11.0.1/28
14 Public IP Addresses
```

Without NAT:

```text
200 Hosts
↓
Need 200 Public IP Addresses
```

With NAT:

```text
200 Hosts
↓
Share 14 Public IP Addresses
```

In many cases, even **one public IP address** is sufficient using modern NAT (PAT).

## Benefits of NAT

NAT provides several advantages:

- Conserves public IPv4 addresses
- Reduces the number of public IPs organizations must purchase
- Hides internal addressing from the Internet
- Allows flexible private addressing inside the organization

---

## My Takeaways

- **RFC 1918** defines the three private IPv4 address ranges.
- Private addresses are **not routable on the public Internet**.
- Multiple organizations may reuse the same private address ranges.
- IPv4 address exhaustion led to the development of **IPv6**.
- Because IPv6 migration is gradual, **NAT** became the practical solution.
- NAT translates private addresses into public addresses, allowing many hosts to share one or a few public IP addresses.
- NAT both **conserves IPv4 addresses** and **reduces operational costs**.
