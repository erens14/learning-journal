# CCNA Self Notes: Factory Reset and Password Recovery

## Overview

Factory reset removes saved configuration; password recovery restores access while retaining it. The procedures serve different purposes.

- The lab's **Factory Reset** erases the saved configuration so the next normal boot starts without those settings.
- **Password Recovery** uses the **Configuration Register** to boot without loading the saved configuration. The lab then restores that configuration, replaces the forgotten password, and returns the register to its normal setting.

## Key Concepts

### NVRAM Filesystem Wiping (`write erase`)

After the saved configuration is erased, the device starts the Setup Wizard on its next normal boot in this example.

### The Configuration Register

A 16-bit software register stored in non-volatile memory that dictates how the router behaves during a system boot cycle (e.g., where it looks for an IOS image, what baud rate it utilizes, or whether it parses configuration states).

### The Break Sequence

The lesson sends **`Ctrl + Break`** through the console during the first 60 seconds of boot to enter ROMMON. This describes the demonstrated recovery procedure.

### Enable Secret vs. Enable Password Precedence

- `enable password`: A legacy configuration statement that stores credentials in a vulnerable plaintext format.
- `enable secret`: A modern configuration statement that hashes passwords securely using cryptographic algorithms. If both are active simultaneously, the `enable secret` statement completely overrides the legacy password string.

## How It Works

### Password Recovery Architectural Pipeline Workflow

```text
[ Lost Access Status ] ---> 1. Hard Reboot Device & Press 'Ctrl + Break' within 60 seconds.
                                 |
                                 v
[ ROMMON Emergency Prompt ] -> 2. Modify Register to bypass NVRAM: 'confreg 0x2142'
                               3. Reload system environment: 'reset'
                                 |
                                 v
[ Blank Active State ] ------> 4. Type 'no' to skip Setup Wizard. Enter Privileged EXEC mode: 'enable'
                                 |
                                 v
[ CRITICAL MERGE PHASE ] ----> 5. Merge backup parameters to active memory:
                                  'copy startup-config running-config'
                                  (*Crucial: Prevents catastrophic data wiping!*)
                                 |
                                 v
[ Active Original Config ] --> 6. Overwrite credential block: 'enable secret <new_password>'
                               7. Restore default boot register: 'config-register 0x2102'
                               8. Commit changes to persistent disk: 'copy running-config startup-config'
                                 |
                                 v
[ Recovery Verified ] -------> 9. Perform final 'reload' to ensure operational integrity.
```

## Components / Structure

### Crucial Configuration Register Bit Mappings

The lesson uses three hexadecimal configuration-register values:

| Register Value | Operational Boot Behavior | Typical Administrative Use Case |
| --- | --- | --- |
| **`0x2102`** | **Standard Default Boot.** Loads the system IOS image from Flash and parses the `startup-config` from NVRAM into RAM. | Normal production environment baseline state. |
| **`0x2120`** | **Direct ROMMON Boot.** Forces the device boot loop to halt immediately and jump straight into low-level ROM Monitor mode. | Advanced system level debugging or localized baseline component testing. |
| **`0x2142`** | **Bypass NVRAM Configuration.** Forces the router to completely ignore the `startup-config` file during initialization. | Emergency password recovery sequences for locked devices. |

## Comparison

### Factory Reset vs. Password Recovery Processes

| Metric / Parameter | Factory Reset | Password Recovery |
| --- | --- | --- |
| **Primary Core Objective** | Permanently erases all historical device configurations. | Preserves active configuration architecture while replacing lost passwords. |
| **Command-Line Entry Tool** | `write erase` (Privileged EXEC Mode). | `confreg 0x2142` (ROMMON Boot Mode). |
| **Saved configuration** | Erases the saved configuration in this procedure. | Preserves the saved configuration while booting without loading it. |
| **Risk** | Recovery requires a backup of settings that were erased. | Saving before restoring the old configuration can overwrite it. |

## Commands (If Applicable)

### Cisco IOS (Standard Production Mode)

```text
! Executing a absolute system factory reset
Router# write erase
Erasing the nvram filesystem will remove all configuration files! Continue? [confirm]
Router# reload
Proceed with reload? [confirm]

! Re-establishing normal default booting constraints within configuration sub-mode
Router# configure terminal
Router(config)# config-register 0x2102
Router(config)# end
Router# copy running-config startup-config
```

### Cisco IOS (ROMMON Recovery Mode)

```text
! Configure the register to skip the NVRAM startup parsing chain
rommon 1 > confreg 0x2142

! Reboot the system processor core dynamically
rommon 2 > reset
```

## Example

### Comprehensive Password Recovery Script Simulation

Below is the complete transcript showing the recovery process on a router with a lost enable secret password:

```text
ROMMON info: Readonly ROMMON initialized.
rommon 1 > confreg 0x2142
rommon 2 > reset

--- System Configuration Dialog ---
Would you like to enter the initial configuration dialog? [yes/no]: no

Router> enable
Router# 

! CRITICAL STEP: Merge the saved production configuration into active RAM
Router# copy startup-config running-config
Destination filename [running-config]? 
874 bytes copied in 0.42 secs

! Notice the prompt immediately returns to its original configured hostname
Production-R1# configure terminal
Production-R1(config)# enable secret NewSecurePass123

! CRITICAL STEP: Restore the configuration register to normal boot mode
Production-R1(config)# config-register 0x2102
Production-R1(config)# end

! Save the modifications permanently
Production-R1# copy running-config startup-config
Building configuration...
[OK]

! Execute a final safety validation check reload
Production-R1# reload
```

## Important Notes

- Load the saved configuration with `copy startup-config running-config` before changing and saving the password. Otherwise, `copy run start` can overwrite the saved settings with the mostly empty recovery configuration.
- If both `enable password` and `enable secret` exist, removing the secret can leave the old enable password in effect. Set a new known secret rather than only removing the old one.
- Restore `0x2102` after recovery. Leaving `0x2142` set causes subsequent boots to ignore the saved configuration in this procedure.

## My Takeaways

- The lab uses `write erase` to erase the saved configuration before reloading.
- Unsaved changes in RAM (`running-config`) can be discarded during an administrative lockout by power-cycling the system to restore the last saved configuration state.
- The configuration register controls boot behavior through hexadecimal settings.
- Setting the configuration register to `0x2142` lets you log into the device with a blank runtime configuration while keeping the original file untouched in NVRAM.
- The `Ctrl + Break` keyboard shortcut intercepts the boot sequence within its first minute, dropping the session directly down into low-level ROMMON mode.
- ROMMON uses `confreg`; standard IOS uses `config-register`.
- Always copy the startup-config into the running-config during recovery to pull back the existing interface layouts, crypto parameters, and IP routes.
- Statically configuring a new `enable secret` automatically overwrites any old, forgotten credentials hidden inside the imported active configuration file.
- Resetting the configuration register back to `0x2102` at the end of password recovery is required to ensure the router loads its configuration normally on the next boot.
- After recovery, reboot as shown in the lab and verify that the saved configuration and new password work.
