# VTP: VLAN Trunking Protocol

## Overview

VLAN Trunking Protocol (VTP) distributes VLAN database information between switches. It can reduce repeated VLAN creation, renaming, and deletion across a campus.

VTP does not assign access ports to VLANs or configure trunk interfaces. Those port-level settings still need local configuration.

The lecture uses the traditional server/client/transparent model and revision-number behavior associated with VTP versions 1 and 2. It does not supply a version-selection command; the behavior should not be generalized to every VTP version.

## What VTP Synchronizes

If Engineering and Sales VLANs are created on a VTP server, participating clients learn those VLAN definitions. Subsequent supported database changes are distributed too.

| Task | Distributed by VTP in this model? |
| --- | --- |
| Create or delete a VLAN | Yes. |
| Change a VLAN's name | Yes. |
| Put a PC-facing port into the Engineering VLAN | No. |
| Make an inter-switch interface a trunk | No. |
| Set an interface's native VLAN | No. |

Changing from VLAN 10 to VLAN 100 also requires appropriate local port assignments. VTP synchronization does not move the attached PCs into a new VLAN ID automatically.

## VTP Modes

| Mode | Local VLAN changes | Learns the shared VLAN database | Role |
| --- | --- | --- | --- |
| Server | Can add, edit, and delete VLANs. | Yes, from accepted newer domain information. | Maintains and advertises the shared database. |
| Client | Cannot directly add, edit, or delete VLANs. | Yes. | Uses the synchronized database. |
| Transparent | Can change its own local VLAN database. | No. | Keeps its VLAN configuration independent while forwarding advertisements in the demonstrated setup. |

Server mode is the default on the switches in this lab. A server can synchronize from another server with newer revision information; it is not permanently authoritative merely because its mode is server.

The lecture calls the highest-revision copy the master. In this version 1/2 discussion, treat that as database freshness, rather than a separate configured primary-server role. [Cisco: understanding VTP](https://www.cisco.com/c/en/us/support/docs/lan-switching/vtp/10558-21.html)

### Transparent Mode and Transit Traffic

```text
[VTP server] == [VTP transparent] == [VTP client]
     |                  |                  |
Create VLANs       Create local VLANs   Learn shared VLANs
manually           manually            from advertisements

VTP advertisements pass through the middle switch in the demo.
Its own VLAN database does not synchronize.
```

Forwarding a VTP advertisement and forwarding user traffic for an advertised VLAN are different operations. The transparent switch still needs the user VLAN in its own local database to carry that VLAN's traffic.

Transparent forwarding has version-specific rules. The independent local database is the key behavior illustrated here; the transcript does not establish a version for its demonstration. [Cisco: VTP modes and transparent forwarding](https://www.cisco.com/c/en/us/support/docs/lan-switching/vtp/10558-21.html)

## Domain and Configuration Revision

The VTP domain groups switches that synchronize VLAN information. The lecture's theory example uses `flackbox`; the demo explicitly configures `Flackbox`. The lab commands below consistently use the demo spelling.

```text
Switch(config)# vtp domain Flackbox
Switch(config)# vtp mode server
```

Alternative mode commands are:

```text
Switch(config)# vtp mode client
Switch(config)# vtp mode transparent
```

Choose the intended mode; these alternatives are not a sequence to apply to every switch.

The revision number identifies the version of the VLAN configuration. A higher accepted revision can replace an older database. It does not prove that the incoming database is correct for production.

### Risk When Connecting an Existing Switch

The lecture describes an old switch whose database lacks the production Engineering and Sales VLANs but has a higher revision. If introduced into the matching VTP domain over a participating trunk, its information can remove those VLANs from other switches.

That can disconnect the hosts that depend on them. Inspect the incoming switch's domain, operating mode, revision, and VLAN database before connecting it to an existing VTP environment.

The revision-number risk is not limited to a switch labeled server; version 1/2 client switches also require revision checks before being introduced. [Cisco: VTP configuration guidelines](https://www.cisco.com/c/en/us/td/docs/switches/lan/catalyst_microswitches/software/releases/15_2_8_e/configuration_guide/vlan/b_1528e_vlan_cms_cg/configuring_vtp.html)

If DTP is also used, the lecture requires matching VTP domain names on the neighboring switches for dynamic trunk formation. Explicit trunk configuration avoids relying on that negotiation.

## Verification Commands

```text
Switch# show vtp status
Switch# show vlan brief
```

Use `show vtp status` to inspect the domain, VTP operating mode, and configuration revision. Use `show vlan brief` to verify that the expected VLANs actually exist and that access ports have their intended assignments.

Neither command alone proves end-to-end connectivity.

## Transcript Lab: Server, Transparent, and Client

The demo uses the same three-switch chain, with trunks already configured and native VLAN 199 created on each switch:

```text
[SW1: Server] == [SW2: Transparent] == [SW3: Client]
    Domain: Flackbox                  Domain: Flackbox

SW1 access ports:                    SW3 access ports:
Fa0/1-2: Engineering, VLAN 10         Fa0/1-2: Sales, VLAN 20
Fa0/3: Sales, VLAN 20                Fa0/3: Engineering, VLAN 10
```

Initially, Engineering and Sales VLANs and their access-port assignments have not been configured. The demo reports all switches initially in server mode with no domain name. Results below are from the supplied transcript; no lab was executed while writing the notes.

### 1. Inspect the Starting State

```text
SW1# show running-config
SW1# show vlan brief
SW1# show vtp status
```

Check that trunks already exist and VLAN 199 is present. The production VLANs 10 and 20 are not yet present.

### 2. Configure SW3 as a Client

```text
SW3# configure terminal
SW3(config)# vtp domain Flackbox
SW3(config)# vtp mode client
SW3(config)# end
SW3# show vtp status
```

The output should identify the intended domain and client mode.

### 3. Configure SW2 as Transparent

```text
SW2# show vtp status
SW2# configure terminal
SW2(config)# vtp mode transparent
SW2(config)# end
SW2# show vtp status
```

The demonstration reports that SW2 has already learned the domain name from its neighbor before this change. Its VLAN database becomes independent when transparent mode is selected.

### 4. Configure SW1 and Create the Production VLANs

```text
SW1# configure terminal
SW1(config)# vtp domain Flackbox
SW1(config)# vtp mode server
SW1(config)# vlan 10
SW1(config-vlan)# name Eng
SW1(config-vlan)# exit
SW1(config)# vlan 20
SW1(config-vlan)# name Sales
SW1(config-vlan)# end
SW1# show vlan brief
```

In the demo, SW1 has also learned the domain name already, and server mode was its existing default. Explicit commands make the intended settings clear.

After the VLAN additions:

| Switch | Database outcome reported in the demo |
| --- | --- |
| SW1, server | VLANs 10 and 20 exist because they were created locally. |
| SW2, transparent | VLANs 10 and 20 are still absent. |
| SW3, client | VLANs 10 and 20 appear through synchronization. |

### 5. Configure Access Ports Locally

On SW1:

```text
SW1# configure terminal
SW1(config)# interface range FastEthernet0/1 - 2
SW1(config-if-range)# switchport mode access
SW1(config-if-range)# switchport access vlan 10
SW1(config-if-range)# exit
SW1(config)# interface FastEthernet0/3
SW1(config-if)# switchport mode access
SW1(config-if)# switchport access vlan 20
SW1(config-if)# end
```

On SW3:

```text
SW3# configure terminal
SW3(config)# interface range FastEthernet0/1 - 2
SW3(config-if-range)# switchport mode access
SW3(config-if-range)# switchport access vlan 20
SW3(config-if-range)# exit
SW3(config)# interface FastEthernet0/3
SW3(config-if)# switchport mode access
SW3(config-if)# switchport access vlan 10
SW3(config-if)# end
```

These port settings are still required even though SW3 learned the VLAN definitions through VTP.

### 6. Diagnose the Failed End-to-End Ping

ENG1 on SW1 tries to reach ENG3 at `10.10.10.12` on SW3. The ping fails even though both endpoint switches have VLAN 10 and the correct access ports.

```text
ENG1 -- [SW1: VLAN 10 exists]
                    ||
        [SW2: VLAN 10 missing]       Traffic cannot pass
                    ||
        [SW3: VLAN 10 learned] -- ENG3, 10.10.10.12
```

SW2 forwarded the VTP advertisements but did not learn their VLAN definitions. Create the required VLANs locally:

```text
SW2# configure terminal
SW2(config)# vlan 10
SW2(config-vlan)# name Eng
SW2(config-vlan)# exit
SW2(config)# vlan 20
SW2(config-vlan)# name Sales
SW2(config-vlan)# end
SW2# show vlan brief
```

### 7. Verify User Traffic

Allow the VLANs and forwarding state to become ready, then repeat the host tests.

| Test | Result reported in the demo |
| --- | --- |
| ENG1 on SW1 to ENG3 at 10.10.10.12 on SW3 | Succeeds after the VLANs are created on SW2. |
| SALES1 on SW3 to SALES3 at 10.10.20.12 on SW1 | Succeeds. |
| Sales PC to an Engineering PC | Fails because the topology has no inter-VLAN router. |

The first Engineering test initially times out during convergence, then succeeds. A working VTP database does not remove the need for user-traffic tests through every transit switch.

## My Takeaways

- Keep VLAN distribution separate from access-port and trunk configuration.
- A newer revision can contain the wrong database; inspect reused switches before joining them to the domain.
- Transparent mode preserves local control, so transit VLANs still need local creation.
- A client learning VLANs through a middle switch does not prove that the middle switch can forward those VLANs' user traffic.
- Same-VLAN connectivity across switches remains separate from routing between VLAN subnets.
