# IP Address Classes (Class D & Class E)

## Overview

This lesson introduces the remaining IPv4 address classes: **Class D** and **Class E**. Unlike Classes A, B, and C, these address classes are **not assigned to end hosts**. Instead, they are reserved for **multicast communication** and **experimental purposes**.

The lesson also explains how multicast differs from unicast and broadcast traffic, making network communication more efficient when delivering data to multiple recipients.

## Key Concepts

### Class D Addresses (Multicast)

Class D addresses are reserved for **multicast communication**, where a single sender transmits data to multiple interested receivers simultaneously.

Characteristics:

| Property | Value |
| ---------- | ------- |
| First bits | **1110** |
| Address range | **224.0.0.0 – 239.255.255.255** |
| Default subnet mask | **None** |
| Purpose | Multicast |

Unlike normal host addresses, Class D addresses identify a **multicast group**, not an individual device.

### Multicast vs Unicast

#### Unicast

One sender communicates with one destination.

```text
Sender ─────► Host A
Sender ─────► Host B
```

Each destination requires a separate transmission.

#### Multicast

One sender transmits a single stream to a multicast group.

```text
          ┌────► Host A
Sender ───┤
          └────► Host B
```

Only hosts that join the multicast group receive the traffic, making multicast far more bandwidth-efficient for applications such as video streaming.

### Multicast vs Broadcast

| Multicast | Broadcast |
| ----------- | ----------- |
| Sent only to subscribed hosts | Sent to every host on the local subnet |
| Can be forwarded by routers (when configured) | Not forwarded by routers by default |
| More bandwidth-efficient | Generates unnecessary traffic |

### Class E Addresses (Experimental)

Class E addresses are reserved for **experimental and future use**.

Characteristics:

| Property | Value |
| ---------- | ------- |
| First bits | **1111** |
| Address range | **240.0.0.0 – 255.255.255.255** |
| Default subnet mask | **None** |
| Purpose | Experimental |

These addresses are not used in normal production networks.

One special address in this range is:

- **255.255.255.255** → Limited Broadcast Address

This address broadcasts packets to **all hosts on the local network**.

## IPv4 Address Class Summary

| Class | First Octet | Default Mask | Purpose |
| ------ | ------------: | -------------- | --------- |
| A | 1 – 126 | /8 | Large networks |
| B | 128 – 191 | /16 | Medium networks |
| C | 192 – 223 | /24 | Small networks |
| D | 224 – 239 | None | Multicast |
| E | 240 – 255 | None | Experimental |

## My Takeaways

- Classes A, B, and C are used for assigning IPv4 addresses to hosts.
- Class D addresses are reserved for multicast communication.
- Multicast sends one stream to multiple subscribed receivers, reducing bandwidth usage.
- Broadcast sends traffic to every host on the local subnet, while multicast targets only interested hosts.
- Class E addresses are reserved for experimental purposes and are not used in production networks.
