# OSI Layer 2 — Switch Operation & MAC Address Learning

## Table of Contents

- [OSI Layer 2 — Switch Operation \& MAC Address Learning](#osi-layer-2--switch-operation--mac-address-learning)
  - [Table of Contents](#table-of-contents)
  - [Overview](#overview)
  - [MAC Address Table (CAM Table)](#mac-address-table-cam-table)
  - [MAC Learning Process](#mac-learning-process)
  - [Single Switch Example](#single-switch-example)
    - [Initial State](#initial-state)
    - [Step 1 — Host A Sends a Frame](#step-1--host-a-sends-a-frame)
    - [Step 2 — Destination Unknown](#step-2--destination-unknown)
    - [Step 3 — Host B Replies](#step-3--host-b-replies)
  - [Multi-Switch Example](#multi-switch-example)
    - [Initial State](#initial-state-1)
    - [Step 1 — Host A Sends to Host B](#step-1--host-a-sends-to-host-b)
      - [Switch 1](#switch-1)
      - [Switch 2](#switch-2)
    - [Step 2 — Host B Replies](#step-2--host-b-replies)
    - [Step 3 — Host C Sends to Host B](#step-3--host-c-sends-to-host-b)
      - [Switch 2](#switch-2-1)
      - [Switch 1](#switch-1-1)
    - [Step 4 — Host B Replies](#step-4--host-b-replies)
  - [Multiple MAC Addresses on One Port](#multiple-mac-addresses-on-one-port)
  - [Unknown Unicast Forwarding](#unknown-unicast-forwarding)
  - [Known Unicast Forwarding](#known-unicast-forwarding)
  - [Switch Learning Summary](#switch-learning-summary)
  - [My Takeaways](#my-takeaways)

## Overview

A **Layer 2 switch** learns the location of devices by examining the **Source MAC Address** of every incoming Ethernet frame.

This information is stored in the **MAC Address Table (CAM Table)**, allowing the switch to forward future frames only to the correct destination port instead of flooding them across the network.

Initially, when a switch has just powered on, its MAC Address Table is **empty**. As devices communicate, the table is gradually populated through a process known as **MAC Address Learning**.

## MAC Address Table (CAM Table)

The MAC Address Table stores a mapping between a device's MAC address and the switch port where that device can be reached.

Example:

| MAC Address | Port |
| ------------- | ------ |
| 1111.1111.1111 | Fa0/1 |
| 2222.2222.2222 | Fa0/2 |
| 3333.3333.3333 | Fa0/3 |

This enables the switch to forward frames efficiently without sending them to every port.

## MAC Learning Process

Whenever a frame enters a switch, the switch performs two actions:

1. Learn the **Source MAC Address**
2. Forward the frame based on the **Destination MAC Address**

```text
Incoming Frame
      │
      ▼
Read Source MAC
      │
      ▼
Update MAC Address Table
      │
      ▼
Lookup Destination MAC
      │
      ├── Known → Forward to specific port
      │
      └── Unknown → Flood all ports (except incoming)
```

## Single Switch Example

### Initial State

The switch has just been powered on.

```text
        +-----------+
        |  Switch   |
        +-----------+
 Fa0/1      Fa0/2      Fa0/3
   │          │          │
 Host A     Host B     Host C
 1.1.1      2.2.2      3.3.3
```

MAC Address Table:

| MAC Address | Port |
| ------------- | ------ |
| *(Empty)* | |

### Step 1 — Host A Sends a Frame

Source:

```text
1.1.1
```

Destination:

```text
2.2.2
```

The switch performs:

- Learns Source MAC = **1.1.1**
- Associates it with **Port 1**

Updated MAC Table:

| MAC Address | Port |
| ------------- | ------ |
| 1.1.1 | Port 1 |

### Step 2 — Destination Unknown

The switch searches for:

```text
2.2.2
```

Since it is **not in the MAC Address Table**, it is considered an **Unknown Unicast**.

Action:

```text
Flood to every port
except the incoming port
```

```text
Port1  ← Incoming
Port2  ← Forward
Port3  ← Forward
```

Host B accepts the frame.

Host C silently discards it because the destination MAC does not match.

### Step 3 — Host B Replies

Host B sends:

Source:

```text
2.2.2
```

Destination:

```text
1.1.1
```

The switch learns:

| MAC Address | Port |
| ------------- | ------ |
| 1.1.1 | Port 1 |
| 2.2.2 | Port 2 |

Now the destination is known.

Action:

```text
Forward only to Port 1
```

Flooding is no longer necessary.

## Multi-Switch Example

Consider two interconnected switches.

```text
Host A ---- Switch1 ---- Switch2 ---- Host C
Host B                        Host D
```

The switches are connected using **Port 24**.

### Initial State

Both switches have empty MAC Address Tables.

---

### Step 1 — Host A Sends to Host B

Host A:

```text
Source = 1.1.1
Destination = 2.2.2
```

#### Switch 1

Learns:

| MAC | Port |
| ------ | ------ |
| 1.1.1 | Port 1 |

Destination unknown.

Floods:

- Port 2
- Port 24 (towards Switch 2)

#### Switch 2

Receives the frame.

Learns:

| MAC | Port |
| ------ | ------ |
| 1.1.1 | Port 24 |

Destination still unknown.

Floods to all local ports.

Hosts C and D discard the frame.

### Step 2 — Host B Replies

Host B sends:

```text
Source = 2.2.2
Destination = 1.1.1
```

Switch 1 learns:

| MAC | Port |
| ------ | ------ |
| 1.1.1 | Port 1 |
| 2.2.2 | Port 2 |

Since the destination is known, the frame is forwarded **only to Port 1**.

No traffic reaches Switch 2.

### Step 3 — Host C Sends to Host B

Host C sends:

```text
Source = 3.3.3
Destination = 2.2.2
```

#### Switch 2

Learns:

| MAC | Port |
| ------ | ------ |
| 1.1.1 | Port 24 |
| 3.3.3 | Port 1 |

Destination unknown.

Floods:

- Port 2
- Port 24

#### Switch 1

Receives the frame on Port 24.

Learns:

| MAC | Port |
| ------ | ------ |
| 1.1.1 | Port 1 |
| 2.2.2 | Port 2 |
| 3.3.3 | Port 24 |

Since Host B is already known, Switch 1 forwards the frame only to Port 2.

### Step 4 — Host B Replies

Host B sends:

```text
Source = 2.2.2
Destination = 3.3.3
```

Switch 1 already knows:

```text
3.3.3 → Port 24
```

The frame is forwarded only to Port 24.

Switch 2 receives the frame.

It learns:

| MAC | Port |
| ------ | ------ |
| 2.2.2 | Port 24 |
| 3.3.3 | Port 1 |
| 1.1.1 | Port 24 |

Finally, Switch 2 forwards the frame only to Port 1.

## Multiple MAC Addresses on One Port

When a switch connects directly to end devices:

```text
Port 1 → One PC
```

Only one MAC address is associated with that port.

However, when a switch connects to another switch:

```text
Switch ---- Switch
```

Many devices may exist behind the neighboring switch.

Example:

| MAC Address | Port |
| ------------- | ------ |
| 1.1.1 | Port 24 |
| 2.2.2 | Port 24 |
| 5.5.5 | Port 24 |
| 6.6.6 | Port 24 |

This is completely normal because **multiple hosts are reachable through the inter-switch link**.

## Unknown Unicast Forwarding

When the destination MAC Address is **not present** in the MAC Address Table:

```text
Destination Unknown
        │
        ▼
Flood Frame
```

The frame is sent to:

- Every switch port
- Except the incoming port

Once the destination responds, the switch learns its location.

## Known Unicast Forwarding

When the destination MAC Address **exists** in the MAC Address Table:

```text
Destination Found
        │
        ▼
Forward Only
to Correct Port
```

This greatly improves:

- Network efficiency
- Performance
- Security

## Switch Learning Summary

```text
Receive Frame
       │
       ▼
Learn Source MAC
       │
       ▼
Is Destination Known?
       │
 ┌─────┴─────┐
 │           │
Yes         No
 │           │
 ▼           ▼
Forward    Flood
to Port    All Ports
```

## My Takeaways

- A switch builds its **MAC Address Table** by learning the **Source MAC Address** of every incoming frame.
- Every learned MAC address is associated with the switch port where it was received.
- If the **Destination MAC Address is unknown**, the switch floods the frame to all ports except the incoming port.
- Once the destination replies, the switch learns its MAC address, allowing future traffic to be forwarded directly.
- In multi-switch environments, switches also learn MAC addresses that are reachable through **inter-switch links**.
- It is normal for a switch port connected to another switch to contain **multiple MAC addresses** in its MAC Address Table.
- Known unicast forwarding minimizes unnecessary traffic, improving network performance and security.
- MAC learning is a dynamic process that continuously updates as devices communicate across the network.
