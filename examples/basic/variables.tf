variable "pm_api_url" {
  type        = string
  description = "HTTPS URL to the Proxmox API endpoint (e.g. https://pve.example.com:8006/api2/json)."
}

variable "pm_api_token_id" {
  type        = string
  description = "Token ID with /api privilege, formatted as 'user@realm!token'."
}

variable "pm_api_token_secret" {
  type        = string
  description = "Secret associated with the token ID."
  sensitive   = true
}

variable "pm_tls_insecure" {
  type        = bool
  description = "Set to true to skip TLS verification (useful for self-signed certs)."
  default     = true
}

variable "vm_name" {
  type        = string
  description = "Name of the VM to create in the example."
  default     = "example-cloudinit"
}

variable "target_node" {
  type        = string
  description = "Proxmox node that will host the VM."
  default     = "pve"
}

variable "template" {
  type        = string
  description = "Existing Proxmox template (cloud-init enabled) to clone."
  default     = "debian-12-cloudinit-template"
}

variable "ip_config" {
  description = "Static IP configuration to hand to cloud-init."
  type = object({
    ipv4               = optional(string)
    ipv4_prefix_length = optional(number)
    gateway4           = optional(string)
    ipv6               = optional(string)
    ipv6_prefix_length = optional(number)
    gateway6           = optional(string)
  })
  default = {
    ipv4               = "192.168.1.50"
    ipv4_prefix_length = 24
    gateway4           = "192.168.1.1"
  }
}

variable "ssh_public_key_path" {
  type        = string
  description = "Path to an SSH public key to inject via cloud-init."
  default     = "~/.ssh/id_rsa.pub"
}
