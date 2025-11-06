# Proxmox Module without Vault

This module provisions Proxmox VMs using direct Terraform variables instead of HashiCorp Vault.

## Features

- **Direct variable configuration** via terraform.tfvars or environment variables
- Automated VM provisioning with cloud-init
- Support for blue/green deployment patterns
- Multi-workspace support (blue, blue-worker, green, green-worker)
- Automated SSH key deployment
- Template-based VM creation

## Prerequisites

- Terraform >= 1.5.0
- Proxmox VE 7.4 or newer
- Proxmox API credentials

## Configuration

### Option 1: Using terraform.tfvars

1. Copy the example file:

```bash
cp terraform.tfvars.example terraform.tfvars
```

2. Edit `terraform.tfvars` with your values:

```hcl
pm_api_url      = "https://proxmox.example.com:8006/api2/json"
pm_user         = "root@pam"
pm_password     = "your-proxmox-password"
proxmox_host    = "pve"
hostname_host_1 = "k8s-master"
host_1          = "192.168.1.100"
ip_address      = "192.168.1.100/24"
gateway         = "192.168.1.1"
user_passwd     = "your-user-password"
public_ssh_key  = "ssh-rsa AAAAB3..."
private_ssh_key = "LS0tLS1CRUdJTi..." # base64 encoded
```

### Option 2: Using Environment Variables

```bash
export TF_VAR_pm_api_url="https://proxmox.example.com:8006/api2/json"
export TF_VAR_pm_user="root@pam"
export TF_VAR_pm_password="your-proxmox-password"
export TF_VAR_proxmox_host="pve"
export TF_VAR_hostname_host_1="k8s-master"
export TF_VAR_host_1="192.168.1.100"
export TF_VAR_ip_address="192.168.1.100/24"
export TF_VAR_gateway="192.168.1.1"
export TF_VAR_user_passwd="your-user-password"
export TF_VAR_public_ssh_key="ssh-rsa AAAAB3..."
export TF_VAR_private_ssh_key="LS0tLS1CRUdJTi..."
```

## Required Environment Variables for Workspace

```bash
export TF_ENV=lab
# Optional: if using remote backend
export COMMON_BACKEND="-backend-config=backend.conf"
export BACKEND_STATE_KEY="backends/lab.conf"
```

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

To add more workspaces, edit `locals.tf` and add additional workspace configurations.

## Security Considerations

⚠️ **Important**: When using this module without Vault:

1. **Never commit `terraform.tfvars`** with real credentials to version control
2. Add `terraform.tfvars` to `.gitignore`
3. Use environment variables for CI/CD pipelines
4. Consider using encrypted storage for sensitive values
5. Rotate credentials regularly

## Notes

- All credentials are passed directly to Terraform
- Sensitive variables are marked as sensitive in the module
- Workspace configuration is managed via `locals.tf`
- For production environments, consider using the Vault-enabled module
