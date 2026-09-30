# Basic Connectivity Troubleshooting

## Overview

Ping checks whether traffic can reach a destination and return to the source. Traceroute helps locate where the path stops responding. When testing a user's problem from a router, the source address matters: a successful router ping can hide a missing return route to the user's subnet.

## Ping and ICMP

ICMP stands for Internet Control Message Protocol and is part of the TCP/IP suite. Ping uses an ICMP echo request and echo reply to test two-way connectivity.

In the lecture example, R1 pings the `10.1.0.1` address on R3:

```text
              Echo request: destination 10.1.0.1
       ------------------------------------------------>
     [R1] ---------------- [R2] ---------------- [R3]
       <------------------------------------------------
              Echo reply: destination R1's source IP
```

For a normal router-originated ping, the source IP is normally the address of the outgoing interface. The destination must have a return path to that address.

```text
R1# ping 10.1.0.1
```

### Reading Cisco Ping Results

| Symbol | Meaning | What to check |
| --- | --- | --- |
| `!` | Echo reply received | The request and reply completed successfully. |
| `.` | Reply timed out | Check routing and whether the destination responds. |
| `U` | ICMP unreachable message received | A device reports that it cannot deliver the packet; filtering such as an ACL may be involved. |

The lecture shows this result:

```text
.!!!!
```

Four of five probes succeed, giving an 80% success rate. The first probe can time out while ARP resolution completes. This result confirms connectivity for the successful probes; one initial timeout alone does not establish a continuing fault.

Five dots mean none of the probes received a reply:

```text
.....
```

A missing route or a destination that does not respond can cause this. Ping failure alone does not identify which part of the request or return path failed.

## Extended Ping: Test from the User's Subnet

### Why a Normal Router Ping Can Mislead

PC1 at `10.0.1.10` cannot reach PC3 at `10.1.2.10`. R4 has a route back to R1's outgoing address, `10.0.0.1`, but lacks a route back to PC1's subnet.

The diagram reconstructs the addresses and relationships described in the transcript. The intervening network is left unlabeled because its full topology is not specified.

```text
 [PC1]                  [R1]                 [R4]          [PC3]
 10.0.1.10 ----- 10.0.1.1 | 10.0.0.1 -- ... -- | -------- 10.1.2.10
                 LAN IP     outgoing IP

 R4's return routes:
   To 10.0.0.1: available
   To PC1's subnet containing 10.0.1.10 and 10.0.1.1: missing
```

The same destination produces different results depending on the source:

| Test | Source IP | Result in this example | Reason |
| --- | --- | --- | --- |
| PC1 pings PC3 | `10.0.1.10` | Fails | R4 cannot route the reply back to PC1. |
| R1 uses normal ping to PC3 | `10.0.0.1` | Succeeds | R4 has a return route to R1's outgoing address. |
| R1 uses extended ping to PC3 | `10.0.1.1` | Fails | The selected source is in PC1's subnet, which lacks a return route. |

```text
 Normal ping:
 R1 (10.0.0.1) -------- request --------> PC3 (10.1.2.10)
 R1 (10.0.0.1) <------- reply via R4 ---- PC3
 Result: succeeds

 Extended ping:
 R1 (10.0.1.1) -------- request --------> PC3 (10.1.2.10)
 R1 (10.0.1.1) <--- X --- R4 <--- reply - PC3
                         |
                         No return route to source subnet
 Result: fails
```

When possible, test directly from PC1. Otherwise, use R1's own interface address `10.0.1.1` as the ping source. Do not enter PC1's address as though it belongs to R1.

### Running Extended Ping

Enter `ping` without a destination to start the interactive prompts:

```text
R1# ping
```

For this example:

1. Accept the default protocol, IP.
2. Enter target address `10.1.2.10`.
3. Accept the repeat count, datagram size, and timeout defaults unless testing a specific issue.
4. Answer `y` when asked whether to use extended commands.
5. Set the source address to `10.0.1.1`, R1's address in the user's subnet.
6. Accept the remaining defaults.

The failure now reproduces the return-routing problem affecting PC1's subnet.

### Other Useful Ping Options

| Option | Use |
| --- | --- |
| Repeat count | Send more probes when checking an intermittent issue. The lecture suggests `1000` to observe repeated success or failure. |
| Datagram size | Test different packet sizes when investigating a suspected Maximum Transmission Unit (MTU) issue. |
| Timeout | Control how long to wait for each reply. The lecture normally leaves this at the default of 2 seconds. |
| Source address | Test the return path to a particular router interface or subnet. |

## Traceroute and TTL

Traceroute discovers the responding hops toward a destination by sending probes with increasing Time To Live (TTL) values. TTL is a field in the IP header.

### TTL Limits Routing Loops

Each router decrements TTL when forwarding a packet. When TTL expires, the router drops the packet and sends an ICMP Time Exceeded message back to the source.

The lecture uses a routing mistake where R1 and R2 keep sending the same packet back to each other:

```text
 [R1] ----------------------------- [R2]
      -------- TTL 15 ------------->
      <------- TTL 14 --------------
      -------- TTL 13 ------------->
      <------- TTL 12 --------------
                    ...
      TTL eventually expires; packet is dropped.
```

TTL does not fix the bad routes. It stops an individual packet from circulating indefinitely and consuming link capacity forever.

### Discovering Hops with Increasing TTL

For the R1-to-R3 example, the destination is `10.1.0.1`, and R2's responding address is `10.0.0.2`:

```text
 [R1] ---------------- [R2] ---------------- [R3]
                       10.0.0.2             10.1.0.1

 Probe with TTL 1:
 R1 -----------------> R2
 R1 <----------------- R2: ICMP Time Exceeded
                       First hop identified

 Probe with TTL 2:
 R1 -----------------> R2 -----------------> R3
 R1 <-------------------------------------- R3: destination response
                                            Destination reached
```

1. R1 sends a probe with TTL `1`.
2. R2 decrements it to zero, drops it, and replies with ICMP Time Exceeded. R1 identifies the first hop as `10.0.0.2`.
3. R1 sends another probe with TTL `2`.
4. R2 forwards it with TTL `1`, allowing it to reach R3, the destination.
5. R3 responds, completing the trace in this two-hop example.

For a longer path, the source continues with TTL `3`, `4`, and so on until the destination is reached or the trace stops.

### Traceroute Probe Type

The lecture describes echo-request probes and an echo reply at the destination. That matches an ICMP-based trace. Cisco IOS normally uses UDP probes and receives ICMP Port Unreachable from the destination. Both methods use ICMP Time Exceeded to discover intermediate hops. [Cisco traceroute documentation](https://www.cisco.com/c/en/us/support/docs/ip/ip-routed-protocols/22826-traceroute.html).

## Using Traceroute to Narrow Down a Fault

When ping fails, trace toward the same destination to find how far the probes receive responses:

```text
R1# traceroute 10.1.2.1
```

The failure example responds at `10.0.0.2` and then `10.1.0.1`, but does not reach `10.1.2.1`:

```text
 Source ------> Hop 1 ------> Hop 2 ------> Destination
                10.0.0.2     10.1.0.1     10.1.2.1
                responds     responds     not reached
                                  |
                                  Start checking around this hop
```

Start by inspecting the routing table on the router at `10.1.0.1`:

```text
Router# show ip route
```

Check whether it has a route toward `10.1.2.1`. If the route exists, continue investigating forwarding from that point and the response path. The last responding hop narrows the search; it does not prove that router is faulty, because filtering or missing replies can also stop a trace.

This is faster than checking every router from the source without knowing where responses stop.

### Ping Works but Traceroute Fails

A trace may fail at the last hop, or a firewall may block its probes or replies. A successful ping still confirms that ICMP echo traffic completed the round trip for the tested source and destination. A failed trace alone does not invalidate that result.

To stop a Cisco traceroute instead of waiting through repeated timeouts, press `Ctrl-Shift-6` together.

## Other Connectivity Checks

The lecture recaps these tools without repeating the earlier Layer 1 and Layer 2 lessons:

| Area | Command | What it helps check |
| --- | --- | --- |
| Interface / Layer 1 | `show ip interface brief` | Interface addresses and status. |
| Interface / Layer 1 | `show interfaces` | Detailed interface information. |
| Layer 2 | `show arp` | IP-to-MAC address mappings. |
| Layer 2 on a switch | `show mac address-table` | Learned MAC addresses and switch ports. |
| Layer 4 | `telnet <destination-ip> <port>` | Whether a TCP connection can be established to the selected destination port. |
| DNS | `nslookup <name>` | Whether DNS resolves the requested name. |
| DNS and connectivity | `ping <fqdn>` | Whether the fully qualified domain name resolves, followed by an ICMP connectivity test. |

For a name-based ping, distinguish failure to resolve the name from failure to receive an echo reply after resolution.

## My Takeaways

- Check the return route as well as the forward route. Reaching the destination is only half of a successful ping.
- Match the ping source to the affected subnet when troubleshooting from a router.
- An initial timeout can be ARP-related; repeated timeouts need further investigation.
- Use increasing TTL values to understand how traceroute reveals hops. Expired TTL also limits the lifetime of looping packets.
- Treat the last responding hop as a starting point for investigation, then verify routing and response paths.
- Choose the next tool according to the problem: interface status, Layer 2 mappings, a TCP port, or DNS resolution.
