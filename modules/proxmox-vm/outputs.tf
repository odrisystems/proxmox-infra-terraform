output "vm_id" {
  description = "Numeric VMID assigned by Proxmox."
  value       = proxmox_vm_qemu.this.vmid
}

output "vm_name" {
  description = "Name of the VM in Proxmox."
  value       = proxmox_vm_qemu.this.name
}

output "node" {
  description = "Proxmox node where the VM resides."
  value       = proxmox_vm_qemu.this.target_node
}

output "ipv4_addresses" {
  description = "Discovered IPv4 addresses reported by the guest agent."
  value       = proxmox_vm_qemu.this.ipv4_addresses
}

output "ipv6_addresses" {
  description = "Discovered IPv6 addresses reported by the guest agent."
  value       = proxmox_vm_qemu.this.ipv6_addresses
}
