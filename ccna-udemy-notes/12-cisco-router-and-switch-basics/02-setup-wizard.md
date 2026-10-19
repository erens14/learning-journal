# CCNA Self Notes: Cisco System Configuration Dialog (Setup Wizard)

## Overview

The Cisco System Configuration Dialog (**Setup Wizard**) asks questions to create an initial configuration. The lesson shows it starting without a saved configuration and being launched manually from privileged EXEC mode.

## Key Concepts

### Automated Initial Provisioning

An out-of-the-box or freshly wiped Cisco device has no hostname or interface IP definitions. The Setup Wizard builds an interactive questionnaire to generate these settings without requiring deep familiarity with standard IOS syntax rules.

### Defensive Credential Layering

The wizard forces the configuration of administrative access keys:

- **Enable Secret:** An encrypted password string required to access privileged EXEC mode (`enable`). This takes operational precedence over the standard password.
- **Enable Password:** A legacy, plaintext/unencrypted privileged access password. It is generally unused if an Enable Secret is defined but is still prompted by the wizard script.
- **Virtual Terminal (VTY) Password:** The baseline password constraint regulating inbound remote management access streams like Telnet or SSH.

### SVI Management Constraints on Switches

On the lab's Layer 2 switch, the wizard assigns the management IP to the **VLAN 1 SVI** rather than a physical switchport.

## How It Works

### Setup Wizard Execution Timeline

```text
[ Device Boot / Empty NVRAM ] 
               |
               v
  "Would you like to enter the initial configuration dialog? [yes/no]" ---> Choose: yes
               |
               v
  "Would you like to enter basic management setup? [yes/no]" -----------> Choose: yes
               |
               v
  [ Enter Administrative Strings: Hostname -> Enable Secret -> VTY Passwords ]
               |
               v
  [ Select Management Interface (e.g., Fa0/0 or VLAN 1) -> Configure IP & Mask ]
               |
               v
  [ Review Command Line Summary Output ]
               |
               v
  [ Final Prompt Choices ]
       ├── [0] Go to CLI prompt without saving configuration.
       ├── [1] Return back to setup wizard start to adjust fields.
       └── [2] Save configuration to NVRAM and exit to CLI. ---> Choose: 2
```

## Components / Structure

### Parameters Required by the Setup Wizard Questionnaire

| Wizard Prompt Parameter | Scope / Definition | Default Value Behavior |
| --- | --- | --- |
| **Hostname** | Establishes the text label identifier for the device system prompt. | Shown in trailing brackets `[Router]` or `[Switch]`. |
| **Enable Secret** | Configures an encrypted password string for the `enable` boundary. | No default; mandatory manual user entry string. |
| **Enable Password** | Legacy unencrypted authentication string. | No default; mandatory entry (fallback layer). |
| **Virtual Terminal Password** | Secures incoming remote network sessions (VTY lines). | No default; dictates Telnet/SSH clearance. |
| **Management Interface** | Pinpoints which slot handles remote administration. | Prompts listing of all available physical/logical interfaces. |
| **IP Address & Subnet Mask** | Configures Layer 3 address parameters to allow remote access. | Subnet masks default based on address class brackets. |

## Comparison

| Metric / Parameter | Setup Wizard Configuration (`setup`) | Manual CLI Configuration (`config t`) |
| --- | --- | --- |
| **Interface** | Step-by-step prompts. | Commands entered directly. |
| **Real-World Preference** | Uniformly avoided by production network deployment groups. | Universally preferred choice for enterprise engineering. |
| **Error Resiliency** | Requires restarting the loop if errors are summarized at the end. | Immediate correction via typing the negative `no` prefix form of commands. |
| **Feature Accessibility** | Restricted to basic naming, passwords, and a single management IP. | Grants access to advanced security, routing protocols, and VLAN segment mappings. |

## Commands (If Applicable)

### Cisco IOS

#### 1. Invoking the Setup Wizard Manually

```text
Router# setup
--- System Configuration Dialog ---
Would you like to enter the initial configuration dialog? [yes/no]: yes

```

#### 2. Manual Remediation Required After Switch Setup Wizard Ends

The switch wizard shown here omits the default gateway. Add it in global configuration mode:

```text
Switch# configure terminal
Switch(config)# ip default-gateway 192.168.0.1
Switch(config)# end
```

#### 3. Verifying the Path Remotely from an End Client Node

```text
Router-R1# telnet 192.168.0.10
Trying 192.168.0.10 ... Open
User Access Verification
Password: <Type Virtual Terminal Password Here>
SW1>
```

## Example

### Router Initial Setup Transcript Simulation

```text
--- System Configuration Dialog ---
Would you like to enter the initial configuration dialog? [yes/no]: yes
Would you like to enter basic management setup? [yes/no]: yes

Enter system name [Router]: R1
Enter enable secret: Flackbox1
Enter enable password: Flackbox2
Enter virtual terminal password: Flackbox3
Configure SNMP Network Management? [yes/no]: no

Current interface summary:
Interface                  IP-Address      OK? Method      Status
FastEthernet0/0            unassigned      YES unset       administratively down
FastEthernet0/1            unassigned      YES unset       administratively down

Enter interface name used to connect to the management network from the above list: FastEthernet0/0
Configuring interface FastEthernet0/0:
Use the 100 BaseTX (full-duplex) mode? [yes]: yes
Configure IP on this interface? [yes]: yes
Configure IP address for this interface [192.168.0.1]: 192.168.0.1
Configure Subnet mask for this interface [255.255.255.0]: 255.255.255.0

[0] Go to the IOS command prompt without saving this config.
[1] Return back to the setup program without saving this config.
[2] Save this configuration to nvram and exit.

Enter your selection [2]: 2
Building configuration...
[OK]
```

## Important Notes

- These notes cover the wizard's prompts and defaults; manual configuration is an alternative.
- The switch wizard shown here configures the SVI but omits `ip default-gateway`. Add the gateway separately for management traffic to other subnets.
- Answer `no` at the initial setup question to continue to the standard user EXEC prompt (`Router>`).

## My Takeaways

- The System Configuration Dialog boots automatically on empty or factory-reset NVRAM arrays, and can be manually loaded using the `setup` execution command.
- Pressing the Enter key during the questionnaire automatically accepts whichever parameter value is presented inside the trailing brackets `[ ]`.
- The script forces administrators to define an Enable Secret (encrypted MD5/SHA) and an Enable Password (plaintext legacy) to establish standard secure device baselines.
- Layer 2 switch implementations map wizard addresses onto logical Switched Virtual Interfaces (SVIs) since individual switch access ports lack direct Layer 3 attributes.
- In the displayed menu, option `2` saves the generated configuration to NVRAM and exits the wizard.
