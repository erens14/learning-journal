# Router and Switch Boot Up Process

## Overview

The boot process checks hardware, loads Cisco IOS, and applies the saved configuration. These notes describe the memory used at each stage and the lab's ROMMON recovery procedure when an IOS image is missing.

## Key Concepts

### Power-On Self Test (POST)

A diagnostic program that runs at power-on to check hardware such as the CPU, memory, and interfaces.

### Image Decompression

Cisco IOS system images (`.bin` files) are stored in Flash memory in a compressed archive format (similar to a ZIP file). During the boot cycle, the bootstrap system decompresses this file and copies the raw operational kernel directly into RAM.

### ROMMON (ROM Monitor Mode)

ROMMON provides a low-level recovery prompt (`rommon>`). The lesson uses it to recover a missing IOS image and introduces its role in password recovery.

### Volatile vs. Non-Volatile Memory

- **Volatile Memory:** Temporary working space (RAM) that requires continuous power to retain its data state. Turning off the device completely erases its content.
- **Non-Volatile Memory:** ROM, Flash, and NVRAM retain their contents without power.

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
| **ROM** *(Read-Only Memory)* | Hardware Chip | Non-Volatile | Stores POST diagnostics and bootstrap code. |
| **Flash Memory** | Internal / Compact Card | Non-Volatile | Stores Cisco IOS image files (`.bin`). |
| **NVRAM** *(Non-Volatile RAM)* | Internal Battery-Backed | Non-Volatile | Stores the permanent backup system configurations (`startup-config`). |
| **RAM** *(Random Access Memory)* | Standard Dynamic Module | **Volatile** | Holds the active `running-config` and decompressed IOS image in this boot model. |

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

### Example 1: Recovering the Last Saved Configuration

An administrator shuts down the interface used for remote management and loses access:

```text
Switch(config)# interface fastEthernet 0/1
Switch(config-if)# shutdown
! Connectivity lost. Administrator can no longer reach or manage the device.
```

**Recovery in this example:** The change was not saved to `startup-config`. A local restart discards the unsaved `running-config` and loads the previous saved configuration. The restart also interrupts service and discards any other unsaved changes.

### Example 2: Lab Demo - Accidental IOS Deletion and TFTP ROMMON Recovery

- **Lab Topology:** Router R1 (`10.10.10.1`) connects through Switch SW1 (`10.10.10.2`) to a TFTP server (`10.10.10.10`) holding the IOS image.
- **The Incident:** An engineer unintentionally removes the active operating system image file from R1's Flash via `delete flash:` and executes a system restart:

```text
Router-R1# delete flash:c2900-universalk9-mz.SPA.151-4.M4.bin
Router-R1# reload
```

- **Failure:** After the reload, the bootstrap cannot find an IOS image in Flash and enters ROMMON:

```text
ROMMON info: Readonly ROMMON initialized.
boot: cannot open "flash:"
rommon 1 > 
```

- **Recovery:** Configure temporary network parameters in ROMMON, download the image from TFTP, and restart:

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

- In the demonstrated boot model, IOS runs from RAM after loading. Deleting its Flash image does not stop that running copy, but the missing image becomes a problem at the next boot.
- **The Setup Wizard Trigger:** If a router boots up and can find its IOS image but finds an empty NVRAM slot with no `startup-config` file, it assumes it is a factory-fresh unit and fires up the interactive System Configuration Dialog.
- **The `vlan.dat` Exception:** While standard interface policies go into NVRAM, Layer 2 switches track their virtual domain database settings in a separate file called `vlan.dat`. Depending on the explicit product platform family, this file stores itself inside **Flash storage** or NVRAM independently.
- Network-based boot or recovery depends on a working path to the TFTP server. A failed link can prevent the image from loading.

## My Takeaways

- ROM supplies POST and bootstrap code in the boot sequence shown here.
- Flash stores the IOS image; RAM holds the running copy in this example.
- Save configuration changes with `copy run start` if they should survive a reboot.
- In the missing-image lab, ROMMON provides the network settings and TFTP commands needed to restore IOS.
