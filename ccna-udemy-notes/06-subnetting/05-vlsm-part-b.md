# Variable Length Subnet Mask (VLSM) Design - Part 2

## Table of Contents

- [Variable Length Subnet Mask (VLSM) Design - Part 2](#variable-length-subnet-mask-vlsm-design---part-2)
  - [Table of Contents](#table-of-contents)
  - [Overview](#overview)
  - [Initial Allocation (Recap)](#initial-allocation-recap)
  - [New York Sales](#new-york-sales)
    - [Requirements](#requirements)
    - [Step 1 — Determine the Subnet Mask](#step-1--determine-the-subnet-mask)
    - [Step 2 — Determine Network Address](#step-2--determine-network-address)
    - [Step 3 — Determine Block Size](#step-3--determine-block-size)
    - [Step 4 — Determine Broadcast Address](#step-4--determine-broadcast-address)
    - [Step 5 — Determine Host Range](#step-5--determine-host-range)
    - [Summary](#summary)
  - [Boston Sales](#boston-sales)
    - [Requirements](#requirements-1)
    - [Step 1 — Determine the Subnet Mask](#step-1--determine-the-subnet-mask-1)
    - [Step 2 — Determine Network Address](#step-2--determine-network-address-1)
    - [Step 3 — Determine Block Size](#step-3--determine-block-size-1)
    - [Step 4 — Determine Broadcast Address](#step-4--determine-broadcast-address-1)
    - [Step 5 — Determine Host Range](#step-5--determine-host-range-1)
    - [Summary](#summary-1)
  - [Point-to-Point Link](#point-to-point-link)
    - [Requirements](#requirements-2)
    - [Choosing /30 vs /31](#choosing-30-vs-31)
    - [Step 1 — Determine Subnet Mask](#step-1--determine-subnet-mask)
    - [Step 2 — Determine Network Address](#step-2--determine-network-address-2)
    - [Step 3 — Determine Block Size](#step-3--determine-block-size-2)
    - [Step 4 — Determine Broadcast Address](#step-4--determine-broadcast-address-2)
    - [Step 5 — Determine Host Range](#step-5--determine-host-range-2)
    - [Summary](#summary-2)
  - [Final VLSM Allocation](#final-vlsm-allocation)
  - [Router Interface Assignment](#router-interface-assignment)
  - [VLSM Design Workflow](#vlsm-design-workflow)
  - [My Takeaways](#my-takeaways)

## Overview

This lesson continues the VLSM design process by allocating IP addresses for the remaining network segments. The subnet allocation always starts from the **largest subnet requirement** and continues sequentially toward the **smallest**, ensuring efficient use of the available address space.

At the end of the design, every department and point-to-point link has its own subnet without wasting unnecessary IP addresses.

## Initial Allocation (Recap)

Allocated Network:

```text
200.15.10.0/24
```

Already allocated:

| Department | Subnet |
| ------------ | -------- |
| New York Engineering | 200.15.10.0/27 |
| Boston Engineering | 200.15.10.32/27 |

Remaining address space begins at:

```text
200.15.10.64
```

## New York Sales

### Requirements

Hosts required:

```text
14 Hosts
```

### Step 1 — Determine the Subnet Mask

Need to support 14 hosts.

Try `/29`

Host bits:

```text
32 - 29 = 3 bits
```

Hosts:

```text
2³ = 8
8 - 2 = 6 Hosts
```

Not enough.

Try `/28`

Host bits:

```text
32 - 28 = 4 bits
```

Hosts:

```text
2⁴ = 16
16 - 2 = 14 Hosts
```

Exactly enough.

Chosen subnet:

```text
/28
```

Subnet Mask:

```text
255.255.255.240
```

### Step 2 — Determine Network Address

Previous subnet ended at

```text
Broadcast:
200.15.10.63
```

Therefore the next available network is

```text
200.15.10.64/28
```

### Step 3 — Determine Block Size

Subnet mask:

```text
/28
```

Interesting octet:

```text
240
```

Block size:

```text
256 - 240 = 16
```

Subnet increments:

```text
64
80
96
112
...
```

Next subnet:

```text
200.15.10.80
```

### Step 4 — Determine Broadcast Address

Broadcast is one address before the next subnet.

```text
Next subnet:
200.15.10.80

Broadcast:
200.15.10.79
```

### Step 5 — Determine Host Range

```text
Network:
200.15.10.64

Broadcast:
200.15.10.79

Hosts:
200.15.10.65
↓

200.15.10.78
```

### Summary

| Item | Value |
| ------ | ------- |
| Network | 200.15.10.64/28 |
| Broadcast | 200.15.10.79 |
| Host Range | 200.15.10.65 - 200.15.10.78 |
| Usable Hosts | 14 |

## Boston Sales

### Requirements

Hosts required:

```text
7 Hosts
```

### Step 1 — Determine the Subnet Mask

A common mistake is choosing `/29`.

Let's verify.

Host bits:

```text
32 - 29 = 3
```

Hosts:

```text
2³ = 8
8 - 2 = 6 Hosts
```

Not enough.

Need:

```text
7 Hosts
```

Therefore use

```text
/28
```

Hosts:

```text
2⁴ = 16
16 - 2 = 14 Hosts
```

Chosen subnet:

```text
/28
```

### Step 2 — Determine Network Address

Previous subnet ended at

```text
Broadcast:
200.15.10.79
```

Next available subnet:

```text
200.15.10.80/28
```

### Step 3 — Determine Block Size

Subnet mask:

```text
255.255.255.240
```

Block size:

```text
256 - 240 = 16
```

Subnet sequence:

```text
80
96
112
...
```

Next subnet:

```text
200.15.10.96
```

### Step 4 — Determine Broadcast Address

```text
Next subnet:
200.15.10.96

Broadcast:
200.15.10.95
```

### Step 5 — Determine Host Range

```text
Network:
200.15.10.80

Broadcast:
200.15.10.95

Hosts:
200.15.10.81
↓

200.15.10.94
```

### Summary

| Item | Value |
|------|-------|
| Network | 200.15.10.80/28 |
| Broadcast | 200.15.10.95 |
| Host Range | 200.15.10.81 - 200.15.10.94 |
| Usable Hosts | 14 |

## Point-to-Point Link

### Requirements

Hosts required:

```text
2 Hosts
```

### Choosing /30 vs /31

Both subnet masks can support two devices.

| Mask | Hosts | Typical Usage |
|------|-------|---------------|
| /31 | 2 | Cisco point-to-point links |
| /30 | 2 | Standard CCNA answer |

For the CCNA exam:

> Unless the question explicitly requests `/31`, always choose `/30`.

### Step 1 — Determine Subnet Mask

Chosen subnet:

```text
/30
```

Subnet mask:

```text
255.255.255.252
```

### Step 2 — Determine Network Address

Previous subnet ended at

```text
Broadcast:
200.15.10.95
```

Next subnet:

```text
200.15.10.96/30
```

### Step 3 — Determine Block Size

Subnet mask:

```text
255.255.255.252
```

Block size:

```text
256 - 252 = 4
```

Subnet sequence:

```text
96
100
104
108
...
```

Next subnet:

```text
200.15.10.100
```

### Step 4 — Determine Broadcast Address

```text
Next subnet:
200.15.10.100

Broadcast:
200.15.10.99
```

### Step 5 — Determine Host Range

```text
Network:
200.15.10.96

Broadcast:
200.15.10.99

Hosts:

200.15.10.97
200.15.10.98
```

### Summary

| Item | Value |
| ------ | ------- |
| Network | 200.15.10.96/30 |
| Broadcast | 200.15.10.99 |
| Host Range | 200.15.10.97 - 200.15.10.98 |
| Usable Hosts | 2 |

## Final VLSM Allocation

| Network Segment | Subnet | Host Range | Broadcast |
| ---------------- | -------- | ------------ | ------------ |
| New York Engineering | 200.15.10.0/27 | 200.15.10.1 - 200.15.10.30 | 200.15.10.31 |
| Boston Engineering | 200.15.10.32/27 | 200.15.10.33 - 200.15.10.62 | 200.15.10.63 |
| New York Sales | 200.15.10.64/28 | 200.15.10.65 - 200.15.10.78 | 200.15.10.79 |
| Boston Sales | 200.15.10.80/28 | 200.15.10.81 - 200.15.10.94 | 200.15.10.95 |
| Router Link | 200.15.10.96/30 | 200.15.10.97 - 200.15.10.98 | 200.15.10.99 |

## Router Interface Assignment

A common design practice is assigning the **first usable IP address** to router interfaces.

| Interface | IP Address |
| ----------- | ------------ |
| New York Engineering Router | 200.15.10.1 |
| Boston Engineering Router | 200.15.10.33 |
| New York Sales Router | 200.15.10.65 |
| Boston Sales Router | 200.15.10.81 |
| New York Router (WAN) | 200.15.10.97 |
| Boston Router (WAN) | 200.15.10.98 |

## VLSM Design Workflow

```text
1. List every network segment.
2. Count required hosts.
3. Sort from largest subnet to smallest.
4. Choose the smallest subnet that fits each segment.
5. Allocate subnets sequentially.
6. Calculate:
   - Network Address
   - Broadcast Address
   - Host Range
7. Assign router interfaces (commonly the first usable IP).
```

## My Takeaways

- Always allocate **largest subnets first**.
- Allocate IP addresses **sequentially** to avoid fragmentation.
- Choose the **smallest subnet** that satisfies the host requirement.
- Remember to reserve IP addresses for **point-to-point links** and infrastructure devices.
- `/30` is the default choice for point-to-point links in CCNA unless `/31` is explicitly requested.
- Router interfaces are commonly assigned the **first usable host address** of each subnet.
- VLSM minimizes wasted IP addresses while maintaining an organized and scalable addressing scheme.
