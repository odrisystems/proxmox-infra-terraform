# proxmox-infra-terraform

Terraform configuration for provisioning and managing Proxmox VE infrastructure. This repository ships ready-made modules and examples that help you bring up VMs on a freshly installed Proxmox cluster using Terraform.

## Contents

- `modules/proxmox-vm` – reusable module that provisions a VM (`proxmox_vm_qemu`) with cloud-init support, additional disks, and networking configuration
- `examples/basic` – sample root module showing how to authenticate with Proxmox and consume the module

## Getting Started

1. Install Terraform >= 1.5.0 and ensure the [`Telmate/proxmox`](https://registry.terraform.io/providers/Telmate/proxmox/latest) provider is available.
2. On your Proxmox VE host:
   - Create an API token with the privileges documented in `modules/proxmox-vm/README.md`.
   - (Optional but recommended) Prepare a cloud-init template by importing a cloud image and converting it to a template.
3. Clone this repository and copy the `examples/basic` folder to bootstrap your own root module, or reference `modules/proxmox-vm` directly from your existing configuration:

```hcl
module "vm" {
  source = "./modules/proxmox-vm"

  name        = "app-01"
  target_node = "pve"
  template    = "debian-12-cloudinit-template"
  cores       = 2
  memory      = 4096

  primary_disk = {
    size_gb = 40
    storage = "local-lvm"
  }

  ip_config = {
    ipv4               = "192.168.10.20"
    ipv4_prefix_length = 24
    gateway4           = "192.168.10.1"
  }

  ci_user         = "debian"
  ssh_public_keys = [file("~/.ssh/id_ed25519.pub")]
}
```

Review the module documentation in `modules/proxmox-vm/README.md` for the complete list of inputs, outputs, and operational notes.
