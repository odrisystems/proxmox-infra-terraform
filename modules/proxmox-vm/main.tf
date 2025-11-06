locals {
  primary_disk_type = coalesce(var.primary_disk.type, "scsi")
  primary_disk_slot = "${local.primary_disk_type}0"
  boot_string       = length(var.boot_order) > 0 ? "order=${join(";", var.boot_order)}" : null
  tags_string       = length(var.tags) > 0 ? join(";", var.tags) : null
  ssh_keys_string   = length(var.ssh_public_keys) > 0 ? join("\n", var.ssh_public_keys) : null
  os_type           = var.os_type != null ? var.os_type : (var.template != null ? "cloud-init" : null)
  ipconfig0_string = var.ip_config == null ? null : join(",", compact([
    var.ip_config.ipv4 != null && var.ip_config.ipv4_prefix_length != null ? "ip=${var.ip_config.ipv4}/${var.ip_config.ipv4_prefix_length}" : null,
    var.ip_config.gateway4 != null ? "gw=${var.ip_config.gateway4}" : null,
    var.ip_config.ipv6 != null && var.ip_config.ipv6_prefix_length != null ? "ip6=${var.ip_config.ipv6}/${var.ip_config.ipv6_prefix_length}" : null,
    var.ip_config.gateway6 != null ? "gw6=${var.ip_config.gateway6}" : null
  ]))
}

resource "proxmox_vm_qemu" "this" {
  name        = var.name
  target_node = var.target_node
  vmid        = var.vm_id
  pool        = var.pool
  desc        = var.description
  clone       = var.template
  full_clone  = var.template == null ? null : var.full_clone
  onboot      = var.onboot
  start       = var.power_on
  boot        = local.boot_string
  bootdisk    = local.primary_disk_slot
  scsihw      = var.scsihw
  bios        = var.bios
  machine     = var.machine
  hotplug     = var.hotplug
  agent       = var.agent_enabled ? 1 : 0
  os_type     = local.os_type
  cpu         = var.cpu_type
  cores       = var.cores
  sockets     = var.sockets
  memory      = var.memory
  balloon     = var.ballooning_memory
  cloudinit_cdrom_storage = var.cloudinit_cdrom_storage
  nameserver  = var.nameserver
  searchdomain = var.searchdomain
  ciuser      = var.ci_user
  cipassword  = var.ci_password
  sshkeys     = local.ssh_keys_string
  tags        = local.tags_string
  ipconfig0   = local.ipconfig0_string

  disk {
    slot         = local.primary_disk_slot
    type         = local.primary_disk_type
    storage      = var.primary_disk.storage
    storage_type = var.primary_disk.storage_type
    size         = var.primary_disk.size_gb
    backup       = var.primary_disk.backup
    ssd          = var.primary_disk.ssd
    discard      = var.primary_disk.discard
    iothread     = var.primary_disk.iothread
  }

  dynamic "disk" {
    for_each = var.additional_disks
    iterator = extra_disk
    content {
      slot         = try(extra_disk.value.slot, null)
      id           = try(extra_disk.value.id, null)
      type         = try(extra_disk.value.type, null)
      storage      = extra_disk.value.storage
      storage_type = try(extra_disk.value.storage_type, null)
      size         = extra_disk.value.size_gb
      backup       = extra_disk.value.backup
      ssd          = extra_disk.value.ssd
      discard      = extra_disk.value.discard
      iothread     = extra_disk.value.iothread
    }
  }

  network {
    bridge   = var.network.bridge
    model    = coalesce(var.network.model, "virtio")
    tag      = var.network.tag
    firewall = var.network.firewall
    rate     = var.network.rate
    mtu      = var.network.mtu
    macaddr  = var.network.macaddr
    queues   = var.network.queues
  }

  dynamic "network" {
    for_each = var.additional_networks
    iterator = extra_net
    content {
      bridge   = extra_net.value.bridge
      model    = coalesce(try(extra_net.value.model, null), "virtio")
      tag      = try(extra_net.value.tag, null)
      firewall = try(extra_net.value.firewall, null)
      rate     = try(extra_net.value.rate, null)
      mtu      = try(extra_net.value.mtu, null)
      macaddr  = try(extra_net.value.macaddr, null)
      queues   = try(extra_net.value.queues, null)
    }
  }

  dynamic "timeouts" {
    for_each = length(var.timeouts) == 0 ? [] : [var.timeouts]
    iterator = custom_timeout
    content {
      create = lookup(custom_timeout.value, "create", null)
      update = lookup(custom_timeout.value, "update", null)
      delete = lookup(custom_timeout.value, "delete", null)
    }
  }

  lifecycle {
    ignore_changes = var.lifecycle_ignore_network_changes ? [
      network,
    ] : []
  }
}
