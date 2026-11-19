<div align="center">

# Gentoo Linux Setup

[![Gentoo](https://img.shields.io/badge/Target-Gentoo%20Linux-54487A?logo=gentoo&logoColor=white)](https://www.gentoo.org/)
[![OpenRC](https://img.shields.io/badge/Init-OpenRC-blue.svg)](https://github.com/OpenRC/openrc)
[![Bash](https://img.shields.io/badge/Shell-Bash-4EAA25?logo=gnubash&logoColor=white)](https://www.gnu.org/software/bash/)
[![nftables](https://img.shields.io/badge/Firewall-nftables-0078D4)](https://netfilter.org/projects/nftables/)

</div>

A personal Gentoo Linux setup with an emphasis on security, simplicity, and maintainability.

## Features

### System Hardening

- **Account Security** — Restricted root access, controlled `su` privileges, secure default file permissions, and stronger password hashing.
- **Kernel Hardening** — Hardened kernel parameters, restricted kernel modules, and protected sensitive system directories.
- **Memory Corruption Protection** — GrapheneOS hardened_malloc with its default security configuration for stronger heap memory protection.
- **SUID/SGID Privilege Reduction** — Unnecessary elevated privileges removed while preserving essential exceptions and required capabilities.

### Network Security

- **Default-Deny Firewall** — Enforces strict inbound and forwarding traffic policies through stateful nftables filtering.
- **Country-Level IP Blocking** — Blocks selected countries at the network level using IPv4 and IPv6 address ranges.
- **Advanced DNS Threat Protection** — Combines HaGeZi Ultimate and Threat Intelligence Feeds (TIF) to block advertisements, trackers, telemetry, phishing, malware, scams, fraudulent domains, cryptojacking, and other internet threats.
- **DNS Privacy & Control** — Centralizes DNS resolution through Unbound, providing control over upstream DNS forwarding and local name resolution.
- **Automatic Threat Intelligence Updates** — Automatically refreshes country-level IP blocklists and DNS threat feeds through OpenRC services, checking for successful updates at system startup.

### Desktop & User Experience

- **Wayland Compositor** — dwl tiling compositor for Wayland.
- **Audio Support** — PipeWire and WirePlumber audio stack.
- **Container Support** — Podman and podman-compose for containerized applications.
- **Session Initialization** — Automatic user session setup at system startup.

## Requirements

- Gentoo Linux
- OpenRC
- doas
- Internet connection

## Installation

Clone the repository:

```bash
git clone https://github.com/riseupcoder/gentoo-setup.git
cd gentoo-setup
./install.sh
```

## Questions & Discussions
Have questions about a script, want to understand a security decision, or have an idea for the project? Open a Discussion. 

## License

This project is licensed under the MIT License.
