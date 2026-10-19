# Basic Router and Switch Configuration

## Overview

This lab configures router interfaces for their local subnets and a Layer 2 switch SVI for management access. It also sets hostnames, interface descriptions, and the switch's default gateway.

## Key Concepts

### Default Gateway Mapping

For any network node to communicate outside its immediate local subnet, it requires a designated default gateway. On local host segments, this address maps directly to the active physical IP address of the connected router interface.

### Switched Virtual Interface (SVI)

A Switch Virtual Interface (SVI) gives the Layer 2 switch a management IP address. The lab uses **VLAN 1** rather than assigning an IP address to a physical switchport.

### Administrative Isolation

The management IP and default gateway let the switch communicate with administrators on other subnets. They do not enable Layer 3 forwarding of user traffic on this Layer 2 switch.

## How It Works

### Interface Initialization and SVI Logic Workflow

```text
    [ Router R1 ] (Physical Router)
     |
     +--- Interface Fa0/0 (Physical Layer 3 Boundary)
          IP: 192.168.0.1/24 (Serves as default gateway for local segment)
          State: Admin Shutdown by Default (Requires 'no shutdown')
     |
     v (Physical Ethernet Cable Line Link)
     |
    [ Switch SW1 ] (Layer 2 Infrastructure)
     |
     +--- Interface Fa0/1 (Physical Access Port Layer 2 - Assigned to VLAN 1)
     |    State: Enabled / Up by default
     |
     +--- Interface VLAN 1 (Switched Virtual Interface - SVI)
          Management IP: 192.168.0.10/24
          IP Default Gateway Target: 192.168.0.1
```

1. Select the router interface (`interface FastEthernet0/0`), assign its address, and enable it with `no shutdown`.
2. Assign the switch's management IP to `interface vlan 1`, matching the VLAN used by the lab's access ports.
3. Configure `ip default-gateway` with the local router's address so the switch can reply to administrators on other subnets.

## Components / Structure

### IOS Configuration Boundary Elements

| Configuration Parameter | Target Device Type | Interface Layer Scope | Core Purpose |
| --- | --- | --- | --- |
| **Physical IP Assignment** | Router | Layer 3 Physical (e.g., `Fa0/0`) | Defines the regional broadcast domain boundary and acts as a localized gateway. |
| **Switched Virtual Interface (SVI)** | Layer 2 Switch | Layer 3 Logical Virtual (`VLAN 1`) | Generates a management host personality for inbound network administrative queries. |
| **IP Default Gateway** | Layer 2 Switch | Global Configuration Mode | Instructs the management plane where to route return management frames heading across subnets. |
| **Interface Description** | Router & Switch | Individual Port Sub-Mode | Appends human-readable labels to ports to streamline diagnostic tracking during failures. |

## Comparison

### Initial Interface Characteristics

| Feature / Behavior | Cisco Router Interfaces | Cisco Layer 2 Switch Ports |
| --- | --- | --- |
| **Default Power State** | **Shutdown** (Administrative Down; requires explicit activation). | **No Shutdown** (Enabled and ready to process links by default). |
| **IP Address Support** | Direct structural IP assignment directly on physical ports. | Disallows physical IP binding; requires logical SVI configuration. |
| **Subnet Capacity** | Supports unique, separate subnets across every active interface. | Restrained to a single operational management IP address zone across the hardware profile. |
| **Primary role** | Routes traffic between subnets. | Switches local frames; its IP address is for management. |

## Commands (If Applicable)

### Cisco IOS

#### 1. Initial Router Interface Configuration

```text
Router# configure terminal
Router(config)# interface FastEthernet0/0
Router(config-if)# ip address 192.168.0.1 255.255.255.0

! Critical step: Router interfaces are disabled by default
Router(config-if)# no shutdown
Router(config-if)# exit

```

#### 2. Initial Switch Management and Identification Configuration

```text
Switch# configure terminal

! Immediate prompt transformation prevents pasting mistakes to unintended systems
Switch(config)# hostname SW1

! Define Management SVI interface parameters
SW1(config)# interface vlan 1
SW1(config-if)# ip address 192.168.0.10 255.255.255.0
SW1(config-if)# no shutdown
SW1(config-if)# exit

! Map the exit path for out-of-subnet administrative tracking
SW1(config)# ip default-gateway 192.168.0.1

! Append a clear label description to the physical link interface
SW1(config)# interface FastEthernet0/1
SW1(config-if)# description Link to R1
SW1(config-if)# end
```

## Example

### Validation Lab Scenario: Local Subnet Verification

The lab uses these addresses:

* **Router R1 Interface Fa0/0:** `192.168.0.1`
* **Switch SW1 SVI Management:** `192.168.0.10`

Test reachability from the switch CLI:

```text
SW1# ping 192.168.0.1
Type escape sequence to abort.
Sending 5, 100-byte ICMP Echos to 192.168.0.1, timeout is 2 seconds:
!!!!!
Success rate is 100 percent (5/5), round-trip min/avg/max = 1/2/4 ms
```

*Result:* The example ping reaches the router. The `ip default-gateway 192.168.0.1` setting provides the switch's next hop for destinations outside `192.168.0.0/24`; this local ping alone does not verify remote management access.

## Important Notes

* **Strict Subnet Formatting:** Cisco IOS does not accept classless inter-domain routing shorthand notations (like `/24`) on the interface command line. Every subnet parameter must be expanded into a complete **Dotted Decimal** mask (e.g., `255.255.255.0`).
* Check administrative state and use `no shutdown` on interfaces intended to be active.
* Set a recognizable `hostname` and check the prompt before pasting device configuration.

## My Takeaways

* Routers must hold distinct, separate IP subnet allocations across each individual physical port interface to fulfill their core routing responsibilities.
* Layer 2 switch IP configurations exist solely to manage the infrastructure device itself, not to route transit data frames across user networks.
* Assigning an `ip default-gateway` on a Layer 2 switch ensures administrative management frames can successfully cross subnet boundaries to reach remote engineers.
* Custom hostnames provide immediate visual confirmation on the console terminal, preventing costly configuration paste errors across open workspace windows.
* Interface descriptions help identify the device or link at the other end during troubleshooting.
