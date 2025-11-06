# Proxmox Module with HashiCorp Vault Integration

This module provisions Proxmox VMs using HashiCorp Vault for secure credential and configuration management.

## Features

- **Secure credential management** using HashiCorp Vault
- Automated VM provisioning with cloud-init
- Support for blue/green deployment patterns
- Multi-workspace support (blue, blue-worker, green, green-worker)
- Automated SSH key deployment
- Template-based VM creation

## Prerequisites

- HashiCorp Vault instance with Proxmox secrets configured
- Terraform >= 1.5.0
- Proxmox VE 7.4 or newer
- Access to Vault with appropriate permissions

## Required Environment Variables

```bash
export VAULT_ADDR=https://vault.my-domain-vault.com
export TF_VAR_vault_token=hvs.your-vault-key
export VAULT_TOKEN=hvs.your-vault-key
export TF_ENV=lab
export COMMON_BACKEND="-backend-config=backend.conf"
export BACKEND_STATE_KEY="backends/lab.conf"
```

## Vault Secret Structure

The module expects secrets in Vault at path `proxmox/<environment>` with the following keys:

- `host` - Proxmox host FQDN/IP
- `password` - Proxmox root password
- `proxmox_host` - Proxmox node name
- `hostname_host_1` - VM hostname
- `host_1` - VM IP address
- `public_ssh_key` - SSH public key
- `private_ssh_key` - SSH private key (base64 encoded)
- `user_passwd` - Cloud-init user password
- `ip_address` - VM IP with CIDR (e.g., 192.168.1.100/24)
- `gateway` - Network gateway

## Usage

### Initialize

```bash
./init.sh
```

### Apply

```bash
./apply.sh
```

### Destroy

```bash
./destroy.sh
```

## Available Workspaces

- `lab` - Lab environment (VMID: 8000, 4GB RAM, storage: local)
  - Vault path: `proxmox/proxmox-lab`

To add more workspaces, edit `locals.tf` and add additional workspace configurations.

## Notes

- All sensitive data is retrieved from Vault at runtime
- No credentials are stored in code or state files
- Workspace configuration is managed via `locals.tf`
