# Cisco IOS System Image and Configuration Backup & Restoration

## Overview

Back up the IOS image (`.bin`) and configuration files (`running-config` / `startup-config`) before changes that may require recovery. The lesson shows external storage through TFTP, FTP, or USB, plus local configuration copies in Flash.

## Key Concepts

### Off-Box vs. On-Box Storage

- **Off-Box Backups (TFTP/FTP/USB):** Keep a copy outside the device so it remains available if the device or its storage fails.
- **On-Box Backups (Flash):** Keep a named local copy for lab rollback or configuration reference. It can be lost with the device.

### The Configuration Merging Trap

A major operational mistake is attempting to restore a previous configuration by directly copying it straight into an active `running-config` or `startup-config` on an already configured device.

- Cisco IOS **merges** the incoming lines with the existing runtime parameters instead of overwriting them.
- When merging into `running-config`, commands missing from the backup can remain active, leaving a configuration that differs from the backup.

### Pure Replacement Methodology

The demonstrated restore procedure uses `write erase`, copies the backup into `startup-config`, and runs `reload` to load it without the previous running settings.

## How It Works

### Backing Up and Restoring From Local Flash

```text
  BACKUP WORKFLOW (Saving baseline state before risky testing)
  [ Running-Config (RAM) ] ------------ 1. copy run flash:R1-Lab ------------> [ Flash Memory ]
  
  THE CONFIGURATION CHANGES (Risky lab modifications executed)
  [ Running-Config (RAM) ] ---> Hostname altered to R2 ---> Saved to NVRAM via 'copy run start'
  
  RESTORATION WORKFLOW (Systematic Override Pattern)
  Step 1: [ NVRAM Storage Block ] <--------- 2. write erase (Clears startup-config)
  Step 2: [ Flash Memory (R1-Lab) ] -------- 3. copy flash:R1-Lab startup-config --------> [ NVRAM Storage Block ]
  Step 3: [ Device Processor ] <------------- 4. reload (Wipes dirty RAM, pulls clean file)
```

## Components / Structure

### IOS Backup System Syntax Matrix

The `copy` command takes the source first, then the destination: `copy <source_filesystem> <destination_filesystem>`.

| Command Operation | Source Location | Target Destination | Core Technical Purpose |
| --- | --- | --- | --- |
| `copy flash tftp` | Local Flash Memory | External Network Server | Exports the heavy OS operating binary (`.bin`) file off-box for recovery. |
| `copy running-config tftp` | Volatile System RAM | External Network Server | Creates a point-in-time network text snapshot of active configurations. |
| `copy startup-config usb` | Non-Volatile NVRAM | Physical USB Media Stick | Exports baseline startup scripts directly onto physical localized storage. |
| `copy running-config flash` | Volatile System RAM | Local Flash Memory Space | Generates a rapid local checkpoint file for rollback actions. |
| `copy flash startup-config` | Local Flash Memory Space | Non-Volatile NVRAM | Loads an archived local configuration file directly into the boot sector. |

## Comparison

### Backup Destinations Profile Evaluation

| Feature / Factor | Local Flash Memory | External Network Server (TFTP / FTP) |
| --- | --- | --- |
| **Recovery Domain Scope** | Restrained to software rollback actions. | Full hardware disaster failure recovery. |
| **Network Reliance** | Zero; operates entirely internal to the device. | High; requires active Layer 3 paths and sockets. |
| **IOS Image Security** | Redundant; the file is already active inside Flash. | High; provides an archive if local flash is corrupted. |
| **File Identification** | Requires unique string tags (e.g., `R1-Lab`). | Best managed with automated date string nomenclature. |

## Commands (If Applicable)

### Cisco IOS

#### 1. Backing Up the Operating System Image to a Network Target

```text
Router# show flash
Directory of flash:/
  1  -rw-  33591764  <BUG_CHECK_KEY>  c2900-universalk9-mz.SPA.151-4.M4.bin

Router# copy flash tftp
Source filename []? c2900-universalk9-mz.SPA.151-4.M4.bin
Address or name of remote host []? 10.10.10.10
Destination filename [c2900-universalk9-mz.SPA.151-4.M4.bin]? 
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
[OK - 33591764 bytes]
```

#### 2. Creating a Timestamped Configuration File Backup to a TFTP Server

```text
Router# copy running-config tftp
Address or name of remote host []? 10.10.10.10
Destination filename [Router-confg]? R1-2026-07-07-Config
!!
[OK - 1042 bytes]
```

#### 3. Generating an On-Box Lab Checkpoint File and Executing the Pure Replacement Restore Sequence

```text
! Step A: Build a local safe backup entry inside local Flash memory
Router# copy running-config flash:R1-Baseline

! [Assume experimental testing changes the system configurations and maps unsafe parameters]

! Step B: Avoid the Merge Trap by executing an explicit baseline factory purge
Router# write erase
Erasing the nvram filesystem will remove all configuration files! Continue? [confirm]

! Step C: Map the secure flash file directly back into the initialization slot
Router# copy flash:R1-Baseline startup-config
Destination filename [startup-config]? 

! Step D: Cycle the device state to apply clean parameters without leftover strings
Router# reload
Proceed with reload? [confirm]
```

## Example

### The Configuration Merge Failure Scenario

The router's running configuration contains an unwanted interface description:

```text
! Active Running Configuration currently in RAM:
interface FastEthernet0/0
 description Link facing Untrusted Public Edge
```

An engineer tries to restore a backup file named `R1-Safe` from Flash *without* running a factory reset first. The `R1-Safe` file contains:

```text
! Content of flash:R1-Safe
interface FastEthernet0/0
 ip address 10.10.10.1 255.255.255.0
```

The engineer executes a direct copy merge sequence:

```text
Router# copy flash:R1-Safe running-config
```

#### The Corrupted Mismatch Result

If you inspect the interface configuration, you will find that the configuration has been merged instead of overwritten:

```text
interface FastEthernet0/0
 description Link facing Untrusted Public Edge
 ip address 10.10.10.1 255.255.255.0
```

*Result:* The description `Link facing Untrusted Public Edge` remains after the merge because the incoming file does not remove it. Copying into `running-config` has not replaced the full configuration.

## Important Notes

- Include the hostname and date in backup names, such as `R1-2026-07-07-1400`, so copies are easier to identify.
- **Flash Space Capacity Verification:** Before backing up multiple configuration checkpoints or alternative IOS revisions to local Flash memory, verify available space by executing `show flash`. Storing excess files can fill up local storage, preventing the router from unzipping core operating kernels.
- After a transfer, inspect the destination directory or `show flash` and check the file size.

## My Takeaways

- Cisco IOS system configuration restorations merge parameters by default when imported directly into active operational slots.
- The lab's erase-and-reload procedure avoids retaining unwanted lines from the previous running configuration.
- Keep an external backup for recovery after device or storage failure.
- Local Flash copies are useful checkpoints during configuration labs.
- Use `copy <source> <destination>` in that order.
- There is no operational value in archiving a Cisco IOS `.bin` operating system file back onto its own local Flash memory array where it already resides.
- Configuration text files are smaller than IOS images and generally take less time to transfer.
- Check connectivity and completion when transferring an IOS image.
- Use dates such as `YYYY-MM-DD` to distinguish backup versions.
- Performing a full system reboot (`reload`) after staging a restored `startup-config` file ensures that the device starts up with a clean, validated configuration state.
