# DIY Home Server

This repository documents my journey of building and configuring a DIY home server.

I decided to create this server because I had a couple of old laptops that were just sitting unused. Instead of letting them collect dust, I repurposed them into a small home server environment.

This repo contains the commands, configurations, and notes from the setup process.  
Later I plan to add explanations, screenshots, and short videos.

---

# Hardware

Currently using two machines as part of this DIY server setup.

## Lenovo ThinkPad T430 (Main Server)

![ThinkPad T430 - Photo 1](photos/TP_photo_1.jpg)
![ThinkPad T430 - Photo 2](photos/TP_photo_2.jpg)

- CPU: Intel i5-3320M  
- RAM: 8 GB DDR3  
- Storage: 500 GB SATA III SSD  
- 1 Gbps NIC with support for Wake on Lan

This machine acts as the **main server**, as it has more reliable performance and significantly more storage available.

## HP ProBook 455 G2 (Testing Machine)

![HP ProBook 455 G2 - Photo 1](photos/HP_photo_1.jpg)
![HP ProBook 455 G2 - Photo 2](photos/HP_photo_2.jpg)

- CPU: AMD A8-7100  
- RAM: 8 GB DDR3  
- Storage: 120 GB SATA III SSD  
- 1 Gbps NIC with support for Wake on Lan

The **HP ProBook struggles with performance and has limited storage**, so it is mainly used as a **testing environment**.  
I use it to experiment with configurations, services, and setups before applying them to the ThinkPad server, which helps avoid breaking the main system and having to reconfigure it.

> **Note:** From this point onward, all setup and configuration steps described in this documentation refer **only to the ThinkPad T430**, which serves as the main server.

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

<!-- ![Servers and Router](photos/servers_router.png) -->

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