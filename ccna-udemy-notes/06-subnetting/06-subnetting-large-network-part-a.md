# Subnetting Class A & Class B Networks

## Table of Contents

- [Subnetting Class A \& Class B Networks](#subnetting-class-a--class-b-networks)
  - [Table of Contents](#table-of-contents)
  - [Overview](#overview)
  - [Key Concepts](#key-concepts)
    - [Subnetting a Class B Network](#subnetting-a-class-b-network)
    - [Step 1 — Calculate Host Bits](#step-1--calculate-host-bits)
    - [Step 2 — Calculate Usable Hosts](#step-2--calculate-usable-hosts)
    - [Step 3 — Calculate Borrowed Bits](#step-3--calculate-borrowed-bits)
    - [Step 4 — Calculate Number of Subnets](#step-4--calculate-number-of-subnets)
  - [Finding Network Information (/29 Example)](#finding-network-information-29-example)
    - [Step 1 — Determine Block Size](#step-1--determine-block-size)
    - [Step 2 — Find Network Address](#step-2--find-network-address)
    - [Step 3 — Find Broadcast Address](#step-3--find-broadcast-address)
    - [Step 4 — Find Valid Hosts](#step-4--find-valid-hosts)
    - [Final Result](#final-result)
  - [Magic Number Method](#magic-number-method)
    - [Formula](#formula)
  - [Subnetting a Class A Network](#subnetting-a-class-a-network)
    - [Step 1 — Calculate Host Bits](#step-1--calculate-host-bits-1)
    - [Step 2 — Calculate Hosts](#step-2--calculate-hosts)
    - [Step 3 — Calculate Borrowed Bits](#step-3--calculate-borrowed-bits-1)
    - [Step 4 — Calculate Subnets](#step-4--calculate-subnets)
  - [Finding Network Information (/28 Example)](#finding-network-information-28-example)
    - [Step 1 — Determine Block Size](#step-1--determine-block-size-1)
    - [Step 2 — Network Address](#step-2--network-address)
    - [Step 3 — Broadcast Address](#step-3--broadcast-address)
    - [Step 4 — Valid Hosts](#step-4--valid-hosts)
    - [Final Result](#final-result-1)
  - [Magic Number Method (/28)](#magic-number-method-28)
  - [My Takeaways](#my-takeaways)

## Overview

Subnetting does not only apply to **Class C** networks. The same subnetting principles also apply to **Class A** and **Class B** networks.

The main difference is:

- The number of **borrowed bits** depends on the default subnet mask of the original class.
- The number of **usable hosts** depends **only on the subnet mask**, regardless of the original network class.

This lesson also introduces the **Magic Number Method**, a faster technique for calculating subnet ranges.

## Key Concepts

### Subnetting a Class B Network

Example network:

```text
135.15.0.0/16
```

Subnet mask:

```text
/29
```

### Step 1 — Calculate Host Bits

IPv4 contains 32 bits.

```text
Host Bits = 32 − 29
          = 3
```

### Step 2 — Calculate Usable Hosts

Formula:

```text
2^(Host Bits) − 2
```

Calculation:

```text
2³ = 8

8 − 2 = 6 usable hosts
```

### Step 3 — Calculate Borrowed Bits

Default Class B mask:

```text
/16
```

Borrowed bits:

```text
29 − 16 = 13
```

### Step 4 — Calculate Number of Subnets

```text
2¹³

2
4
8
16
32
64
128
256
512
1024
2048
4096
8192
```

Result:

```text
8192 subnets
```

## Finding Network Information (/29 Example)

Given:

```text
IP Address

135.15.10.138/29
```

### Step 1 — Determine Block Size

A /29 mask means the subnet boundary is after:

```text
128 64 32 16 8 | 4 2 1
```

The block size is:

```text
8
```

Meaning network addresses increase by:

```text
136
144
152
160
...
```

### Step 2 — Find Network Address

138 belongs to the block:

```text
136–143
```

Therefore:

```text
Network Address

135.15.10.136
```

### Step 3 — Find Broadcast Address

Next network:

```text
135.15.10.144
```

Broadcast is one address before:

```text
135.15.10.143
```

### Step 4 — Find Valid Hosts

```text
135.15.10.137

↓

135.15.10.142
```

### Final Result

| Item | Address |
| ------ | --------- |
| Network | 135.15.10.136 |
| First Host | 135.15.10.137 |
| Last Host | 135.15.10.142 |
| Broadcast | 135.15.10.143 |

## Magic Number Method

The Magic Number Method provides a faster way to determine subnet ranges.

### Formula

```text
Magic Number
256 − Subnet Octet
```

Example:

```text
/29
255.255.255.248
```

Subnet octet:

```text
248
```

Calculation:

```text
256 − 248 = 8
```

Meaning every subnet starts every:

```text
0
8
16
24
32
40
...
136
144
152
...
```

Since:

```text
138
```

falls between:

```text
136 and 144
```

We obtain:

```text
Network = 136

Broadcast = 143
```

This method is especially useful when the subnet mask is provided in **dotted decimal notation**.

## Subnetting a Class A Network

Example network:

```text
60.0.0.0/8
```

Subnet mask:

```text
255.255.255.240
```

First convert:

```text
255.255.255.240 = /28
```

### Step 1 — Calculate Host Bits

```text
32 − 28 = 4
```

### Step 2 — Calculate Hosts

```text
2⁴ = 16

16 − 2 = 14 usable hosts
```

### Step 3 — Calculate Borrowed Bits

Default Class A:

```text
/8
```

Borrowed bits:

```text
28 − 8 = 20
```

### Step 4 — Calculate Subnets

```text
2²⁰ = 1,048,576 subnets
```

Although very large, the calculation still follows the same formula.

## Finding Network Information (/28 Example)

Given:

```text
60.15.10.75/28
```

### Step 1 — Determine Block Size

A /28 mask means subnet increments of:

```text
16
```

Possible network addresses:

```text
0
16
32
48
64
80
96
...
```

75 belongs to:

```text
64 – 79
```

### Step 2 — Network Address

```text
60.15.10.64
```

### Step 3 — Broadcast Address

Next subnet:

```text
60.15.10.80
```

Broadcast:

```text
60.15.10.79
```

### Step 4 — Valid Hosts

```text
60.15.10.65
↓
60.15.10.78
```

### Final Result

| Item | Address |
| ------ | --------- |
| Network | 60.15.10.64 |
| First Host | 60.15.10.65 |
| Last Host | 60.15.10.78 |
| Broadcast | 60.15.10.79 |

## Magic Number Method (/28)

Subnet mask:

```text
255.255.255.240
```

Magic Number:

```text
256 − 240 = 16
```

Network blocks:

```text
0
16
32
48
64
80
96
...
```

Given:

```text
60.15.10.75
```

The address falls between:

```text
64 and 80
```

Therefore:

```text
Network
60.15.10.64

Broadcast
60.15.10.79

Hosts
60.15.10.65 – 60.15.10.78
```

## My Takeaways

- The subnetting process is identical for Class A, B, and C networks.
- The number of **usable hosts** depends only on the subnet mask.
- The number of **available subnets** depends on how many bits are borrowed from the default class mask.
- The **Magic Number Method** provides a fast way to calculate subnet boundaries.
- Network Address = beginning of the block.
- Broadcast Address = one address before the next block.
- Valid host addresses are always between the Network Address and Broadcast Address.
