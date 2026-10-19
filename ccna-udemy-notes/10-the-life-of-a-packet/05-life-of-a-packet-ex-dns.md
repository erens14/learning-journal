# Life of a Packet (Part 1: DNS Name Resolution)

## Overview

In this example, Host A resolves `www.flackbox.com` before sending HTTP traffic. The DNS query crosses subnets, so its delivery also involves IP routing, ARP, MAC learning, and switching.

## Key Concepts

### Packet Deconstruction & Buffering

The host needs a destination IP address before sending the HTTP request. In this example, DNS resolves the name first, and ARP supplies the local-link MAC mappings needed to deliver packets.

### MAC Table vs. ARP Cache Roles

- **MAC Table (Layer 2 - Switch):** Maps a physical port to a hardware MAC address based on *source traffic observations*.
- **ARP Cache (Layer 2/3 - Host/Router):** Maps a logical IP address directly to a physical MAC address based on *broadcast queries*.

### End-to-End Consistency vs. Hop-by-Hop Instability

- **IP Headers:** The source and destination logical IP addresses **never alter** from the original creator to the final system.
- **MAC Headers:** Routers replace the incoming Layer 2 header with one for the outgoing link.

## How It Works

### Step-by-Step Resolution Architecture Workflow

```text
[ Host A ]               [ Switch 1 ]               [ Router A ]               [ Switch 3 ]             [ DNS Server ]
(10.10.10.10)                                   (Int 1: 10.10.10.1)                                     (10.10.100.10)
     |                                          (Int 2: 10.10.100.1)                                           |
     |                                                   |                                                     |
     |-- 1. Broadcast ARP for Gateway ------------------>|                                                     |
     |<- 2. Unicast ARP Reply from Gateway --------------|                                                     |
     |                                                   |                                                     |
     |== 3. Unicast DNS Request to Gateway =============>|                                                     |
     |   [Src IP: .10.10 | Dst IP: .100.10]              |-- 4. Router buffers DNS Request                     |
     |   [Src MAC: Host  | Dst MAC: Rtr Int1]            |      and launches ARP for DNS Server -------------->|
     |                                                   |<-- 5. Unicast ARP Reply from DNS Server ------------|
     |                                                   |                                                     |
     |                                                   |== 6. Router Rewrites & Forwards DNS Request =======>|
     |                                                   |   [Src IP: .10.10 | Dst IP: .100.10]                |
     |                                                   |   [Src MAC: Rtr Int2 | Dst MAC: DNS Server]         |
     |                                                   |                                                     |
     |                                                   |                                              (Processes DNS Query
     |                                                   |                                               & locates database)
     |                                                   |                                                     |
     |<== 8. Router Delivers Remade DNS Reply -----------|<== 7. Unicast DNS Reply to Gateway =================|
     |   [Src IP: .100.10 | Dst IP: .10.10]              |   [Src IP: .100.10 | Dst IP: .10.10]                |
     |   [Src MAC: Rtr Int1 | Dst MAC: Host]             |   [Src MAC: DNS Server | Dst MAC: Rtr Int2]         |
```

### Operational Timeline Breakdown

1. **Host A Local Network Evaluation:** Host A tries to ping/access `www.flackbox.com`. It realizes it lacks the IP address and constructs a DNS request targeting its local DNS Server (`10.10.100.10`). It notices the DNS Server is on an external subnet, requiring redirection through its Default Gateway (`10.10.10.1`).
2. **First Subnet Discovery (ARP Phase):** Host A checks its ARP cache for the gateway's MAC address. If empty, it buffers the DNS request packet and broadcasts an ARP request. Switch 1 records Host A's MAC (`1111.2222.3333`) on Port 1 and floods the frame. Router A processes the frame and sends back a unicast ARP reply containing its MAC (`4444.5555.6666`), which Switch 1 maps on Port 2.
3. **DNS Outbound Transmission (Segment 1):** Host A moves the DNS request from the buffer, wraps it in a Layer 2 frame targeting the Gateway MAC, and sends it out. Switch 1 forwards it directly out Port 2 to the router.
4. **Second Subnet Discovery (Router ARP Phase):** Router A receives the frame, reads the Layer 3 header, and notices the destination IP (`10.10.100.10`) belongs to its secondary local interface subnet (`10.10.100.0/24`). Lacking the target server's MAC address, it stores the DNS query and broadcasts an ARP request out its right-side interface.
5. **DNS Server Recognition:** Switch 3 populates its MAC table with the router's second MAC (`8888.9999.AAAA`) and broadcasts the query. The DNS Server recognizes the IP request and replies with its MAC address (`3333.4444.5555`). Switch 3 registers this binding on Port 2.
6. **DNS Execution & Return Path:** Router A retrieves the buffered DNS request, changes the Source MAC to `8888.9999.AAAA`, sets the Destination MAC to `3333.4444.5555`, and forwards it to the DNS Server. The server checks its database records and finds `www.flackbox.com = 10.10.12.10`. It responds by sending a DNS reply back along the path through Router A, which switches the hardware mappings back to deliver it to Host A.
7. **DNS Resolution:** Host A receives the reply and uses the resolved address (`10.10.12.10`) as the destination for its HTTP traffic.

## Components / Structure

### OSI Layer Analysis during Processing at DNS Server Node

When the final DNS request frame reaches the network interface card of the DNS Server, the server inspects the parameters from the bottom up to ensure data validity:

| OSI Layer | Inspected Header Element | Server Validation Action / Result |
| --- | --- | --- |
| **Layer 2** | Destination MAC Address | Matches `3333.4444.5555` (Itself). Validates frame and strips header. |
| **Layer 3** | Destination IP Address | Matches `10.10.100.10` (Itself). Validates packet and strips header. |
| **Layer 4** | Transport Layer Protocol & Port | Identifies **UDP Port 53**. Directs the internal payload to the DNS application daemon. |
| **Layer 7** | Application Payload Data | Parses query query string: `www.flackbox.com`. Queries database zone records. |

## Comparison

### Frame Header Manipulation Along the Routing Path

| Packet Layer Field | Initial Frame Host A -> Router A | Intermediate Frame Router A -> DNS Server | Return Frame DNS Server -> Router A | Final Delivery Frame Router A -> Host A |
| --- | --- | --- | --- | --- |
| **Source IP** | `10.10.10.10` | `10.10.10.10` | `10.10.100.10` | `10.10.100.10` |
| **Destination IP** | `10.10.100.10` | `10.10.100.10` | `10.10.10.10` | `10.10.10.10` |
| **Source MAC** | `1111.2222.3333` | `8888.9999.AAAA` | `3333.4444.5555` | `4444.5555.6666` |
| **Destination MAC** | `4444.5555.6666` | `3333.4444.5555` | `8888.9999.AAAA` | `1111.2222.3333` |

## Important Notes

- **Layer Independence:** Application processes do not track physical paths. The browser relies on the operating system's network stack to transparently resolve address and hardware details before transmission.
- Switches learn source MAC addresses and use their MAC tables to forward frames. Unknown destinations require flooding in this example.
- Router A connects directly to both subnets, so this path does not require a dynamically learned route.

## My Takeaways

- Host A resolves the web server's name before sending HTTP traffic in this example.
- The example holds packets while ARP resolves the next local-link destination.
- In this example, source and destination IP addresses stay the same while MAC addresses change at router boundaries.
- Switches read only the incoming Source MAC field to construct their port mapping tables, while ignoring the payload content inside.
- Troubleshooting remote connectivity issues requires examining both Layer 3 DNS server reachability and local Layer 2 gateway ARP parameters.
