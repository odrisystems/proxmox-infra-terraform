variable "name" {
  type        = string
  description = "Name of the Proxmox VM to create."
}

variable "target_node" {
  type        = string
  description = "Name of the Proxmox node (host) where the VM will be created."
}

variable "vm_id" {
  type        = number
  description = "Optional static VMID to assign. If null, Proxmox picks the next available ID."
  default     = null
}

variable "pool" {
  type        = string
  description = "Optional resource pool to associate with the VM."
  default     = null
}

variable "description" {
  type        = string
  description = "Optional description shown in the Proxmox UI."
  default     = null
}

variable "template" {
  type        = string
  description = "Existing VM or template name to clone. Set to null to create from scratch."
  default     = null
}

variable "full_clone" {
  type        = bool
  description = "Whether to create a full clone when cloning from a template."
  default     = true
}

variable "onboot" {
  type        = bool
  description = "Whether the VM should automatically start on node boot."
  default     = true
}

variable "power_on" {
  type        = bool
  description = "Whether the VM should be powered on after creation."
  default     = true
}

variable "cores" {
  type        = number
  description = "Number of vCPU cores to assign."
  default     = 2
}

variable "sockets" {
  type        = number
  description = "Number of CPU sockets to assign."
  default     = 1
}

variable "cpu_type" {
  type        = string
  description = "CPU type to expose to the guest."
  default     = "kvm64"
}

variable "memory" {
  type        = number
  description = "Memory in MiB to allocate for the VM."
  default     = 2048
}

variable "ballooning_memory" {
  type        = number
  description = "Optional memory ballooning limit in MiB."
  default     = null
}

variable "scsihw" {
  type        = string
  description = "SCSI controller model to use."
  default     = "virtio-scsi-pci"
}

variable "bios" {
  type        = string
  description = "BIOS type to use for the VM."
  default     = "seabios"
}

variable "machine" {
  type        = string
  description = "Optional QEMU machine type override."
  default     = null
}

variable "agent_enabled" {
  type        = bool
  description = "Enable the QEMU guest agent (requires it to be installed in the guest)."
  default     = true
}

variable "hotplug" {
  type        = string
  description = "Devices that are hot-pluggable for the VM."
  default     = "network,disk,usb"
}

variable "primary_disk" {
  description = "Primary system disk configuration."
  type = object({
    size_gb      = number
    storage      = string
    type         = optional(string, "scsi")
    storage_type = optional(string)
    backup       = optional(bool, true)
    ssd          = optional(bool, false)
    discard      = optional(bool, false)
    iothread     = optional(bool, false)
  })
  default = {
    size_gb = 20
    storage = "local-lvm"
  }
}

variable "additional_disks" {
  description = "Additional disks to attach to the VM."
  type = list(object({
    id           = optional(number)
    slot         = optional(string)
    size_gb      = number
    storage      = string
    type         = optional(string, "scsi")
    storage_type = optional(string)
    backup       = optional(bool, true)
    ssd          = optional(bool, false)
    discard      = optional(bool, false)
    iothread     = optional(bool, false)
  }))
  default = []
}

variable "network" {
  description = "Primary network interface configuration."
  type = object({
    bridge   = string
    model    = optional(string, "virtio")
    tag      = optional(number)
    firewall = optional(bool)
    rate     = optional(number)
    mtu      = optional(number)
    macaddr  = optional(string)
    queues   = optional(number)
  })
  default = {
    bridge = "vmbr0"
  }
}

variable "additional_networks" {
  description = "Additional network interfaces to attach."
  type = list(object({
    bridge   = string
    model    = optional(string, "virtio")
    tag      = optional(number)
    firewall = optional(bool)
    rate     = optional(number)
    mtu      = optional(number)
    macaddr  = optional(string)
    queues   = optional(number)
  }))
  default = []
}

variable "ip_config" {
  description = "Cloud-init IP configuration for the primary interface."
  type = object({
    ipv4              = optional(string)
    ipv4_prefix_length = optional(number)
    gateway4          = optional(string)
    ipv6              = optional(string)
    ipv6_prefix_length = optional(number)
    gateway6          = optional(string)
  })
  default = null
}

variable "nameserver" {
  type        = string
  description = "Optional DNS nameserver for cloud-init."
  default     = null
}

variable "searchdomain" {
  type        = string
  description = "Optional DNS search domain for cloud-init."
  default     = null
}

variable "ci_user" {
  type        = string
  description = "Cloud-init default user."
  default     = null
}

variable "ci_password" {
  type        = string
  description = "Cloud-init default user password. Set to null to disable password auth."
  default     = null
  sensitive   = true
}

variable "ssh_public_keys" {
  type        = list(string)
  description = "List of SSH public keys injected via cloud-init."
  default     = []
}

variable "cloudinit_cdrom_storage" {
  type        = string
  description = "Storage location for the generated cloud-init ISO (ide2)."
  default     = "local-lvm"
}

variable "os_type" {
  type        = string
  description = "Guest OS type hint (for example 'cloud-init', 'linux', 'windows')."
  default     = null
}

variable "tags" {
  type        = list(string)
  description = "Tags applied to the VM (displayed in the Proxmox UI)."
  default     = []
}

variable "boot_order" {
  type        = list(string)
  description = "Devices boot order, expressed as Proxmox device identifiers (e.g. ['scsi0','net0'])."
  default     = ["scsi0", "net0"]
}

variable "lifecycle_ignore_network_changes" {
  type        = bool
  description = "Whether to ignore drift for network blocks (helps avoid spurious diffs when Proxmox sets MACs)."
  default     = true
}

variable "timeouts" {
  description = "Custom timeouts for the proxmox_vm_qemu resource."
  type = object({
    create = optional(string)
    update = optional(string)
    delete = optional(string)
  })
  default = {}
}
