# ARP across Different Subnets (Routed Traffic)

## Overview

When two hosts communicate across different IP subnets, traffic must pass through a Layer 3 boundary (a router). Because Layer 2 broadcasts cannot cross a router, a sender cannot ARP directly for a final destination that resides on a foreign subnet. Instead, the sender targets its **Default Gateway**. As data moves across the network, the **Layer 3 IP addresses remain constant end-to-end**, whereas the **Layer 2 MAC addresses change hop-by-hop** at each router interface.

## Key Concepts

### Subnet Mask Comparison
Before sending data, a host compares its own IP address and subnet mask with the destination IP address. If they differ, the host recognizes the destination is on a remote network and shifts its target to the default gateway.

### Hop-by-Hop MAC Rewriting
While routing packets, a router strips away the incoming Layer 2 frame header, examines the Layer 3 destination IP to make a routing decision, and encapsulates the packet into a brand-new Layer 2 frame with new source and destination MAC addresses tailored for the next hop.

### Gateway Resolution
The host sends an initial ARP request to find the physical hardware address of its local router interface (the default gateway), rather than the remote target host.

## How It Works

### Step-by-Step Routed Multi-Subnet Architecture

```text
[ Sender: 172.23.4.1 ]               [ Router / Default Gateway ]               [ Receiver: 192.168.10.1 ]
  (1111.2222.3333)                    Int 1 (Left): 172.23.4.254                     (2222.3333.4444)
         |                             MAC: 4444.5555.6666                                  |
         |                            Int 2 (Right): 192.168.10.254                         |
         |                             MAC: 4444.5555.7777                                  |
         |                                      |                                           |
         |-- 1. ARP Request for Gateway ------->|                                           |
         |   "Who has 172.23.4.254?"            |                                           |
         |<- 2. ARP Reply from Gateway ---------|                                           |
         |   "I am .254, here's 4444.5555.6666" |                                           |
         |                                      |                                           |
         |== 3. Packet Sent to Router =========>|                                           |
         |   Src IP: 172.23.4.1                 |-- 4. Router holds packet                  |
         |   Dst IP: 192.168.10.1               |   and sends ARP Request ----------------->|
         |   Src MAC: 1111.2222.3333            |   "Who has 192.168.10.1?"                 |
         |   Dst MAC: 4444.5555.6666            |<-- 5. ARP Reply from Receiver ------------|
         |                                      |   "I am .1, here's 2222.3333.4444"        |
         |                                      |                                           |
         |                                      |== 6. Router Rewrites & Forwards Packet ==>|
         |                                      |   Src IP: 172.23.4.1                      |
         |                                      |   Dst IP: 192.168.10.1                    |
         |                                      |   Src MAC: 4444.5555.7777                 |
         |                                      |   Dst MAC: 2222.3333.4444                 |
```

1. **Subnet Determination:** Host `172.23.4.1` detects that `192.168.10.1` is on a remote subnet.
2. **First Segment ARP:** The host sends a local Layer 2 broadcast seeking the MAC of its gateway (`172.23.4.254`). The router responds with `4444.5555.6666`.
3. **Transmission to Gateway:** The host transmits the frame to the router. The IP headers list the ultimate destination (`192.168.10.1`), but the MAC header targets the router.
4. **Second Segment ARP:** The router decapsulates the frame. Seeing a destination of `192.168.10.1` on its right interface, it checks its own ARP cache. If empty, the router buffers the packet and broadcasts an ARP request out its right interface.
5. **Final Destination Reply:** The receiver (`192.168.10.1`) returns its MAC address (`2222.3333.4444`) via unicast to the router.
6. **Frame Remaking & Delivery:** The router creates a new Layer 2 frame enclosing the original packet, modifying the Source MAC to its right interface (`4444.5555.7777`) and the Destination MAC to the receiver (`2222.3333.4444`).

## Components / Structure

### Header Transformation Throughout the Path

| Location | Source IP | Destination IP | Source MAC | Destination MAC |
| --- | --- | --- | --- | --- |
| **On Left Segment** *(Host to Router)* | `172.23.4.1` | `192.168.10.1` | `1111.2222.3333` | `4444.5555.6666` *(Gateway)* |
| **On Right Segment** *(Router to Host)* | `172.23.4.1` | `192.168.10.1` | `4444.5555.7777` *(Router)* | `2222.3333.4444` *(Receiver)* |

## Comparison

| Parameter | Inside the Same Subnet | Across Different Subnets (Routed) |
| --- | --- | --- |
| **Initial ARP Target** | The IP address of the final destination host. | The IP address of the local Default Gateway. |
| **Broadcast Reach** | Reaches the final host directly. | Limited to the sender's local VLAN/segment. |
| **MAC Layer Changes** | Source and Destination MACs remain unchanged. | Source and Destination MACs are rewritten at each router hop. |
| **IP Layer Changes** | Source and Destination IPs remain unchanged. | Source and Destination IPs remain unchanged. |

## Commands (If Applicable)

### Cisco IOS

```text
# Display the current ARP cache mapping table on a Cisco Router
Router# show ip arp

# Alternative command yielding the same mapping table results
Router# show arp

# Completely clear all dynamic entries inside the router's ARP cache
Router# clear arp-cache
```

## Example

### Viewing the Router ARP Table Output

Below is the typical layout displayed when issuing diagnostic commands on a Cisco router (`R1`) communicating across segments:

```text
Router-R1# show arp
Protocol  Address          Age (min)  Hardware Addr   Type   Interface
Internet  10.10.10.1              -   000c.294f.a11a  ARPA   FastEthernet0/0
Internet  10.10.10.2              5   000c.298c.b22b  ARPA   FastEthernet0/0
```

*Field Meanings:*

* **Protocol:** Network layer protocol (typically Internet / IPv4).
* **Address:** The mapped IP address.
* **Age (min):** Time in minutes since the entry was refreshed. A hyphen (`-`) means local interface.
* **Hardware Addr:** The discovered Layer 2 MAC address.
* **Interface:** The specific exit port where the device is physically reachable.

## Important Notes

* **IP Address Invariance:** Regardless of how many routers or firewalls a packet traverses across the internet, the original Source IP and ultimate Destination IP **never change** under normal routing conditions (excluding NAT).
* **Broadcast Boundary:** A router acts as a strict barrier for broadcast frames. It drops frames addressed to `FFFF.FFFF.FFFF`, preventing local segment broadcast traffic from spilling onto neighboring subnets.
* **Packet Buffering:** While a router waits for an ARP query response on an adjacent interface, it temporarily queues the original data packet in memory. If the ARP request times out, the packet is discarded.

## My Takeaways

* A host uses its subnet mask to calculate if a destination is remote, preventing it from performing useless direct ARP broadcasts to external networks.
* When traffic crosses subnets, the destination MAC address is always pointed at the gateway interface handling the local segment.
* The core mechanic of routing involves continually stripping off old Layer 2 headers and rebuilding new ones for the next physical medium link.
* Understanding that IP addresses remain static while MAC addresses change hop-by-hop is a core prerequisite for tracing data patterns globally.
* The command `show ip arp` on Cisco IOS provides crucial visibility into neighboring gateway nodes, tracking names, bindings, and hardware exit points.