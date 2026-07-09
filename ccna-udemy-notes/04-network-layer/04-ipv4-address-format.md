# IPv4 Address Format

## Overview

IPv4 addresses are represented in **dotted decimal notation**, consisting of four decimal numbers separated by periods.

Each number is called an **octet**, and each octet contains **8 bits**, resulting in a total IPv4 address length of **32 bits**.

Example:

```text
192.168.10.15
```

| Octet 1 | Octet 2 | Octet 3 | Octet 4 |
| ------: | ------: | ------: | ------: |
|     192 |     168 |      10 |      15 |

## IPv4 Address Structure

Each IPv4 address consists of:

```text
8 bits   8 bits   8 bits   8 bits

[ Octet ][ Octet ][ Octet ][ Octet ]
```

Total:

```text
8 × 4 = 32 bits
```

Each octet can represent values from:

```text
0 - 255
```

because:

```text
11111111₂ = 255₁₀
```

## Binary Representation

Although humans write IP addresses in decimal form, computers process them in binary.

Example:

```text
Decimal

192.168.10.15
```

becomes

```text
Binary

11000000.10101000.00001010.00001111
```

Understanding this binary representation is essential for learning:

* Subnet Masks
* CIDR
* Subnetting
* Routing

## Finding Your IP Address

Different operating systems provide different commands to display network configuration.

| Platform  | Command                                                   |
| --------- | --------------------------------------------------------- |
| Windows   | `ipconfig`                                                |
| Linux     | `ifconfig` *(or `ip addr` on modern Linux distributions)* |
| Cisco IOS | `show ip interface brief`                                 |

Useful Cisco commands:

```bash
show ip interface brief
show interface
show ip interface
```

These commands display information such as:

* IP Address
* Interface Status
* Subnet Mask / Prefix Length

## Default Gateway

The **default gateway** is the router used when a device needs to communicate with a different network.

Simple example:

```text
PC
IP Address:
192.168.1.9

↓

Default Gateway
192.168.1.1

↓

Other Networks / Internet
```

Communication flow:

* Same subnet → communicate directly.
* Different subnet → send traffic to the default gateway.

## Static vs Dynamic IP Addressing

### Static Address

IP address is configured manually.

Commonly used for:

* Servers
* Routers
* Switches
* Firewalls
* Printers

Advantages:

* Predictable
* Never changes unless manually modified
* Easy to reference for infrastructure devices

### Dynamic Address (DHCP)

IP address is assigned automatically by a **DHCP (Dynamic Host Configuration Protocol)** server.

Commonly used for:

* Desktop computers
* Laptops
* Mobile devices

Advantages:

* Centralized management
* Easier deployment
* Reduces manual configuration
* Minimizes configuration errors

## Static vs DHCP

| Static IP                  | DHCP                   |
| -------------------------- | ---------------------- |
| Manually assigned          | Automatically assigned |
| Fixed address              | Address may change     |
| Infrastructure devices     | End-user devices       |
| Requires manual management | Managed centrally      |

## Key Concept

A device decides where to send traffic based on the destination IP address.

```text
Destination

Same Subnet
        │
        ▼
Send Directly

Different Subnet
        │
        ▼
Send to Default Gateway
```

This decision-making process is fundamental to how IP routing works.

## My Takeaways

* Every IPv4 address consists of **32 bits**, divided into four 8-bit octets.
* Although IPv4 addresses are written in decimal notation, computers interpret them in binary.
* The default gateway allows communication with devices located on different networks.
* Infrastructure devices typically use static IP addresses, while client devices commonly obtain addresses through DHCP.
* Understanding IPv4 formatting and binary representation is essential before learning subnet masks and subnetting.
