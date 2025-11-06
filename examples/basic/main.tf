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
  pm_api_url          = var.pm_api_url
  pm_api_token_id     = var.pm_api_token_id
  pm_api_token_secret = var.pm_api_token_secret
  pm_tls_insecure     = var.pm_tls_insecure
}

module "vm" {
  source = "../../modules/proxmox-vm"

  name        = var.vm_name
  target_node = var.target_node
  template    = var.template

  cores   = 2
  sockets = 1
  memory  = 4096

  primary_disk = {
    size_gb = 20
    storage = "local-lvm"
  }

  ip_config = var.ip_config

  ci_user          = "debian"
  ssh_public_keys  = [file(var.ssh_public_key_path)]
  tags             = ["terraform", "example"]
  cloudinit_cdrom_storage = "local-lvm"
}
