variable "proxmox_server_domain_name" {
  description = "The DNS name or IP address of the Proxmox server"
  type        = string
}

variable "proxmox_server_api_url" {
  description = "The full API URL for the Proxmox server"
  type        = string
  default     = "https://${var.proxmox_server_domain_name}:8006/api2/json"
}

variable "proxmox_username" {
  description = "Username to authenticate against the Proxmox API (e.g. root@pam)"
  type        = string
}

variable "proxmox_password" {
  description = "Password for the Proxmox API user"
  type        = string
  sensitive   = true
}
