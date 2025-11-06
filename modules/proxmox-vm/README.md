# Proxmox VM Terraform Module

Terraform module that provisions a virtual machine on a Proxmox VE cluster. The module is designed for freshly installed Proxmox environments and optimised for cloud-init enabled templates, while still supporting creation of blank VMs that you can install manually from an ISO.

## Features

- Creates a `proxmox_vm_qemu` VM with configurable CPU, memory, boot options, and hot-plug settings
- Supports cloning from an existing template or creating an empty VM shell
- Manages the primary disk and optional additional disks and network interfaces
- Configures cloud-init metadata (IP addressing, user, SSH keys, DNS)
- Exposes useful outputs (VMID, name, discovered IPs) for downstream automation

## Requirements

- **Terraform** >= 1.5.0
- **Provider**: [`Telmate/proxmox`](https://registry.terraform.io/providers/Telmate/proxmox/latest) >= 3.0.0
- Proxmox VE 7.4 or newer with API access enabled
- API token or user/password with `VM.Allocate`, `VM.Config.*`, `VM.Console`, `Datastore.AllocateSpace`, and `Sys.Audit` privileges on the target resources

### Preparing a fresh Proxmox server

1. Create an API token via *Datacenter → Permissions → API Tokens* and note the token ID and secret.
2. (Recommended) Create a cloud-init ready template. Proxmox ships cloud-init packages; follow the official guide to turn a cloud image into a template (download image, import as VM, convert to template).
3. Ensure the storage locations referenced by the module (`primary_disk.storage`, `cloudinit_cdrom_storage`) exist. For a default install, `local` and `local-lvm` are available.

## Usage

```hcl
terraform {
  required_version = ">= 1.5.0"

  required_providers {
    proxmox = {
      source  = "Telmate/proxmox"
      version = ">= 3.0.0"
    }
  }
}

provider "proxmox" {
  pm_api_url          = "https://pve.example.com:8006/api2/json"
  pm_api_token_id     = var.pm_api_token_id
  pm_api_token_secret = var.pm_api_token_secret
  pm_tls_insecure     = true
}

module "vm" {
  source = "./modules/proxmox-vm"

  name        = "web-01"
  target_node = "pve"
  template    = "debian-12-cloudinit-template"

  cores  = 2
  memory = 4096

  primary_disk = {
    size_gb = 40
    storage = "local-lvm"
  }

  ip_config = {
    ipv4               = "192.168.10.50"
    ipv4_prefix_length = 24
    gateway4           = "192.168.10.1"
  }

  ci_user         = "debian"
  ssh_public_keys = [file("~/.ssh/id_ed25519.pub")]
  tags            = ["terraform", "production"]
}
```

See the [`examples/basic`](../../examples/basic) scenario for a runnable configuration.

## Inputs

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `name` | `string` | n/a | Name of the Proxmox VM. |
| `target_node` | `string` | n/a | Name of the Proxmox host that will run the VM. |
| `template` | `string` | `null` | Template or VM name to clone. Leave `null` to create an empty VM. |
| `primary_disk` | `object` | `{ size_gb = 20, storage = "local-lvm" }` | Primary disk definition (size in GiB, storage ID, optional type, etc.). |
| `additional_disks` | `list(object)` | `[]` | Extra disks to attach; supply `slot` or `id` + storage settings. |
| `network` | `object` | `{ bridge = "vmbr0" }` | Primary NIC configuration (bridge, model, VLAN tag, etc.). |
| `additional_networks` | `list(object)` | `[]` | Additional NICs to attach. |
| `ip_config` | `object` | `null` | Cloud-init IP data (`ipv4`, `gateway4`, `ipv6`, ...). |
| `ci_user` | `string` | `null` | Cloud-init default user. |
| `ssh_public_keys` | `list(string)` | `[]` | SSH keys injected via cloud-init. |
| `cores` | `number` | `2` | Number of vCPU cores. |
| `memory` | `number` | `2048` | Memory in MiB. |
| `tags` | `list(string)` | `[]` | Tags shown in the Proxmox UI. |

For a full list (including `vm_id`, `bios`, `hotplug`, `timeouts`, etc.) see [`variables.tf`](./variables.tf).

## Outputs

- `vm_id` – Numeric VMID assigned by Proxmox
- `vm_name` – Name of the created VM
- `node` – Node hosting the VM
- `ipv4_addresses` – IPv4 addresses detected by the guest agent
- `ipv6_addresses` – IPv6 addresses detected by the guest agent

## Notes

- When cloning from a template, set `template` to the Proxmox template name and ensure it has cloud-init enabled for IP/SSH injection.
- For completely fresh installs without a template, leave `template = null`, provide `primary_disk` settings, and optionally attach an ISO later or via the Proxmox UI (`Datacenter → Storage → Upload`).
- The module defaults to ignoring network drift in Terraform state (Proxmox may populate MAC addresses and bridge info). Disable via `lifecycle_ignore_network_changes = false` if you need strict drift detection.
