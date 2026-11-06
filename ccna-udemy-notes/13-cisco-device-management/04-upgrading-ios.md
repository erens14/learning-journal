# CCNA Self Notes: Cisco IOS System Image Upgrade

## Overview

This lesson upgrades a Cisco IOS image (`.bin`) by copying it from a TFTP server into Flash, selecting it with `boot system`, saving the configuration, and reloading. Keeping the previous image provides a fallback in the demonstrated setup.

## Key Concepts

### Cisco Software Download Portal

The official, secure repository (`software.cisco.com`) where administrators locate and acquire authentic Cisco IOS image binaries tailored strictly to specific hardware product families and feature sets.

### TFTP Image Staging

The demonstrated transfer uses a local host running a TFTP server to hold the downloaded image.

### Multi-Image Flash Cohabitation

If Flash has enough space, the device can retain the previous IOS image alongside the new one for rollback.

### Boot System Selection Pointer

A global configuration command that selects the image to load on the next boot.

## How It Works

### Step-by-Step Operating System Upgrade Workflow

```text
 [ Admin Workstation ]            [ TFTP Server ]                 [ Cisco Catalyst Switch ]
(software.cisco.com)               (10.10.10.10)                        (10.10.10.2)
          |                              |                                    |
          |--- 1. Download IOS .bin ---->|                                    |
          |       (Version 15.0)         |                                    |
          |                              |                                    |
          |                              |<-- 2. Execute: copy tftp flash ----|
          |                              |       Target IP: 10.10.10.10       |
          |                              |       File: c2960-lanbase-15.0.bin |
          |                              |                                    |
          |                              |====== 3. File Transfer Layer =====>|
          |                                                                   | (Saves binary alongside
          |                                                                   |  legacy 12.2 firmware)
          |                                                                   |
          |                                                                   |-- 4. Define Boot Path:
          |                                                                   |      'boot system flash:...'
          |                                                                   |-- 5. Commit & Reset:
          |                                                                   |      'copy run start'
          |                                                                   |      'reload'
          |                                                                   |
          |                                                                   | (Decompresses 15.0 image
          |                                                                   |  into Volatile RAM memory)
```

1. Download the correct IOS image from Cisco, check its checksum, and place it in the TFTP server directory.
2. Run `show flash` on the switch to inspect stored images and free space.
3. Transfer the image using `copy tftp flash`.
4. Use `boot system flash:` to select the new image.
5. Save the configuration, run `reload`, and verify the running version after boot.

## Components / Structure

### IOS Image Upgrade Management Tactics

| Upgrade Deployment Strategy | Technical Execution Path | Primary Benefit | Core System Risk Factor |
| --- | --- | --- | --- |
| **Replace the old image** | Delete the old file with `delete flash:<old_file>`, then transfer the new image. | Frees space for the new image. | Leaves no local fallback if the replacement cannot boot. |
| **Keep both images** | Retain the old image and select the new one with `boot system`. | Preserves the previous image for rollback. | Requires enough Flash space for both files. |

## Comparison

### Firmware State Inspection Parameters

| Parameter Attributes | Initial Pre-Upgrade System Baseline | Post-Upgrade System Runtime State |
| --- | --- | --- |
| **Active OS Runtime Layer** | Legacy environment framework (e.g., Version 12.2). | Modern system release (e.g., Version 15.0). |
| **Flash Directory Index** | Contains only the singular original factory binary asset file. | Houses both the original legacy system binary and the newly transferred file asset. |
| **Boot-image selection** | With no explicit boot-system entry, selection depends on the platform's default boot process and available images. | An explicit boot-system entry selects the intended image filename, subject to platform support and image availability. |
| **RAM Operating Mirror** | Runs the uncompressed legacy system kernel framework. | Runs the uncompressed updated system kernel framework. |

## Commands (If Applicable)

### Cisco IOS

#### 1. Verifying Storage Capacity and Firmware Baselines

```text
Switch# show flash
Directory of flash:/
  1  -rw-   4412342  c2960-lanbase-mz.122-25.FX.bin
32514048 bytes total (28101706 bytes free)

Switch# show version
Cisco IOS Software, C2960 Software (C2960-LANBASE-M), Version 12.2(25)FX
```

#### 2. Executing the Inbound Network Binary File Transfer

```text
Switch# copy tftp flash
Address or name of remote host []? 10.10.10.10
Source filename []? c2960-lanbase-mz.150-1.SE.bin
Destination filename [c2960-lanbase-mz.150-1.SE.bin]? 
Accessing tftp://10.10.10.10/c2960-lanbase-mz.150-1.SE.bin...
Loading c2960-lanbase-mz.150-1.SE.bin from 10.10.10.10: !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
[OK - 4671234 bytes]
```

#### 3. Re-Mapping the System Initialization Path Pointer

```text
Switch# configure terminal
Switch(config)# boot system flash:c2960-lanbase-mz.150-1.SE.bin
Switch(config)# end

! CRITICAL STEP: Commit the boot pointer change to NVRAM before reloading
Switch# copy running-config startup-config
Switch# reload
Proceed with reload? [confirm]
```

## Example

### Validation Lab Scenario: Successful Switch OS Migration

The lab uses these transfer settings:

* **TFTP Server IP:** `10.10.10.10`
* **Target Switch IP:** `10.10.10.2`
* **Target File:** `c2960-lanbase-mz.150-1.SE.bin`

After the switch reloads, inspect the stored images and running version:

```text
Switch# show flash
Directory of flash:/
  1  -rw-   4412342  c2960-lanbase-mz.122-25.FX.bin
  2  -rw-   4671234  c2960-lanbase-mz.150-1.SE.bin

Switch# show version
Cisco IOS Software, C2960 Software (C2960-LANBASE-M), Version 15.0(1)SE
```

*Result:* The example `show flash` output lists both images. The `show version` output identifies Version 15.0 as running after the boot-image change.

## Important Notes

* Save the `boot system` change with `copy run start` before reloading, or the device will use its previously saved boot settings.
* **Storage Allocation Auditing:** Always ensure the device has enough free space before transferring a new image. Running out of flash storage mid-transfer can result in a corrupted, incomplete file copy.
* In the shown `boot system flash:filename` syntax, keep the colon immediately after `flash`.

## My Takeaways

* Cisco IOS updates require transferring files across the network from an external TFTP repository directly into the target device's internal Flash storage.
* The lab demonstrates booting the remaining image after deleting the old one. Check saved boot settings before relying on that behavior elsewhere.
* Keeping a legacy image alongside a new one inside Flash memory provides a valuable safety net for quick rollbacks if bugs appear in production.
* The `boot system flash:filename` command lets engineers point the bootloader to a specific target image, bypassing the default behavior of loading the first file found.
- Selecting a boot image does not activate it immediately; the lab reloads the switch to run the new image.
- Check `show flash` for stored files and `show version` for the image actually running.
- IOS image filenames identify the platform, feature set, and file format in these examples.
* If a device has multiple operating system files in its flash storage and no custom boot pointer is configured, it defaults to loading the first valid `.bin` file it encounters.
* Use Packet Tracer to practice the demonstrated transfer and boot-image selection steps.
* Save a dated configuration backup before an upgrade so the previous settings are available for recovery.
