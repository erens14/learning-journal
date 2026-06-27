# Cisco IOS

---

## Connecting to a Cisco Device

Cisco devices are commonly managed using **PuTTY**.

---

## SSH vs Telnet

**SSH (Secure Shell)**

* Encrypted communication
* Recommended for enterprise environments

**Telnet**

* Unencrypted
* Not recommended for production environments

---

## AAA

Enterprise environments typically authenticate users through a centralized **AAA server**.

AAA stands for:

* Authentication
* Authorization
* Accounting

---

## Network Management Methods

### Out-of-Band Management

Uses a dedicated management network separate from the production network.

Advantages:

* More secure
* Still accessible when the production network is unavailable

---

### In-Band Management

Uses the same network as normal user traffic.

---

## Initial Connection

Cisco devices do not have a default IP address.

During the initial setup, administrators usually connect through a console cable before assigning an IP address.

Common console cable types:

* Serial DB9 → RJ45
* USB → Mini-USB (newer devices)

For USB console cables:

1. Install the appropriate driver.
2. Open **Device Manager**.
3. Check the assigned COM port.
4. Connect using PuTTY.

---

# Basic Cisco CLI Commands

| Command                          | Description                                         |                                                 |
| -------------------------------- | --------------------------------------------------- | ----------------------------------------------- |
| `enable`                         | Enter Privileged EXEC mode                          |                                                 |
| `disable`                        | Return to User EXEC mode                            |                                                 |
| `configure terminal` or `conf t` | Enter Global Configuration mode                     |                                                 |
| `exit`                           | Exit one configuration level                        |                                                 |
| `end`                            | Return directly to Privileged EXEC mode             |                                                 |
| `do`                             | Execute privileged commands from Configuration mode |                                                 |
| `                                | `                                                   | Filter command output using regular expressions |

---

# Configuration Management

## Save Running Configuration

After making configuration changes, save them permanently:

```bash
copy running-config startup-config
```

or simply:

```bash
copy run start
```

---

## Erase Startup Configuration

Older Cisco devices:

```bash
write erase
```

Newer Cisco devices:

```bash
erase startup-config
```

---

## Backup Configuration

Save the running configuration into Flash memory:

```bash
copy running-config flash:<filename>
```

Example:

```bash
copy running-config flash:backup-config
```

View stored files:

```bash
show flash
```

---

# My Takeaways

* SSH should always be preferred over Telnet because it encrypts management traffic.
* Always save the running configuration after making changes to prevent configuration loss after a reboot.