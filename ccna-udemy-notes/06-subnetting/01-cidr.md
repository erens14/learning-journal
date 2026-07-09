# CIDR (Classless Inter-Domain Routing)

## Overview

This lesson introduces **CIDR (Classless Inter-Domain Routing)**, a method developed to improve IPv4 address allocation and routing efficiency.

Originally, organizations could only receive entire **Class A (/8)**, **Class B (/16)**, or **Class C (/24)** networks. This often resulted in significant address waste. CIDR removes these fixed class boundaries by allowing more flexible subnet sizes based on actual requirements.

## Key Concepts

### Why CIDR Was Introduced

Under the original classful addressing scheme:

- A company with fewer than **254 hosts** could use a **Class C (/24)**.
- A company with **255–65,534 hosts** had to receive an entire **Class B (/16)**.

Example:

```text
Company needs: 500 IP addresses

Without CIDR
Allocated: Class B (/16)

Available Hosts:
65,534

Unused:
≈65,000 addresses
```

This inefficient allocation contributed to IPv4 address exhaustion.

### What CIDR Changes

CIDR removes the requirement to allocate only fixed Class A, B, or C networks.

Instead, organizations receive an address block that closely matches their needs.

Example:

```text
Traditional Class B

175.10.0.0/16

CIDR Allocation

175.10.10.0/20
```

Instead of assigning an entire `/16`, only a `/20` is allocated, leaving the remaining addresses available for other organizations.

### Route Summarization

CIDR also introduces **route summarization (route aggregation)**.

Instead of advertising many individual routes, routers can advertise one summarized route.

Example:

Without summarization

```text
175.10.0.0/24
175.10.1.0/24
175.10.2.0/24
...
175.10.255.0/24
```

Total:

```text
256 individual routes
```

With summarization

```text
175.10.0.0/16
```

One summary route represents all 256 networks.

### Benefits of Route Summarization

- Smaller routing tables.
- Lower memory usage on routers.
- Faster route processing.
- Improved network scalability.
- Network failures are isolated, reducing the impact on other networks.

## My Takeaways

- CIDR replaces fixed Class A, B, and C allocation with flexible subnet sizes.
- Flexible allocation significantly reduces wasted IPv4 addresses.
- Route summarization combines multiple networks into a single advertised route.
- Smaller routing tables improve router performance and scalability.
- CIDR forms the foundation for subnetting and advanced IP address planning.
