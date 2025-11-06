locals {

  env = {
    lab = {
      iso_storage_pool     = "local"
      vmid                 = "8000"
      cloud-init-disk-name = "cloud-init-disk-lab"
      memory               = 4096
    }
  }

  workspace = local.env[terraform.workspace]
}
