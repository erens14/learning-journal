# Subnetting on the 3rd Octet

## Table of Contents
- [Subnetting on the 3rd Octet](#subnetting-on-the-3rd-octet)
  - [Table of Contents](#table-of-contents)
  - [Overview](#overview)
  - [Key Concepts](#key-concepts)
    - [Subnetting a Class A Network on the 3rd Octet](#subnetting-a-class-a-network-on-the-3rd-octet)
    - [Step 1 — Calculate Host Bits](#step-1--calculate-host-bits)
    - [Step 2 — Calculate Usable Hosts](#step-2--calculate-usable-hosts)
    - [Step 3 — Calculate Borrowed Bits](#step-3--calculate-borrowed-bits)
    - [Step 4 — Calculate Number of Subnets](#step-4--calculate-number-of-subnets)
  - [Finding Network Information (/19 Example)](#finding-network-information-19-example)
    - [Step 1 — Determine Block Size](#step-1--determine-block-size)
    - [Step 2 — Find Network Address](#step-2--find-network-address)
    - [Step 3 — Find Broadcast Address](#step-3--find-broadcast-address)
    - [Step 4 — Find Valid Hosts](#step-4--find-valid-hosts)
    - [Final Result](#final-result)
  - [Magic Number Method (/19)](#magic-number-method-19)
  - [Determining the Correct Subnet Mask](#determining-the-correct-subnet-mask)
    - [Step 1 — Determine Borrowed Bits](#step-1--determine-borrowed-bits)
    - [Step 2 — Add Borrowed Bits](#step-2--add-borrowed-bits)
    - [Step 3 — Additional Information](#step-3--additional-information)
  - [CCNA Exam Tips](#ccna-exam-tips)
    - [Type 1 — Design Questions](#type-1--design-questions)
    - [Type 2 — Calculation Questions](#type-2--calculation-questions)
  - [My Takeaways](#my-takeaways)

## Overview

Subnetting can occur on different octets depending on the subnet mask.

- **/24 to /32** → subnetting occurs on the **4th octet**.
- **/16 to /23** → subnetting occurs on the **3rd octet**.

Although the calculations remain the same, subnetting on the **3rd octet** often confuses beginners because the network increments occur in the third octet while the fourth octet spans the full host range.

This lesson also demonstrates how to determine an appropriate subnet mask based on the required number of networks.

## Key Concepts

### Subnetting a Class A Network on the 3rd Octet

Example network:

```text
60.0.0.0/8
```

Subnet mask:

```text
/19
```

### Step 1 — Calculate Host Bits

IPv4 contains 32 bits.

```text
Host Bits

32 − 19 = 13
```

### Step 2 — Calculate Usable Hosts

Formula:

```text
2^(Host Bits) − 2
```

Calculation:

```text
2¹³ = 8192

8192 − 2 = 8190 usable hosts
```

### Step 3 — Calculate Borrowed Bits

Default Class A mask:

```text
/8
```

Borrowed bits:

```text
19 − 8 = 11
```

### Step 4 — Calculate Number of Subnets

```text
2¹¹ = 2048 subnets
```

## Finding Network Information (/19 Example)

Given:

```text
IP Address
60.15.10.75/19
```

### Step 1 — Determine Block Size

Subnet mask:

```text
/19
```

The subnet boundary is after:

```text
128 64 32 | 16 8 4 2 1
```

The block size is:

```text
32
```

Unlike previous examples, the increment occurs on the **3rd octet**.

Possible network blocks:

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

The third octet is:

```text
10
```

Since:

```text
0 ≤ 10 < 32
```

The address belongs to the first subnet.

### Step 2 — Find Network Address

```text
Network Address

60.15.0.0
```

Notice:

- Third octet becomes **0**
- Fourth octet becomes **0**

### Step 3 — Find Broadcast Address

Next subnet starts at:

```text
60.15.32.0
```

Therefore:

```text
Broadcast Address
60.15.31.255
```

Notice:

- Third octet is one less than 32 → **31**
- Fourth octet becomes **255**

### Step 4 — Find Valid Hosts

```text
First Host
60.15.0.1
↓
Last Host
60.15.31.254
```

### Final Result

| Item | Address |
|------|---------|
| Network | 60.15.0.0 |
| First Host | 60.15.0.1 |
| Last Host | 60.15.31.254 |
| Broadcast | 60.15.31.255 |

## Magic Number Method (/19)

Convert:

```text
/19
↓
255.255.224.0
```

Magic Number:

```text
256 − 224 = 32
```

Network blocks on the **3rd octet**:

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

Given:

```text
60.15.10.75
```

Third octet:

```text
10
```

Falls between:

```text
0 and 32
```

Therefore:

```text
Network
60.15.0.0

Broadcast
60.15.31.255

Hosts
60.15.0.1 – 60.15.31.254
```

## Determining the Correct Subnet Mask

Sometimes the exam asks for the subnet mask instead of the network information.

Example:

```text
Network:
134.65.0.0

Requirement:
6 subnets
```

### Step 1 — Determine Borrowed Bits

Need at least:

```text
6 subnets
```

Using the formula:

```text
2^n ≥ Required Subnets
```

Calculation:

```text
2¹ = 2
❌ Not enough

2² = 4
❌ Not enough

2³ = 8
✅ Enough
```

Borrow:

```text
3 bits
```

### Step 2 — Add Borrowed Bits

Default Class B mask:

```text
/16
```

Borrow:

```text
3 bits
```

Result:

```text
16 + 3 = /19
```

Subnet mask:

```text
255.255.224.0
```

### Step 3 — Additional Information

Network block size:

```text
32
```

Network addresses:

```text
134.65.0.0
134.65.32.0
134.65.64.0
134.65.96.0
...
```

Hosts per subnet:

```text
Host Bits
32 − 19 = 13

2¹³ − 2 = 8190 hosts
```

## CCNA Exam Tips

Subnetting questions generally fall into two categories.

### Type 1 — Design Questions

Given:

- Required number of subnets
- Required number of hosts

Determine:

- Appropriate subnet mask
- Network addresses

### Type 2 — Calculation Questions

Given:

- IP address
- Subnet mask

Determine:

- Network Address
- Broadcast Address
- First Host
- Last Host

Mastering these two question types is enough to solve most subnetting questions on the CCNA exam.

## My Takeaways
- Subnetting on the **3rd octet** follows the same rules as subnetting on the 4th octet.
- The only difference is that subnet increments occur in the **3rd octet**.
- The **Magic Number Method** works on any octet being subnetted.
- To determine the required subnet mask:
  - Calculate the required borrowed bits using **2ⁿ ≥ required subnets**.
  - Add the borrowed bits to the default class mask.
- Most CCNA subnetting questions focus on:
  - Selecting the correct subnet mask.
  - Calculating the Network Address, Broadcast Address, and usable host range.