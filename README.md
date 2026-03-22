# Table of Contents

- [DIY Home Server](#diy-home-server)
- [Hardware](#hardware)
  - [Lenovo ThinkPad T430 (Main Server)](#lenovo-thinkpad-t430-main-server)
  - [HP ProBook 455 G2 (Testing Machine)](#hp-probook-455-g2-backup-server)
- [Operating System](#operating-system)
  - [Initial Plan](#initial-plan)
  - [Final Approach](#final-approach)
- [Network](#network)
  - [Solution: DHCP Reservation (Static Local IP)](#solution-dhcp-reservation-static-local-ip)
  - [Network Schema](#network-schema)
- [Laptop Power Configuration](#laptop-power-configuration)
  - [Lid Configuration](#lid-configuration)
  - [Disable Sleep / Suspend](#disable-sleep--suspend)
  - [Battery Configuration](#battery-configuration)
  - [Wake-on-LAN (WoL)](#wake-on-lan-wol)

- [Server Setup & Services](#server-setup--services)
  - [Common Setup](#common-setup)
    - [SSH — Remote Server Access](#ssh--remote-server-access)
    - [System Monitoring Tools](#system-monitoring-tools)
  - [ThinkPad Server Setup (Main Server)](#thinkpad-server-setup-main-server)
      - [Storage Layout](#storage-layout)
      - [Storage Permissions](#storage-permissions)
      - [Samba — Network File Sharing (NAS)](#samba--network-file-sharing-nas)
        <!-- - [Installation](#installation)
        - [User setup](#user-setup)
        - [Configuration](#configuration)
        - [Configuration Explanation](#configuration-explanation) -->

# DIY Home Server

This repository documents my journey of building and configuring a DIY home server.

I decided to create this server because I had a couple of old laptops that were just sitting unused. Instead of letting them collect dust, I repurposed them into a small home server environment.

This repo contains the commands, configurations, and notes from the setup process.  
Later I plan to add explanations, screenshots, and short videos.

---

# Hardware

Currently using two machines as part of this DIY server setup. The system is built around a **primary server** and a **secondary backup server**.

## Lenovo ThinkPad T430 (Main Server)

![ThinkPad T430 - Photo 1](photos/TP_photo_1.jpg)
![ThinkPad T430 - Photo 2](photos/TP_photo_2.jpg)

- CPU: Intel i5-3320M  
- RAM: 8 GB DDR3  
- Storage: 500 GB SATA III SSD  
- 1 Gbps NIC with support for Wake on Lan

This machine acts as the **main server**, as it has better performance and significantly more storage available. It hosts the primary services of the system and runs most applications through Docker containers.

## HP ProBook 455 G2 (Backup Server)

![HP ProBook 455 G2 - Photo 1](photos/HP_photo_1.jpg)
![HP ProBook 455 G2 - Photo 2](photos/HP_photo_2.jpg)

- CPU: AMD A8-7100  
- RAM: 8 GB DDR3  
- Storage: 120 GB SATA III SSD  
- 1 Gbps NIC with support for Wake on Lan

This machine acts as a **backup server**. The **HP ProBook struggles with performance and has limited storage**, so it is mainly used for storing **backups of important data**. 
---

# Operating System

![Debian](photos/fastfetch.jpg)

The server currently runs:

- **Debian 13 Stable (Trixie)**

### Initial Plan

My initial plan was to run **Proxmox** and structure the system with:

- 1 **Debian VM** running Docker conatiners
- several **LXC containers** for different services

### Final Approach

The hardware was **not suitable for a full virtualization stack**. Running Proxmox, a VM, and multiple containers would have added too much overhead on machine with limited CPU and RAM.

Instead, I installed **Debian 13 Stable directly on the ThinkPad T430 (bare metal)**.

The system was installed using a **minimal setup with no desktop environment**, since:

- the server is managed entirely through **SSH**
- a graphical interface is **not necessary**
- avoiding a GUI saves **RAM and CPU resources**

---

# Network

In most home networks, devices receive their **local IP address dynamically** through DHCP.  
This means the router automatically assigns an available IP address to each device when it connects to the network.

In order to access the server or any of its services, you need to know its local IP address.  
This can be retrieved either from the server itself or from the router’s admin panel, which can be annoying.

### Solution: DHCP Reservation (Static Local IP)

I chose to create a **DHCP reservation from the router**, which always assigns the **same IP address to each server based on its MAC address**.

> Note: It is also possible to set a static IP manually on the server itself, but using the router simplifies management.

Router configuration example:

![DHCP Reservation Example](photos/DHCP_reservation.jpg)

In my setup, the router is configured to always assign the same IP address for each server.

### Network Schema

For now, I only have a **single Wireless Router** handling all roles.
> **Note:** In the future, I plan to separate these functions into specialized devices:
>
> - **Gigabit switch** for wired connections  
> - **Custom router** running OPNsense or pfSense 
> - **Access Point** for WiFi
Router and server setup:

![Servers and Router](photos/setup_photo.jpg)

Below is an **ASCII diagram** illustrating the layout of the whole network:

```
               ISP
                │
               WAN
        ┌─────────────────────────────────┐
        │         Wireless Router         │
        │---------------------------------│
        │ WAN                             │
        │ LAN0                            │
        │ LAN1                            │
        │ LAN2                            │
        │ WiFi                            │
        └─────────────────────────────────┘
          LAN0   LAN1  LAN2    WiFi
           │      │      │      │
           │      │      │      ├─device0
           │      │      │      ├─device1
           │      │      │      ├─device2    
           │      │      │      ├─device3    
           │      │      │      └─deviceN    
           │      │      │          
           │      │      │
           │      │      └── My Laptop
           │      │
           │      └── HP Server
           │
           └── ThinkPad Server
```

---

# Laptop Power Configuration

Since the server runs on a **laptop (ThinkPad T430)** instead of traditional server hardware, a few adjustments are necessary.

Laptops are designed to prioritize **power saving and efficiency**, which can interfere with a system intended to run **continuously as a server**.

The following configurations ensure the laptop stays powered on even when the lid is closed, prevents sleep/suspend states, allows remote power-on, and helps preserve battery health.

---

## Lid Configuration

Prevent the laptop from sleeping when the lid is closed.

Edit:

```
/etc/systemd/logind.conf
```

Uncomment and modify the following parameters:

![logind.conf configuration](photos/logind.png)

Restart the service:

```bash
sudo systemctl restart systemd-logind
```

---

## Disable Sleep / Suspend

Disable all sleep targets to ensure the server remains active.

```bash
sudo systemctl mask sleep.target suspend.target hibernate.target hybrid-sleep.target
```

---

## Battery Configuration

Limit battery charging to **80%** to reduce long-term battery wear.

```bash
echo 80 | sudo tee /sys/class/power_supply/BAT0/charge_control_end_threshold
```

> **Note:** Battery device names (for example `BAT0`) and configuration paths may differ depending on the laptop model and hardware configuration.

> **Note:** Some laptops may not support limiting battery charge at the hardware/firmware level, meaning this feature might not be available on all systems.

> **Note:** The link below includes additional methods and troubleshooting steps if this method does not work on a specific system.

Reference:

https://ubuntuhandbook.org/index.php/2024/02/limit-battery-charge-ubuntu/

---

## Wake-on-LAN (WoL)

Wake-on-LAN allows the server to be **powered on remotely** by sending a *magic packet* to its network interface.

> **Important:** Wake-on-LAN must first be **enabled in the system BIOS/UEFI**.

Before configuring WoL, identify the **network interface name** and **MAC address**:

```bash
ip a
```

This command lists all network interfaces. From here you can find:

- the **network interface name** (for example `enp1s0`)
- the **MAC address** used for Wake-on-LAN

The MAC address can also usually be found in the **router's admin panel** under the list of connected devices.

Install the required tool:

```bash
sudo apt install ethtool
```

Enable WoL on the network interface:

```bash
sudo ethtool -s enp1s0 wol g
```

To make this persistent after reboot, create a systemd service:

```bash
sudo nano /etc/systemd/system/wol-enable.service
```

Service configuration:

```
[Unit]
Description=Configure Wake-up on LAN
After=network-online.target

[Service]
Type=oneshot
ExecStart=/sbin/ethtool -s enp1s0 wol g

[Install]
WantedBy=basic.target
```

Enable the service:

```bash
sudo systemctl enable wol-enable.service
```

The server can then be powered on remotely using:

```bash
wakeonlan <MAC_ADDRESS>
```

<!-- Example WoL demonstration: -->

<!-- ![Wake-on-LAN demo](videos/wol_demo.mp4) -->

> **Note:** There are multiple ways to configure Wake-on-LAN depending on the system, network interface, and distribution. The reference below includes alternative approaches and troubleshooting information.

Reference:

https://www.thelinuxvault.net/blog/how-to-wake-on-lan-supported-host-over-the-network-using-linux/

---

# Server Setup & Services

This section covers the core services and configurations that transform the machines into a functional servers.

The setup is divided into three parts:

- **Common setup** applied to both servers
- **ThinkPad server setup** for the main server
- **HP server setup** for the backup server

---

## Common Setup

The following configurations are applied to **both servers**.

They provide:

- **Remote management** (SSH)
- **Basic system monitoring tools**

---

### SSH — Remote Server Access

SSH allows the server to be managed remotely from another machine through the terminal.

#### Installation

Install the SSH server:

```bash
sudo apt install openssh-server
```

Enable and start the service:

```bash
sudo systemctl enable ssh
sudo systemctl start ssh
```

#### Connecting to the Server

From another machine on the network, connect using the following command.  
In my case:

```bash
ssh dev@192.168.0.109
```

Where:

- `dev` is the username on the server  
- `192.168.0.109` is the server's local IP address

For **Linux and Windows**, I usually connect directly from the **terminal** using the command shown above.

For **Android**, I use the **Termius** SSH client to connect to the servers.

| | |
|---|---|
| ![Termius Home Page](photos/termius1.jpg) | ![Termius session](photos/termius2.jpg) |

---

### System Monitoring Tools

Some lightweight tools are installed to quickly inspect system information and resource usage.

#### fastfetch

Displays system information.

```bash
sudo apt install fastfetch
```

Run:

```bash
fastfetch
```

#### btop

Interactive resource monitor.

```bash
sudo apt install btop
```

Run:

```bash
btop
```

#### htop

Alternative terminal system monitor.

```bash
sudo apt install htop
```

Run:

```bash
htop
```

---

## ThinkPad Server Setup (Main Server)

The **ThinkPad T430** acts as the **main server** in this setup.

It is responsible for:

- running **Docker services**
- providing **network storage (NAS)** via Samba
- storing application data and media

---

### Storage Layout

Before setting everything up, I defined a directory structure to clearly separate:

- **Docker configurations**
- **shared data (NAS)**
- **service-specific data**

Planned layout:

```
/
├── srv
│   └── docker
│       └── navidrome
│           └── docker-compose.yml
│
└── data
    ├── shares
    │   └── media
    │       └── music
    │
    └── services
        └── navidrome
            ├── navidrome.db
            └── cache
```

This structure keeps:

- configs in `/srv/docker`
- user-accessible files in `/data/shares`
- service data isolated in `/data/services`

---

### Storage Permissions

To keep permissions clean and manageable, I created a dedicated **group for storage access** and configured a shared directory.

#### Create storage group and configure permissions

```bash
sudo groupadd storage
sudo usermod -aG storage dev
sudo chown -R root:storage /data
sudo chmod -R 2775 /data
```

Explanation:

- `storage` → shared group for file access  
- `dev` → added to the group  
- `/data` → main shared directory  
- `2775` → ensures new files inherit the group

---

### Samba — Network File Sharing (NAS)

Samba is used to expose the `/data` directory to other devices on the network.

I chose **Samba (SMB)** instead of **NFS** because I access the server from multiple operating systems:

- **Linux**
- **Windows**
- **Android**

SMB is natively supported on all of these platforms, making it a more flexible choice.  
NFS is more common in Linux-only environments, but requires additional setup or third-party tools on Windows and Android.

#### Installation

```bash
sudo apt update
sudo apt install samba
```

Enable and start the service:

```bash
sudo systemctl enable smbd
sudo systemctl start smbd
```

Check status:

```bash
sudo systemctl status smbd
```

---

#### User setup

Enable Samba access for the user:

```bash
sudo smbpasswd -e dev
```

---

#### Configuration

Edit the Samba configuration file:

```bash
sudo nano /etc/samba/smb.conf
```

Add the following:

```
[global]
server string = DebiServ
workgroup = WORKGROUP
security = user
map to guest = Bad User

[data]
path = /data
force user = dev
force group = storage
create mask = 0664
force create mode = 0664
directory mask = 0775
force directory mode = 0775
browseable = yes
writable = yes
guest ok = no
read only = no
```


---

#### Configuration Explanation

- `[global]` → general server settings  
- `server string` → server name shown on the network  
- `workgroup` → Windows workgroup (default: WORKGROUP)  
- `security = user` → requires authentication  
- `map to guest = Bad User` → unknown users are treated as guests  

---

- `[data]` → shared folder definition  
- `path = /data` → directory being shared  
- `force user / group` → ensures consistent ownership of files  
- `create mask = 0664` → file permissions (rw-rw-r--)  
- `directory mask = 0775` → directory permissions (rwxrwxr-x)  
- `browseable = yes` → visible on the network  
- `writable = yes` → allows writing  
- `guest ok = no` → disables anonymous access  
- `read only = no` → allows modifications  

---

> **Note:** I recommend creating the Samba configuration from scratch instead of modifying the default file.  
> This helps keep the configuration clean and avoids unnecessary or confusing defaults.
>
> You can keep the original file as a reference by renaming it:
>
> ```bash
> sudo mv /etc/samba/smb.conf /etc/samba/smb.conf.old
> ```
>
> Then create a new configuration file:
>
> ```bash
> sudo nano /etc/samba/smb.conf
> ```

---

Apply changes:

```bash
sudo systemctl restart smbd
```

---

<!-- #### Accessing the NAS from different devices

**Linux**
![Linux NAS Access](photos/linux_nas.jpg)

**Windows**
![Windows NAS Access](photos/windows_nas.jpg)

**Android**
![Android NAS Access](photos/android_nas.jpg)

--- -->
