# Address Resolution Protocol (ARP)

## Overview

The Address Resolution Protocol (ARP) is a critical network protocol operating between Layer 2 (Data-Link) and Layer 3 (Network) of the OSI model. While application traffic and routing rely on logical IP addresses managed by administrators, data cannot be physically placed onto the wire without a physical hardware address (MAC address). ARP provides the mechanism to automatically discover and map a known destination IPv4 address to its corresponding, globally unique hardware MAC address.

## Key Concepts

### Logical vs. Physical Addressing

IP addresses are logical, hierarchical addresses easily configured or resolved via DNS. MAC addresses are flat, hardcoded physical identifiers on network interface cards (NICs). Because applications cannot pre-program dynamic destination MAC addresses, ARP bridges this gap dynamically.

### Layer 2 Broadcast (ARP Request)

When a sender knows the target IP but lacks the destination MAC, it sends a frame to the universal Layer 2 broadcast address (`FFFF.FFFF.FFFF`). Switches flood this frame out of all ports within the broadcast domain.

### Layer 2 Unicast (ARP Reply)

The specific host owning the requested IP address responds directly back to the original sender. Since the sender's MAC address was included in the request, the reply is sent as targeted unicast traffic.

### ARP Cache / ARP Table

A temporary storage area in a host's memory that saves IP-to-MAC mappings. This prevents the host from having to send a broadcast ARP request for every single packet it transmits.

## How It Works

### Step-by-Step Operation on the Same Subnet

```text
[ Sender: 172.23.4.1 ]                                                 [ Receiver: 172.23.4.2 ]
  (1111.2222.3333)                                                       (2222.3333.4444)
         |                                                                      |
         |---- 1. ARP Request (Broadcast: FFFF.FFFF.FFFF) --------------------->|
         |        "Who has 172.23.4.2? Tell 172.23.4.1"                         |
         |                                                                      |
         |                                                                (Processes request &
         |                                                                 saves Sender to Cache)
         |                                                                      |
         |<--- 2. ARP Reply (Unicast: 1111.2222.3333) --------------------------|
         |        "I am 172.23.4.2, my MAC is 2222.3333.4444"                   |
         |                                                                      |
  (Saves Receiver                                                               
   to Cache & sends                                                             
   Layer 2 Frame)
```

1. **Encapsulation Halt:** The sender (e.g., `172.23.4.1`) builds a packet up to Layer 3 destined for `172.23.4.2` but lacks the Layer 2 Destination MAC.
2. **The Request:** The sender broadcasts an ARP request (`Dst MAC: FFFF.FFFF.FFFF`) asking who owns the target IP.
3. **Switch Flooding:** The network switch receives the broadcast and floods it to all connected devices.
4. **The Reply:** Only the host matching `172.23.4.2` processes the message and sends a unicast ARP reply containing its MAC address (`2222.3333.4444`) back to the sender.
5. **Caching:** Both hosts populate their local ARP tables, allowing regular traffic flow to commence.

## Components / Structure

### ARP Packet Context in the OSI Stack

During standard communication, data travels down the stack, but ARP must resolve hardware details before the final Data-Link layer frame can be fully formed:

| Layer | Frame/Header Element | Value in Example |
| --- | --- | --- |
| **Layer 3** | Source IP Address | `172.23.4.1` |
| **Layer 3** | Destination IP Address | `172.23.4.2` |
| **Layer 2** | Source MAC Address | `1111.2222.3333` |
| **Layer 2** | Destination MAC Address | *Initially Unknown* -> Discovered via ARP as `2222.3333.4444` |

## Comparison

| Feature | ARP Request | ARP Reply |
| --- | --- | --- |
| **Transmission Type** | Broadcast (`FFFF.FFFF.FFFF`) | Unicast (Targeted to the original sender) |
| **Switch Behavior** | Flooded out all active ports in the VLAN except the source. | Forwarded precisely out of a single port based on the MAC table. |
| **Sender** | The host initiating communication. | The target host matching the queried IP. |
| **Payload Content** | "Who has target IP X.X.X.X?" | "I have X.X.X.X, here is my MAC." |

## Commands (If Applicable)

### Windows

```bash
# Display the current IPv4 ARP cache table
arp -a

# Flush/Clear the entire dynamic ARP cache (Requires Administrator privileges)
netsh interface ip delete arpcache
```

### Linux

```bash
# Display the current ARP table with numerical entries
arp -n

# Alternative modern command to view neighbor/ARP table
ip neighbor show

# Flush the ARP cache for a specific interface (e.g., eth0)
sudo ip neigh flush dev eth0
```

### Cisco IOS

```text
Router# show ip arp
Router# clear arp-cache
```

## Example

### Host Resolution Scenario (Same Subnet PING)

* **Windows Host:** `172.23.4.1` (MAC: `1111.2222.3333`)
* **Linux Host:** `172.23.4.2` (MAC: `2222.3333.4444`)

When running a ping from the Windows Command Prompt:

```text
C:\> ping 172.23.4.2
Pinging 172.23.4.2 with 32 bytes of data:
Reply from 172.23.4.2: bytes=32 time<1ms TTL=64
```

Behind the scenes, verifying the ARP table right after shows the resolved hardware address:

```text
C:\> arp -a
Interface: 172.23.4.1 --- 0x2
  Internet Address      Physical Address      Type
  172.23.4.2            22-22-33-33-44-44     dynamic
```

## Important Notes

* **Subnet Boundaries:** Standard ARP broadcasts do not cross routers. This operational flow applies exclusively when both devices are in the same IP subnet/VLAN.
* **Silent Execution:** ARP processes run completely automatically in the background without user intervention or visible output in basic application prompts.
* **Cache Expiration:** Entries in the ARP cache are dynamic and will naturally age out and delete themselves after a period of inactivity to maintain network accuracy.
* **Troubleshooting:** Cache corruption or mismatched IPs can lead to connectivity failures, requiring a manual flush (`arp -d` or clearing the table) to fix.

## My Takeaways

* ARP acts as the crucial translator mapping logical Layer 3 IP destinations to physical Layer 2 MAC addresses on a local network segment.
* ARP requests must use Layer 2 broadcasts because a sender has no way of predicting the physical port location or identity of a target host beforehand.
* Switches efficiently manage replies because the response uses unicast, meaning it only passes through the port mapped to the initiating sender.
* Caching via the local host ARP table dramatically optimizes network overhead by cutting down unnecessary broadcast storms.
* Commands like `arp -a` (Windows) and `arp -n` (Linux) provide vital Layer 2 visibility for network engineers diagnostics during structural or physical line issues.
