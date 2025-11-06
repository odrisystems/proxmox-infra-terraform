variable "pm_api_url" {
  description = "Proxmox API URL (e.g., https://proxmox.example.com:8006/api2/json)"
  type        = string
}

variable "pm_user" {
  description = "Proxmox user (e.g., root@pam)"
  type        = string
  default     = "root@pam"
}

variable "pm_password" {
  description = "Proxmox user password"
  type        = string
  sensitive   = true
}

variable "proxmox_host" {
  description = "Proxmox host node name"
  type        = string
}

variable "hostname_host_1" {
  description = "Hostname for the VM"
  type        = string
}

variable "user_passwd" {
  description = "User password for cloud-init"
  type        = string
  sensitive   = true
}

variable "public_ssh_key" {
  description = "Public SSH key for access"
  type        = string
}

variable "private_ssh_key" {
  description = "Private SSH key (base64 encoded)"
  type        = string
  sensitive   = true
}

variable "ip_address" {
  description = "IP address for the VM (CIDR notation, e.g., 192.168.1.100/24)"
  type        = string
}

variable "gateway" {
  description = "Network gateway"
  type        = string
}

variable "host_1" {
  description = "Host IP for SSH connection"
  type        = string
}
