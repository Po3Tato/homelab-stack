# HomeOps as Code

A collection of Infrastructure as Code configurations for managing my Hybrid cloud environment.

## What's This?

This repository contains automation playbooks and configurations for managing:

- **Home Lab Infrastructure** - Proxmox as my Type 1 hypervisor for all my VMs and containers. I plan on deploying two Type 1 hypervisors (Proxmox and OpenStack).
- **Cloud Resources** - Vultr instances with time i will add AWS and Azure.
- **Network Configuration** - Tailscale as my underlying network for my homelab. This makes it easy for me to setup ACLs and it propergrates across the network.
- **Service Deployments** - 🚧 **Work in Progress** 🚧

## Current Status

- ✅ Proxmox VM automation
- ✅ Vultr cloud instance deployment
- ✅ Network configuration - Tailscale
- 🔄 Service orchestration (planned) - Talos Linux

## Goals

- Declarative infrastructure management
- Reproducible deployments
- Disaster recovery preparedness
- Learning and experimentation platform

## License

MIT License - see [LICENSE](LICENSE) file for details.