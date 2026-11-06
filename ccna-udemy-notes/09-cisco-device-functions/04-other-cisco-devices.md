# Cisco Networking Products: Self Notes

## Table of Contents

- [Cisco Networking Products: Self Notes](#cisco-networking-products-self-notes)
  - [Table of Contents](#table-of-contents)
  - [Overview](#overview)
  - [Cisco Product Portfolio](#cisco-product-portfolio)
    - [1. Cisco ASA (Adaptive Security Appliance)](#1-cisco-asa-adaptive-security-appliance)
      - [Primary Functions](#primary-functions)
      - [Purpose](#purpose)
    - [2. Cisco FirePower IPS](#2-cisco-firepower-ips)
      - [Deployment Options](#deployment-options)
      - [Functions](#functions)
    - [3. Cisco Wireless Solutions](#3-cisco-wireless-solutions)
      - [Wireless LAN Controller (WLC)](#wireless-lan-controller-wlc)
      - [Wireless Access Point (AP)](#wireless-access-point-ap)
      - [Why Use a WLC?](#why-use-a-wlc)
  - [Cisco Collaboration Products](#cisco-collaboration-products)
    - [4. Cisco Unified Communications Manager (CUCM)](#4-cisco-unified-communications-manager-cucm)
      - [Purpose](#purpose-1)
      - [Traditional PBX vs IP PBX](#traditional-pbx-vs-ip-pbx)
    - [5. Cisco IP Phones](#5-cisco-ip-phones)
    - [6. Cisco TelePresence](#6-cisco-telepresence)
      - [Features](#features)
    - [7. Cisco Webex](#7-cisco-webex)
  - [Cisco Data Center Products](#cisco-data-center-products)
    - [8. Cisco UCS (Unified Computing System)](#8-cisco-ucs-unified-computing-system)
      - [Benefits](#benefits)
    - [9. Cisco Nexus Switches](#9-cisco-nexus-switches)
      - [Characteristics](#characteristics)
    - [Cisco IOS vs NX-OS](#cisco-ios-vs-nx-os)
  - [Cisco Product Categories](#cisco-product-categories)
  - [Relationship Between Cisco Products](#relationship-between-cisco-products)
  - [Key Concepts](#key-concepts)
  - [My Takeaways](#my-takeaways)

## Overview

Cisco products beyond routers and switches include firewalls, wireless systems, collaboration tools, and data center equipment. These notes group them by function.

## Cisco Product Portfolio

### 1. Cisco ASA (Adaptive Security Appliance)

The **Cisco ASA** is Cisco's enterprise firewall solution.

#### Primary Functions

- Network firewall
- Stateful packet inspection
- VPN termination
- Access control
- Network Address Translation (NAT)

#### Purpose

Protects internal networks by filtering traffic entering and leaving the organization.

---

### 2. Cisco FirePower IPS

Cisco's **Intrusion Prevention System (IPS)** is called **FirePower** (originally from Sourcefire).

#### Deployment Options

- Dedicated appliance
- Software module
- Hardware module inside Cisco ASA

#### Functions

- Intrusion detection
- Intrusion prevention
- Threat intelligence
- Malware detection
- Advanced attack protection

> Modern Cisco deployments commonly integrate FirePower directly into the ASA firewall.

---

### 3. Cisco Wireless Solutions

Cisco provides enterprise wireless infrastructure consisting of:

- Wireless LAN Controller (WLC)
- Wireless Access Points (AP)

#### Wireless LAN Controller (WLC)

A centralized controller that manages multiple wireless access points.

Responsibilities include:

- Centralized AP management
- Wireless configuration
- Security policies
- Firmware updates
- Roaming management

#### Wireless Access Point (AP)

Provides Wi-Fi connectivity for wireless clients.

#### Why Use a WLC?

Instead of configuring each AP individually:

```text
Without WLC

AP1
AP2
AP3
AP4

Configure individually
```

```text
With WLC

           WLC
        /   |   \
      AP1 AP2 AP3 AP4

Centralized Management
```

Benefits:

- Easier administration
- Better scalability
- Consistent configuration
- Simplified maintenance

## Cisco Collaboration Products

Cisco also provides solutions for voice, video, and online collaboration.

### 4. Cisco Unified Communications Manager (CUCM)

**Cisco Unified Communications Manager (CUCM)** is Cisco's IP-based PBX (Private Branch Exchange).

#### Purpose

Manages enterprise VoIP (Voice over IP) systems.

Functions include:

- Call routing
- Extension management
- Voicemail integration
- Phone registration
- Call control

#### Traditional PBX vs IP PBX

| Traditional PBX | Cisco CUCM |
|-----------------|------------|
| Analog phone system | IP-based phone system |
| Dedicated phone wiring | Uses IP network |
| Limited scalability | Highly scalable |

---

### 5. Cisco IP Phones

Cisco manufactures enterprise IP phones designed to work with CUCM.

Features include:

- VoIP calling
- Caller ID
- Conference calls
- Call forwarding
- Voicemail integration

---

### 6. Cisco TelePresence

Cisco TelePresence provides enterprise-grade video conferencing systems.

#### Features

- High-definition video
- High-quality audio
- Large conference room support
- Real-time collaboration

Purpose:

Enable face-to-face meetings between geographically distributed teams.

---

### 7. Cisco Webex

Cisco Webex is Cisco's cloud collaboration platform.

Common uses:

- Online meetings
- Video conferencing
- Screen sharing
- Team collaboration
- Remote work

Webex is widely used for hybrid and remote workplaces.

## Cisco Data Center Products

Cisco also develops products specifically for modern data centers.

### 8. Cisco UCS (Unified Computing System)

Cisco UCS is Cisco's server platform.

Available as:

- Blade servers
- Rack servers

#### Benefits

- High performance
- Virtualization support
- Centralized management
- Scalable computing

Cisco expanded beyond networking by offering compute resources through UCS.

---

### 9. Cisco Nexus Switches

Cisco Nexus switches are designed specifically for data center environments.

#### Characteristics

- High-performance switching
- Low latency
- Data center optimized
- Supports virtualization
- High availability

### Cisco IOS vs NX-OS

| Cisco IOS | Cisco NX-OS |
| ------------ | ------------- |
| Enterprise routers & switches | Data center switches |
| Runs on Catalyst series | Runs on Nexus series |
| Traditional enterprise networks | Data center environments |
| CLI commands | Very similar CLI commands |

> Learning Cisco IOS makes transitioning to NX-OS relatively easy because the command syntax is largely similar.

## Cisco Product Categories

| Category | Product | Purpose |
|----------|----------|---------|
| Security | ASA | Enterprise firewall |
| Security | FirePower IPS | Intrusion prevention |
| Wireless | Wireless LAN Controller | Centralized AP management |
| Wireless | Access Point | Wi-Fi connectivity |
| Collaboration | CUCM | IP PBX / VoIP management |
| Collaboration | Cisco IP Phone | Enterprise VoIP phone |
| Collaboration | TelePresence | Video conferencing |
| Collaboration | Webex | Online meetings & collaboration |
| Data Center | UCS | Enterprise servers |
| Data Center | Nexus Switch | Data center switching |

## Relationship Between Cisco Products

```text
                    Cisco Solutions

        ┌───────────────┬────────────────┬────────────────┐
        │               │                │
     Security       Wireless       Collaboration
        │               │                │
   ASA Firewall      WLC          Cisco CUCM
   FirePower IPS      APs          IP Phones
                                     Webex
                                 TelePresence

                    │
                    ▼

               Data Center
               ├── UCS Servers
               └── Nexus Switches
```

## Key Concepts

Use the category table above to compare product roles; the individual sections explain their functions and deployment context.

## My Takeaways

For revision, distinguish the enterprise IOS and data-center NX-OS contexts, then use the product categories to place security, wireless, and collaboration functions. Similar CLI syntax is useful background, but it does not establish identical platform behavior.
