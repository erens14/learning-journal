# Slash Notation

## Overview

CIDR (Classless Inter-Domain Routing) slash notation is a shorter and more convenient way to represent subnet masks. Instead of writing the full dotted decimal subnet mask, the number after the slash (`/`) indicates how many consecutive bits belong to the network portion.

## Key Concepts

### CIDR Slash Notation

A subnet mask can be written in two equivalent formats:

| Dotted Decimal | Slash Notation |
| -------------- | -------------- |
| 255.255.255.0  | /24            |
| 255.255.0.0    | /16            |
| 255.0.0.0      | /8             |

The value after the slash represents the number of contiguous `1`s in the subnet mask.

Example:

```text
255.255.255.0

11111111.11111111.11111111.00000000
<-----------24----------->

= /24
```

### Why Slash Notation?

CIDR notation is widely used because it is:

* Easier to read and write.
* Commonly used in network diagrams and documentation.
* More concise than dotted decimal notation.

For example:

```text
192.168.10.15/24
```

is equivalent to

```text
192.168.10.15
Subnet Mask: 255.255.255.0
```

### Determining the Network Address

The network address contains only the **network portion** of an IP address.

Example:

```text
Host Address : 10.10.10.15/8

Network Portion : 10
Host Portion    : 10.10.15

Network Address : 10.0.0.0/8
```

### Usable Host Range

For the network:

```text
10.0.0.0/8
```

| Address        | Purpose           |
| -------------- | ----------------- |
| 10.0.0.0       | Network Address   |
| 10.0.0.1       | First Usable Host |
| 10.255.255.254 | Last Usable Host  |
| 10.255.255.255 | Broadcast Address |

## My Takeaways

* CIDR slash notation is a simplified representation of subnet masks.
* The number after `/` indicates the number of network bits.
* Slash notation is commonly used in network documentation because it is concise and easier to read.
* The network address includes only the network portion of an IP address, while the remaining bits identify individual hosts.
* Understanding CIDR notation makes it easier to identify network boundaries and calculate usable host ranges.
