# Subnetting Overview

## Overview

This lesson introduces **subnetting**, one of the most fundamental concepts in networking. Subnetting divides a larger network into multiple smaller logical networks, making IP address allocation more efficient and improving network organization.

Originally, organizations could purchase a single public network and split it into multiple subnets instead of purchasing several separate address blocks.

## Key Concepts

### What is Subnetting?

Subnetting is the process of **borrowing bits from the host portion** of an IPv4 address and adding them to the network portion.

This creates multiple smaller subnets within a single network.

```text
Before Subnetting

| Network | Host Host Host Host Host Host |

After Subnetting

| Network Subnet | Host Host |
| Network Subnet | Host Host |
| Network Subnet | Host Host |
```

The subnet boundary always moves **to the right**.

### Trade-off of Subnetting

Moving the subnet boundary creates a trade-off:

- More borrowed bits → More subnets
- More borrowed bits → Fewer hosts per subnet

```text
More Subnet Bits
        ↓
More Networks
        ↓
Fewer Hosts per Network
```

### Calculating the Number of Subnets

Formula:

```text
Number of Subnets = 2^(Borrowed Bits)
```

Example:

Class C default mask:

```text
/24
```

Subnetted to:

```text
/28
```

Borrowed bits:

```text
28 − 24 = 4
```

Calculation:

```text
2^4 = 16 subnets
```

### Calculating the Number of Hosts

Formula:

```text
Number of Hosts = 2^(Host Bits) − 2
```

The subtraction of **2** accounts for:

- Network Address
- Broadcast Address

Example:

Subnet mask:

```text
/28
```

Remaining host bits:

```text
32 − 28 = 4
```

Calculation:

```text
2^4 = 16

16 − 2 = 14 usable hosts
```

This calculation is the same regardless of whether the original network is Class A, B, or C.

### Class Comparison

Using a **/28** subnet mask:

| Network Class | Default Mask | Borrowed Bits | Available Subnets | Usable Hosts/Subnet |
| -------------- | -------------- | --------------: | ------------------: | --------------------: |
| Class A | /8 | 20 | 1,048,576 | 14 |
| Class B | /16 | 12 | 4,096 | 14 |
| Class C | /24 | 4 | 16 | 14 |

The number of **subnets** depends on the original network class, while the number of **hosts per subnet** depends only on the subnet mask.

### Cisco `ip subnet-zero`

Older networking standards reserved subnet IDs where the borrowed subnet bits were all **0s** or all **1s**, reducing the available subnet count by two.

Modern Cisco devices enable the **`ip subnet-zero`** feature by default, allowing these subnet IDs to be used.

As a result:

- **Do not subtract 2 from the number of subnets** on modern Cisco networks or in the CCNA exam.
- **Always subtract 2 from the number of hosts**, since the Network Address and Broadcast Address remain reserved.

## My Takeaways

- Subnetting creates multiple logical networks by borrowing host bits.
- Borrowing more bits increases the number of subnets but decreases the number of hosts per subnet.
- Number of Subnets = **2^(Borrowed Bits)**.
- Number of Hosts = **2^(Host Bits) − 2**.
- Modern Cisco networks support subnet-zero, so all calculated subnets are usable.
