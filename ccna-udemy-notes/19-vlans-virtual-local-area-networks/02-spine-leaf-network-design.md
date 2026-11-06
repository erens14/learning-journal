# Spine-Leaf Network Design

## Overview

Spine-leaf is a data-center design that connects server-facing leaf switches through a mesh of spine switches. It supports growth and predictable paths when substantial traffic flows between servers.

The lecture contrasts this with the traditional campus hierarchy of access, distribution, and core.

## North-South and East-West Traffic

| Direction | Meaning in the lecture | Example |
| --- | --- | --- |
| North-south | Traffic between clients outside the data center and its servers. | A client in another campus building accesses a server. |
| East-west | Traffic between servers within the data center. | A web front end communicates with a database server. |

The traditional campus hierarchy works well for the lecture's client-to-server traffic pattern:

```text
Client in Building 1
        |
   Access layer
        |
 Distribution layer
        |
     Core layer
        |
 Distribution layer
        |
   Access layer
        |
Server in Main Building / Data Center
```

Modern applications can generate more server-to-server traffic because:

- Virtualization places many virtual servers in the data center.
- A clustered application can spread work across several servers.
- An application can use separate front-end and database servers.

These systems need efficient connectivity between servers, alongside the north-south traffic that still exists.

## Spine and Leaf Roles

Servers connect to leaf switches. Spine switches form the upper layer and interconnect the leaves; servers do not attach directly to the spines in this design.

Every leaf connects to every spine. This is a mesh between the two layers, rather than a requirement to connect every switch to every other switch.

Conceptual diagram; the transcript does not provide device names or interface numbers:

```text
          [Spine A]              [Spine B]
              |  \              /  |
              |    \          /    |
              |      \      /      |
              |        \  /        |
              |         X          |
              |        /  \        |
              |      /      \      |
              |    /          \    |
              |  /              \  |
           [Leaf A]              [Leaf B]
              |                     |
            Server                Server
```

The crossing lines are separate links, not a device or a connection between the spines. Each leaf has one link to each spine.

## Paths Between Servers

For servers attached to different leaves, the path is:

```text
Source server -- Source leaf -- Spine -- Destination leaf -- Destination server
```

The source leaf can reach the destination leaf through a spine without traversing a longer campus hierarchy.

The lecture describes this as a maximum of two hops when counting the spine and destination leaf after the source leaf. To avoid ambiguity, remember the actual path: **leaf, spine, leaf**, with two inter-switch links and three forwarding switches. [Cisco: spine-leaf path length](https://www.cisco.com/c/en/us/solutions/collateral/enterprise/cisco-on-cisco/cs-en-08022017-sdn-thesis.html)

## Scaling the Fabric

A small spine-leaf diagram can resemble a collapsed distribution/core topology. Its defining property is the connection pattern: each leaf connects to all spines.

The lecture scales the design by adding leaves and spines:

- A new leaf adds another server attachment point and connects to the existing spines.
- A new spine connects to all leaves and expands the available cross-layer connectivity.

The design maintains short paths as the data center grows. It serves north-south traffic as well as the east-west traffic that motivates this topology.

## My Takeaways

- Identify traffic direction by its endpoints, rather than the orientation of a drawing.
- The leaf layer attaches servers; the spine layer connects those attachment points.
- A complete set of leaf-to-spine links distinguishes the fabric from an arbitrary two-layer hierarchy.
- Describe the forwarding path explicitly when a hop count could be interpreted in different ways.
