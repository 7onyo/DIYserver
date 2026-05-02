# Table of Contents

- [DIY Home Server](#diy-home-server)
- [Hardware](#hardware)
  - [Lenovo ThinkPad T430 (Main Server)](#lenovo-thinkpad-t430-main-server)
  - [HP ProBook 455 G2 (Backup Server)](#hp-probook-455-g2-backup-server)
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
      - [Navidrome — Self-Hosted Music Streaming](#navidrome--self-hosted-music-streaming)
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

 #### Accessing the NAS from different devices

**Linux**
![Linux NAS Access](photos/sambaLinux.png)

**Windows**
![Windows NAS Access](photos/sambaWindows.png)

**Android**
<p align="center">
  <img src="photos/sambaAndroid.jpg">
</p>

--- 

### Navidrome — Self-Hosted Music Streaming

**Navidrome** is a lightweight self-hosted music server and web-based player.

It allows streaming your personal music library from:

- web browser
- Android apps
- Subsonic-compatible clients
- other devices on the network

Official documentation:

https://www.navidrome.org/docs/installation/docker/

---

#### My Music Library

My personal music collection is stored locally and served through Navidrome.

Library details:

- around **1100 songs**
- approximately **35 GB**
- all files in **FLAC** format
- organized into folders representing playlists

I originally kept most of my music on **Spotify**.  
Later, I transferred the library to **Deezer**, then used **Deemix** to download and preserve the collection locally in FLAC quality.

This gives me:

- full ownership of my library
- offline access
- no subscription dependency
- higher audio quality
- compatibility with self-hosted streaming

![My Music](photos/myMusic.png)

---

#### Directory Location

Docker project files are stored in:

```bash
/srv/docker/navidrome
```

---

#### Docker Compose Configuration

Create:

```bash
sudo nano /srv/docker/navidrome/docker-compose.yml
```

Add:

```yaml
services:
  navidrome:
    image: deluan/navidrome:latest
    user: 1000:1000
    ports:
      - "4533:4533"
    restart: unless-stopped
    environment:
      ND_LOGLEVEL: info
    volumes:
      - "/data/services/navidrome/:/data"
      - "/data/shares/media/music/:/music:ro"
```

---

#### Volume Explanation

```bash
/data/services/navidrome/
```

Used for:

- application data
- database
- cache
- metadata

This folder is also accessible through Samba for easier management.

---

```bash
/data/shares/media/music/
```

Used as the main music library location.

This is where I store my music files.

It is mounted as:

```bash
/music:ro
```

Meaning:

- read-only for the container
- protects music files from accidental modification

---

#### Starting the Container

From the project directory:

```bash
cd /srv/docker/navidrome
docker compose up -d
```

---

#### Accessing Navidrome

Open in browser:

```text
http://SERVER_IP:4533
```

Example:

```text
http://192.168.0.108:4533
```

---

#### Clients

I currently use the following clients to access Navidrome.

##### PC / Linux / Windows

- Web browser
- SubTUI (Subsonic-compatible CLI client)


![Navidrome in Browser](photos/navidromeBrowser.png)
![SubTUI](photos/subTUI.png)


---

##### Android

- **Symfonium** *(paid one-time purchase, around 25 RON)*

> Note: There are multiple options for clients compatible with Navidrome: https://www.navidrome.org/apps/

<p align="center">
  <img src="photos/symfonium.jpg">
</p>
---

#### Playlist Import Script

My music library is organized in folders, where each folder represents a playlist.

Navidrome recognizes standard playlist files such as `.m3u`, so I created a small script to automatically generate playlist files from those folders.

Create:

```bash
nano importInNavidrome.sh
```

Add:

```bash
#!/bin/bash
cd /data/shares/media/music/ || exit 1

for dir in */; do
    find "$dir" -type f -name "*.flac" | sort > "${dir%/}.m3u"
done
```

Make executable:

```bash
chmod +x importInNavidrome.sh
```

Run:

```bash
./importInNavidrome.sh
```

---

#### How It Works

Example structure before running:

```text
/music/playlists/
├── Good Shit!/
├── Pop/
└── Killing the Classics/
```

After running the script:

```text
/music/playlists/
├── Good Shit!/
├── Good Shit!.m3u
├── Pop/
├── Pop.m3u
├── Killing the Classics/
└── Killing the Classics.m3u
```

Each generated `.m3u` file contains the `.flac` tracks found inside the matching folder.

This allows Navidrome to import folder-based playlists automatically.

---
