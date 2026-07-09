# Variable Length Subnet Masking (VLSM) Design — Part A

## Table of Contents

- [Variable Length Subnet Masking (VLSM) Design — Part A](#variable-length-subnet-masking-vlsm-design--part-a)
  - [Table of Contents](#table-of-contents)
  - [Overview](#overview)
  - [Key Concepts](#key-concepts)
    - [What is VLSM?](#what-is-vlsm)
    - [Why Use VLSM?](#why-use-vlsm)
    - [VLSM Design Process](#vlsm-design-process)
    - [Real-World Design Considerations](#real-world-design-considerations)
    - [Exam vs Real World](#exam-vs-real-world)
  - [Example VLSM Design](#example-vlsm-design)
    - [Network Topology](#network-topology)
    - [Step 1 — Sort by Largest Network](#step-1--sort-by-largest-network)
    - [Step 2 — Determine Required Subnet Mask](#step-2--determine-required-subnet-mask)
    - [Step 3 — Allocate First Engineering Subnet](#step-3--allocate-first-engineering-subnet)
    - [Step 4 — Allocate Second Engineering Subnet](#step-4--allocate-second-engineering-subnet)
    - [Allocation Summary (Current Progress)](#allocation-summary-current-progress)
  - [My Takeaways](#my-takeaways)

## Overview

This lesson introduces the practical implementation of **Variable Length Subnet Masking (VLSM)**. Unlike Fixed Length Subnet Masking (FLSM), VLSM allows different subnet sizes within the same network, resulting in much more efficient IP address utilization.

The lesson also demonstrates a step-by-step subnet design process based on real-world requirements, where each department receives a subnet sized according to its actual number of hosts.

## Key Concepts

### What is VLSM?

Variable Length Subnet Masking (VLSM) allows different subnet masks to exist within the same parent network.

Instead of assigning every subnet the same size, each subnet can be customized according to its host requirements.

```text
FLSM (Fixed)

200.15.10.0/24
├── /27
├── /27
├── /27
└── /27

All subnets have the same size.
```

```text
VLSM (Variable)

200.15.10.0/24
├── /27
├── /28
├── /29
└── /30

Subnet sizes are adjusted based on requirements.
```

### Why Use VLSM?

Benefits of VLSM include:

- More efficient IP address allocation
- Less wasted address space
- Better scalability
- Flexible network design
- Different departments can receive subnet sizes appropriate for their needs

### VLSM Design Process

A common VLSM design follows these steps:

```text
1. List all required subnets
            ↓
2. Sort by largest host requirement
            ↓
3. Allocate the largest subnet first
            ↓
4. Continue allocating remaining address space
            ↓
5. Repeat until all subnets are assigned
```

This approach minimizes fragmentation and simplifies future expansion.

### Real-World Design Considerations

When designing a subnetting scheme, consider:

- Number of locations
- Number of departments
- Number of hosts in each subnet
- Future growth
- Security requirements
- Efficient address utilization

Example:

```text
Accounting
↓
Separate subnet
↓
Traffic can be controlled using Layer 3 routing
```

Different departments can be isolated using routers or Layer 3 switches, improving security and access control.

### Exam vs Real World

In production environments:

- Leave room for future growth.
- Reserve extra address space.
- Avoid allocating subnets that are exactly full.

Example:

```text
Current Hosts = 28

Real World
↓
Allocate /26
(62 Hosts)

Future growth is supported.
```

For the CCNA exam:

```text
Always follow the question.

If it says:
"Use the smallest subnet possible"
↓
Do NOT leave extra space.

Choose the smallest subnet that satisfies the requirement.
```

## Example VLSM Design

### Network Topology

Available network:

```text
200.15.10.0/24
```

Requirements:

| Department | Hosts |
| ------------ | ------: |
| New York Engineering | 28 |
| Boston Engineering | 28 |
| New York Sales | 14 |
| Boston Sales | 7 |
| Router Link | 2 |

### Step 1 — Sort by Largest Network

Arrange subnets from largest to smallest.

```text
28 Hosts
28 Hosts
14 Hosts
7 Hosts
2 Hosts
```

Always allocate the largest subnet first.

### Step 2 — Determine Required Subnet Mask

Engineering requires:

```text
28 Hosts
```

Known subnet sizes:

| Prefix | Usable Hosts |
| --------- | -------------: |
| /28 | 14 |
| /27 | 30 |
| /26 | 62 |

Calculation:

```text
28 Hosts
↓
/28
Not enough
↓
/27
30 Hosts
✓ Correct
```

Subnet mask:

```text
/27
255.255.255.224
```

### Step 3 — Allocate First Engineering Subnet

Available network:

```text
200.15.10.0/24
```

Using:

```text
/27
```

Subnet increment:

```text
256 − 224 = 32
```

Network addresses increase by:

```text
0
32
64
96
128
160
192
224
```

First subnet:

| Item | Address |
| ------ | --------- |
| Network | 200.15.10.0 |
| First Host | 200.15.10.1 |
| Last Host | 200.15.10.30 |
| Broadcast | 200.15.10.31 |

### Step 4 — Allocate Second Engineering Subnet

Next network starts at:

```text
200.15.10.32
```

Next increment:

```text
64
```

Therefore:

```text
Network
200.15.10.32
↓
Broadcast
200.15.10.63
```

Host range:

| Item | Address |
| ------ | --------- |
| Network | 200.15.10.32 |
| First Host | 200.15.10.33 |
| Last Host | 200.15.10.62 |
| Broadcast | 200.15.10.63 |

### Allocation Summary (Current Progress)

| Department | Network | Prefix | Host Range |
| ------------ | --------- | -------: | ------------ |
| NY Engineering | 200.15.10.0 | /27 | 200.15.10.1 – 200.15.10.30 |
| Boston Engineering | 200.15.10.32 | /27 | 200.15.10.33 – 200.15.10.62 |

The remaining departments (Sales and Router Link) will be allocated from the remaining address space in the next design step.

## My Takeaways

- VLSM allows different subnet sizes within the same network.
- Always allocate the largest subnet first.
- Sort subnet requirements from largest to smallest before designing.
- In real-world networks, leave room for future growth whenever possible.
- For the CCNA exam, always follow the question requirements exactly, even if they differ from production best practices.
- A **/27** subnet supports **30 usable hosts**, making it the smallest suitable subnet for a department requiring **28 hosts**.
