# Life of a Packet (Part 2: HTTP Web Traffic Delivery)

## Overview

After DNS resolves the web server to `10.10.12.10`, Host A sends HTTP traffic through Router A and Router B. This example follows route lookups, ARP exchanges, and MAC-address changes along that path.

## Key Concepts

### Intermediary Next-Hop Routing

For a remote destination, the router checks its routing table for the next hop. The route can be configured statically or learned through a dynamic routing protocol.

### Packet Buffering at the Network Boundaries

In this example, a router holds the packet while ARP resolves the next hop's MAC address. It sends the ARP request on the outgoing link, then builds the Ethernet frame using the reply.

### Steady State Flow Acceleration

Once the ARP and MAC tables contain the required mappings, subsequent frames can be forwarded without repeating those discovery exchanges. The mappings remain usable until they change or expire.

## How It Works

### Multi-Hop HTTP Delivery

```text
 [ Host A ]        [ Switch 1 ]        [ Router A ]                    [ Router B ]        [ Switch 2 ]     [ Web Server ]
(10.10.10.10)                       (Int 1: 10.10.10.1)             (Int 1: 10.10.11.2)                     (10.10.12.10)
     |                              (Int 2: 10.10.11.1)             (Int 2: 10.10.12.1)                          |
     |                                       |                               |                                   |
     |== 1. Initial HTTP Packet to R_A =====>|                               |                                   |
     |                                       |-- 2. R_A reads Static Route   |                                   |
     |                                       |      to 10.10.12.0/24 via     |                                   |
     |                                       |      Next-Hop 10.10.11.2.     |                                   |
     |                                       |      Launches ARP for R_B --->|                                   |
     |                                       |<- 3. Unicast ARP Reply -------|                                   |
     |                                       |                               |                                   |
     |                                       |== 4. Remade HTTP to R_B =====>|                                   |
     |                                       |                               |-- 5. R_B checks local port,       |
     |                                       |                               |      holds packet, and            |
     |                                       |                               |      launches ARP for Server ---->|
     |                                       |                               |<-- 6. Unicast ARP Reply ----------|
     |                                       |                               |                                   |
     |                                       |                               |== 7. Remade HTTP to Server ======>|
     |                                       |                               |                                   (Processes Data)
     |                                       |                               |                                   |
  ================================= STEADY STATE SESSION ESTABLISHED =================================
     |                                       |                               |                                   |
     |== 8. Subsequent HTTP Packet =========>|== 9. Instant Forwarding =====>|== 10. Instant Delivery ==========>|
     |   [No ARP Broadcast Overheads]        |   [No ARP Broadcast Overheads]|   [No ARP Broadcast Overheads]    |
```

### End-to-End Hop Transformations

1. **Host A Egress:** Host A populates the destination IP (`10.10.12.10`), encapsulates the HTTP GET request with a destination MAC pointing to its default gateway (`4444.5555.6666`), and drops it on the wire via Switch 1.
2. **Router A Processing:** Router A decapsulates the frame. It consults its routing table for `10.10.12.0/24` and finds a static route pointing to next-hop `10.10.11.2`. Since it lacks `10.10.11.2`'s hardware mapping, it buffers the HTTP packet and broadcasts an ARP request across the `10.10.11.0` transit segment.
3. **Router B Response:** Router B processes the broadcast on its `10.10.11.2` interface, updates its ARP cache with Router A's details, and sends a unicast ARP reply containing its MAC address (`6666.7777.8888`).
4. **Router A Forwarding:** Router A pulls the HTTP packet from its buffer, updates the Source MAC to `5555.6666.7777`, sets the Destination MAC to `6666.7777.8888`, and ships it to Router B.
5. **Router B Segment Discovery:** Router B reads the packet and notes the target IP falls within its directly connected `10.10.12.0/24` subnet interface. Lacking the Web Server's physical hardware address, it buffers the packet and broadcasts an ARP request into the final segment via Switch 2.
6. **Server Resolution Completion:** The Web Server processes the request, caches Router B's gateway layout (`7777.8888.9999`), and sends a unicast ARP reply back with its physical signature (`2222.3333.4444`). Switch 2 logs this mapping onto Port 2.
7. **Final Frame Remake:** Router B completes the sequence: it flushes the buffered payload, rewrites the Source MAC to `7777.8888.9999`, sets the Destination MAC to `2222.3333.4444`, and delivers it to the Web Server via Switch 2. The server decapsulates the layers from the bottom up, processing the web traffic at TCP Port 80.

## Components / Structure

### Headers at Each Hop

The table shows the source and destination addresses at each hop:

| Hop Location | Outer Source MAC | Outer Destination MAC | Inner Source IP | Inner Destination IP | Transport Layer |
| --- | --- | --- | --- | --- | --- |
| **Host A $\rightarrow$ Router A** | `1111.2222.3333` | `4444.5555.6666` | `10.10.10.10` | `10.10.12.10` | TCP Port 80 |
| **Router A $\rightarrow$ Router B** | `5555.6666.7777` | `6666.7777.8888` | `10.10.10.10` | `10.10.12.10` | TCP Port 80 |
| **Router B $\rightarrow$ Web Server** | `7777.8888.9999` | `2222.3333.4444` | `10.10.10.10` | `10.10.12.10` | TCP Port 80 |

## Comparison

### Layer 2 Switching vs. Layer 3 Routing Behaviors

| Feature / Metric | Layer 2 Switching (Switch 1 & 2) | Layer 3 Routing (Router A & B) |
| --- | --- | --- |
| **Primary Identifier Checked** | Hardware MAC Address (Flat space). | Logical Network IP Address (Hierarchical space). |
| **Table Referenced** | MAC Address Table / CAM Table. | Routing Table (`show ip route`). |
| **Data Modification** | Passes the frame through cleanly without altering headers. | Completely strips the Layer 2 frame and overwrites MAC values. |
| **Handling of Remote Subnets** | Incapable of passing traffic beyond the local broadcast domain. | Actively bridges boundaries using routes or dynamic next-hops. |

## Important Notes

* In this example, source IP `10.10.10.10` and destination IP `10.10.12.10` stay the same across the routed path.
* **Mac Table Learning:** Intermediary switches do not execute active network polls; they populate their tables dynamically by reading the *Source MAC* field of any passing frames.
* While the required cache entries remain valid, later frames can use them without repeating ARP discovery.

## My Takeaways

* Layer 3 routers strip and recreate Layer 2 frame headers at every single subnet intersection along a packet's journey.
* If a router's routing table lacks an explicit static or dynamic entry for a remote destination network, it drops the packet immediately.
* Switches simply guide frames within a single subnet, whereas routers make advanced, long-distance path selections based on logical IP mappings.
* ARP queries operate in isolated zones; they run independently on individual network segments and do not pass through Layer 3 boundaries.
* Cached ARP and MAC mappings let later frames use unicast forwarding without repeating the initial discovery exchanges.
