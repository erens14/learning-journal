# Loopback Interfaces

## Overview

A loopback interface is a logical interface on a router or Layer 3 switch. Its IP address is not tied to a physical port, so it stays reachable as long as routing to the device still exists, even when one physical path fails.

Loopbacks are normally assigned a `/32` address because they represent one logical address on one device.

## Why Use a Loopback Interface

- Provides one stable address for traffic that terminates on the router.
- Commonly used for management access, BGP peering, and IP telephony traffic.
- Can identify a router in OSPF through its router ID.
- Supports redundancy when multiple routed paths lead to the same router.

One loopback interface is normally enough for multiple uses. Additional loopbacks are possible but are usually reserved for special cases.

## Loopback vs Physical Interface

| Interface type | Tied to a cable or port | Affected by a physical link failure | Typical use |
| --- | --- | --- | --- |
| Physical interface | Yes | Yes | Forwarding traffic across a direct link |
| Loopback interface | No | No | Stable router address for management or routing services |

## Redundant Access Example

R4 can reach R1 through two paths. Instead of managing R1 through one physical-interface address, R4 targets R1's loopback address, `192.168.1.1/32`.

```text
PC 10.1.2.10
      |
     R4
     | \________________________
     |                          \
     R3 -- R2 -- R1              R5
               |                 |
               +-- Lo0           +-- R1
                   192.168.1.1/32

Top path:    R4 - R3 - R2 - R1
Bottom path: R4 - R5 - R1
```

The routing protocol advertises `192.168.1.1/32`. R4 learns both available paths and uses the lower-cost path, or both paths if their costs are equal. If one path fails, R4 can still reach the same loopback address through the remaining path.

## Basic Configuration

### Create the Loopback on R1

```text
R1# configure terminal
R1(config)# interface loopback 0
R1(config-if)# ip address 192.168.1.1 255.255.255.255
```

The interface comes up immediately because it is logical; it does not need a physical cable or `no shutdown` command.

### Advertise the Loopback in EIGRP

```text
R1(config)# router eigrp 100
R1(config-router)# network 192.168.1.1 0.0.0.0
```

The wildcard mask `0.0.0.0` matches only `192.168.1.1`, allowing other routers to learn the `/32` loopback route.

## Verification and Failover

```text
R1# show ip interface brief
R4# show ip route
R4# ping 192.168.1.1
R4# traceroute 192.168.1.1
```

In the lab, R4 initially reached `192.168.1.1` through its top path on `FastEthernet0/0`. After that interface was shut down, EIGRP removed the failed path and installed the route through `FastEthernet2/0` and R5. The loopback address remained reachable because the bottom path was still available.

## My Takeaways

- A loopback is a logical router address, not an address tied to one physical port.
- `/32` is the normal mask because the loopback represents one device address.
- Advertising a loopback in the routing protocol makes it reachable through every valid routed path.
- A single loopback address avoids changing the destination when one physical path to the router fails.
- Loopbacks are useful for stable management, BGP, IP telephony, and OSPF router identification.
