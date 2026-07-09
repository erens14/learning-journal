# Router and Switch Boot Up Process

## Overview

Every Cisco router and switch relies on a multi-stage boot up process to initialize its hardware, load its operating system (Cisco IOS), and apply its configurations. Understanding how a device boots requires deep familiarity with its four distinct internal memory locations. Misconfiguring these layers or experiencing storage corruption can halt operations, making memory diagnostics and disaster recovery procedures—such as ROMMON-based TFTP restoration—critical skills for network engineers.

## Key Concepts

### Power-On Self Test (POST)

A diagnostic program embedded within the hardware that runs immediately upon receiving power. It verifies the functionality of essential physical components like the CPU, memory modules, and interface ports.

### Image Decompression

Cisco IOS system images (`.bin` files) are stored in Flash memory in a compressed archive format (similar to a ZIP file). During the boot cycle, the bootstrap system decompresses this file and copies the raw operational kernel directly into RAM.

### ROMMON (ROM Monitor Mode)

A low-level, primitive operating system sub-mode that executes when a device cannot locate a valid Cisco IOS image in its Flash storage. It presents a `rommon>` command line prompt and is used primarily for password recovery and factory disaster mitigation.

### Volatile vs. Non-Volatile Memory

- **Volatile Memory:** Temporary working space (RAM) that requires continuous power to retain its data state. Turning off the device completely erases its content.
- **Non-Volatile Memory:** Persistent permanent storage arrays (ROM, Flash, NVRAM) that securely preserve stored data strings through power cycles, reboots, and outages.

## How It Works

### The Cisco IOS Step-by-Step Boot Sequence Flow

```text
+-----------------------+
|  1. Power On Device   |
+-----------+-----------+
            |
            v
+-----------------------+
|   2. Execute POST     | ---> Executed by ROM to check physical hardware health
+-----------+-----------+
            |
            v
+-----------------------+
| 3. Load Bootstrap Code| ---> Loaded from ROM to look for an OS system image
+-----------+-----------+
            |
            v
+-----------------------+        +-----------------------+
|  4. Locate/Load IOS   | ---->  |   FAILS TO FIND IOS   |
+-----------+-----------+        +-----------+-----------+
            | (Decompresses from             |
            |  Flash into RAM)               v
            |                    +-----------------------+
            |                    |   Enter ROMMON Mode   | ---> Recovery via USB/TFTP
            |                    +-----------------------+
            v
+-----------------------+
| 5. Load Configuration |
+-----------+-----------+
            |
            +---- Found in NVRAM ----> Loads saved startup-config into RAM
            |
            +---- Empty/Missing -----> Launches interactive System Setup Wizard
```

## Components / Structure

### Internal Memory Locations and Roles

| Memory Location | Type | Persistence | Primary Function and Loaded Files |
| --- | --- | --- | --- |
| **ROM** *(Read-Only Memory)* | Hardware Chip | Non-Volatile | Stores the POST diagnostics and the initial baseline bootstrap code wrapper. |
| **Flash Memory** | Internal / Compact Card | Non-Volatile | Stores the massive Cisco IOS operating system system binary image files (`.bin`). |
| **NVRAM** *(Non-Volatile RAM)* | Internal Battery-Backed | Non-Volatile | Stores the permanent backup system configurations (`startup-config`). |
| **RAM** *(Random Access Memory)* | Standard Dynamic Module | **Volatile** | Active operational arena containing the live `running-config` and unzipped IOS kernel. |

## Comparison

### Startup-Config vs. Running-Config Profiles

| Parameter Baseline | Startup-Config | Running-Config |
| --- | --- | --- |
| **Storage Location** | NVRAM (Non-Volatile RAM) | RAM (Random Access Memory) |
| **Persistence Across Reboots** | Yes, data survives a device shutdown. | No, data is completely wiped during power loss. |
| **Modification Execution** | Static; requires manual copy commands to update values. | Dynamic; typing a configuration command alters RAM instantly. |
| **System State Role** | Dictates device settings for the next boot cycle. | Manages active interfaces, routing tables, and frames right now. |

## Commands (If Applicable)

### Cisco IOS (Standard Mode)

```text
! View the content, image sizes, and available capacity inside Flash storage
Router# show flash

! Review the baseline software releases and hardware components loaded from ROM/RAM
Router# show version

! Erase a specific IOS system image from the local storage structure
Router# delete flash:c2900-universalk9-mz.SPA.151-4.M4.bin

! Manually trigger a system restart sequence
Router# reload
```

### Cisco IOS (ROMMON Recovery Mode)

*Note: Environment variables in ROMMON are case-sensitive and must be written exactly as shown below.*

```text
rommon 1 > IP_ADDRESS=10.10.10.1
rommon 2 > IP_SUBNET_MASK=255.255.255.0
rommon 3 > DEFAULT_GATEWAY=10.10.10.10
rommon 4 > TFTP_SERVER=10.10.10.10
rommon 5 > TFTP_FILE=c2900-universalk9-mz.SPA.151-4.M4.bin
rommon 6 > tftpdnld
rommon 7 > reset
```

## Example

### Example 1: Utilizing RAM Volatility as an Administrative Safety Net

An administrator logs onto a remote switch to perform advanced interface changes. While modifying the lines, a critical command error breaks connectivity, locking the engineer out of the CLI console:

```text
Switch(config)# interface fastEthernet 0/1
Switch(config-if)# shutdown
! Connectivity lost. Administrator can no longer reach or manage the device.
```

**The Mitigation Path:** Because the changes were made in RAM (`running-config`) but never committed to NVRAM (`startup-config`), the local site coordinator can simply pull out the physical power cable and plug it back in. The switch reboots, wipes the broken RAM runtime configuration, pulls the clean `startup-config` from NVRAM, and restores the configuration state before the error.

### Example 2: Lab Demo - Accidental IOS Deletion and TFTP ROMMON Recovery

- **Lab Topology:** Router R1 (`10.10.10.1`) connects to Switch SW1 (`10.10.10.2`) and an external TFTP Server (`10.10.10.10`) harboring production software image storage files.
- **The Incident:** An engineer unintentionally removes the active operating system image file from R1's Flash via `delete flash:` and executes a system restart:

```text
Router-R1# delete flash:c2900-universalk9-mz.SPA.151-4.M4.bin
Router-R1# reload
```

- **The Failure Symptom:** Upon reboot, the bootstrap loader fails to identify a valid boot target file in Flash, halting the initialization path and dropping the interface into an unconfigured emergency line prompt:

```text
ROMMON info: Readonly ROMMON initialized.
boot: cannot open "flash:"
rommon 1 > 
```

- **The Recovery Path:** Because the router is completely unconfigured at this stage, the engineer must manually build a layer 3 networking profile directly within ROMMON to communicate with the TFTP server, download the file back into Flash, and restart the device:

```text
rommon 1 > IP_ADDRESS=10.10.10.1
rommon 2 > IP_SUBNET_MASK=255.255.255.0
rommon 3 > DEFAULT_GATEWAY=10.10.10.10
rommon 4 > TFTP_SERVER=10.10.10.10
rommon 5 > TFTP_FILE=c2900-universalk9-mz.SPA.151-4.M4.bin
rommon 6 > tftpdnld

Invoke this command only to erase the current contents of flash memory
and download the specified image from the TFTP server.
Do you wish to continue? y
Receiving c2900-universalk9-mz.SPA.151-4.M4.bin from 10.10.10.10 !!!!!!
File reception successful.

rommon 7 > reset
```

## Important Notes

- **RAM Runtime Runtime Immunity:** Deleting an active `.bin` image out of Flash storage does *not* instantly crash a running router. Because the operating system executes entirely from its decompressed RAM mirror copy, the device functions perfectly until it is reloaded or suffers a power loss.
- **The Setup Wizard Trigger:** If a router boots up and can find its IOS image but finds an empty NVRAM slot with no `startup-config` file, it assumes it is a factory-fresh unit and fires up the interactive System Configuration Dialog.
- **The `vlan.dat` Exception:** While standard interface policies go into NVRAM, Layer 2 switches track their virtual domain database settings in a separate file called `vlan.dat`. Depending on the explicit product platform family, this file stores itself inside **Flash storage** or NVRAM independently.
- **TFTP Booting Risks:** Although Cisco IOS allows downloading boot images and startup configurations over the network from an external TFTP server, doing so introduces a single point of failure. If the local network link drops during a power flap, the device becomes a brick until the connection is restored.

## My Takeaways

- ROM functions as the immutable engine ignition system, checking hardware via POST and loading the bootstrap sequence before passing control to Flash.
- Flash storage behaves like a hard drive inside a computer, providing permanent storage for heavy Cisco IOS system operating files.
- Cisco IOS software compressed binaries automatically unarchive themselves into RAM during initialization, rendering the system immune to local Flash deletions until the next hardware reboot.
- RAM updates operational variables instantly as commands are typed, requiring engineers to explicitly commit those changes to NVRAM via the `copy run start` command to make them permanent.
- Dropping into a `ROMMON` prompt indicates a critical lack of operational firmware, which can be mitigated by configuring temporary networking environment parameters to pull recovery images from an adjacent TFTP server.
