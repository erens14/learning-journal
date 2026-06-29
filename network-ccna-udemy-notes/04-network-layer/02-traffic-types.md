# 2. Traffic Types

## Overview

This lecture introduces the three primary traffic delivery methods used in IP networks:

* Unicast
* Broadcast
* Multicast

Each traffic type serves a different purpose depending on how many destination devices should receive the data.

## Unicast

Unicast communication sends data from one sender to one specific destination.

Characteristics:

* One sender
* One receiver
* Most common traffic type on modern networks

Examples:

* Opening a website
* SSH connection
* Downloading a file
* API communication

Diagram : 

![Unicast Traffic Diagram](/network-ccna-udemy-notes/04-network-layer/images/unicast-traffic-diagram.jpg)

![Unicast Traffic with Multiple Host Diagram](/network-ccna-udemy-notes/04-network-layer/images/unicast-multiple-host-diagram.jpg)

## Broadcast

Broadcast communication sends one packet to **every host within the same subnet**.

Characteristics:

* One sender
* All devices on the local network receive the packet
* Routers do **not** forward broadcast traffic

Reason:

Limiting broadcast traffic to a single subnet helps improve performance and prevents unnecessary traffic from spreading across larger networks such as the Internet.

Diagram : 

![Broadcast Traffic Diagram](/network-ccna-udemy-notes/04-network-layer/images/broadcast-traffic-diagram.jpg)

## Multicast

Multicast sends **one copy of data** to **multiple subscribed receivers**.

Unlike broadcast, only devices that have joined the multicast group receive the traffic.

Benefits:

* Saves bandwidth
* Reduces duplicate traffic
* More efficient than sending multiple unicast streams

Example:

A server streaming a live video to multiple users.

Instead of transmitting three separate streams, the server sends one multicast stream that is delivered only to interested receivers.

Diagram : 

![Multicast Traffic Diagram](/network-ccna-udemy-notes/04-network-layer/images/multicast-traffic-diagram.jpg)

## Traffic Comparison

| Traffic Type | Destination           | Router Forwarding   | Typical Use                        |
| ------------ | --------------------- | ------------------- | ---------------------------------- |
| Unicast      | One host              | Yes                 | Web browsing, SSH, Email           |
| Broadcast    | All hosts on a subnet | No                  | ARP, DHCP Discover                 |
| Multicast    | Selected hosts        | Yes (if configured) | IPTV, Video Streaming, Live Events |

## Key Concept

Broadcast and multicast may appear similar because both deliver data to multiple devices.

The main difference is:

* **Broadcast** reaches every device on the subnet.
* **Multicast** reaches only devices that explicitly join the multicast group.

This makes multicast much more bandwidth-efficient for one-to-many communication.

## My Takeaways

* Unicast is the default communication model used by most applications.
* Broadcast is limited to a single subnet because routers intentionally stop broadcast traffic.
* Multicast reduces bandwidth usage by sending one stream to multiple subscribed receivers.
* Choosing the appropriate traffic type is important for network efficiency and scalability.