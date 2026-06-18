# Homelab Self-Hosting Apps & Services (Curated List)

This document lists popular applications and services commonly used in homelab environments for self-hosting, automation, media management, networking, and infrastructure control.

It is structured by category to make it easier to explore and decide what fits different use cases.

---

# 1. Core Infrastructure

## Reverse Proxy / TLS Management

- **Nginx Proxy Manager** – simple web UI for reverse proxy + SSL
- **Traefik** – dynamic reverse proxy designed for containers
- **Caddy** – automatic HTTPS with minimal configuration

---

## DNS / Network Control

- **Pi-hole** – network-wide ad blocking + DNS control
- **AdGuard Home** – alternative to Pi-hole with more UI features
- **Unbound** – recursive DNS resolver for privacy-focused setups

---

## VPN / Remote Access

- **WireGuard** – modern, fast VPN protocol
- **OpenVPN** – older but widely supported VPN solution
- **Tailscale** – WireGuard-based mesh VPN (managed service)
- **Headscale** – self-hosted Tailscale control server

---

# 2. Storage & Backup

## File Sync / Cloud Storage

- **Syncthing** – decentralized file synchronization
- **Nextcloud** – full self-hosted Google Drive alternative
- **Seafile** – lightweight cloud storage alternative

---

## Backup Solutions

- **BorgBackup** – deduplicated, encrypted backups
- **Restic** – simple encrypted backup tool
- **Kopia** – modern backup tool with UI and encryption

---

## NAS / File Sharing

- **Samba (SMB)** – cross-platform file sharing (Windows/Linux/Android)
- **NFS** – Linux-native network file sharing
- **OpenMediaVault** – NAS management OS
- **TrueNAS** – enterprise-grade NAS system (ZFS-based)

---

# 3. Media Services

## Music

- **Navidrome** – lightweight Subsonic-compatible music server
- **Lidarr** – music collection automation
- **Beets** – music library organizer

---

## Video / Streaming

- **Jellyfin** – open-source media streaming platform
- **Plex** – popular media server (partially closed-source)
- **Emby** – Plex alternative with hybrid licensing

---

## Photo Management

- **Immich** – Google Photos alternative (very popular now)
- **PhotoPrism** – AI-based photo organization
- **Piwigo** – classic photo gallery system

---

# 4. Containers & App Hosting

- **Docker** – container runtime
- **Docker Compose** – multi-container orchestration
- **Portainer** – web UI for Docker management
- **Podman** – daemonless container engine alternative

---

# 5. Monitoring & System Tools

- **Netdata** – real-time system monitoring
- **Grafana** – visualization dashboards
- **Prometheus** – metrics collection
- **Uptime Kuma** – service uptime monitoring
- **Glances** – lightweight system monitor

---

# 6. Game Servers

- **LinuxGSM** – game server manager (CLI-based)
- **Pterodactyl Panel** – full game server hosting panel
- **AMP (CubeCoders)** – commercial game server manager
- **Crafty Controller** – Minecraft-focused server panel

---

# 7. Home Automation

- **Home Assistant** – most popular smart home platform
- **Node-RED** – flow-based automation engine
- **OpenHAB** – alternative smart home hub

---

# 8. Productivity / Personal Systems

- **Obsidian (self-hosted via browser containers)** – note system
- **HedgeDoc** – collaborative markdown editor
- **Outline** – team wiki system
- **BookStack** – documentation / wiki platform

---

# 9. Networking Utilities

- **lancache** – local caching for game downloads (Steam, etc.)
- **Speedtest Tracker** – logs internet speed over time
- **Netmaker** – WireGuard-based networking platform

---

# 10. Security

- **Fail2Ban** – intrusion prevention
- **CrowdSec** – modern collaborative security engine
- **Vaultwarden** – self-hosted Bitwarden server

---

# Notes

Most homelab setups combine:

- VPN (WireGuard)
- NAS (Samba / NFS)
- Containers (Docker)
- Media stack (Jellyfin / Navidrome)
- Backup (Borg / Restic)
- Monitoring (Uptime Kuma / Grafana)

This stack can be scaled from a single laptop to full multi-node infrastructure.

---
