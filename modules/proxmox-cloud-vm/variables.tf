variable "proxmox_node" {
  type = string
}

variable "image_datastore" {
  type = string
}

variable "cloud_image_url" {
  type = string
}

variable "cloud_image_file_name" {
  type = string
}

variable "cloud_image_checksum" {
  type     = string
  default  = null
  nullable = true
}

variable "cloud_image_checksum_algorithm" {
  type     = string
  default  = null
  nullable = true
}

variable "cloud_image_overwrite" {
  type    = bool
  default = false
}

variable "cloud_image_download_timeout" {
  type    = number
  default = 1800
}

variable "vm_datastore" {
  type = string
}

variable "vm_id" {
  type = number
}

variable "vm_hostname" {
  type = string
}

variable "vm_domain" {
  type = string
}

variable "vm_description" {
  type    = string
  default = "VM managed by Terraform"
}

variable "vm_tags" {
  type    = list(string)
  default = ["terraform"]
}

variable "vm_started" {
  type    = bool
  default = true
}

variable "vm_stop_on_destroy" {
  type    = bool
  default = true
}

variable "vm_startup_order" {
  type    = number
  default = 3
}

variable "vm_startup_up_delay" {
  type    = number
  default = 30
}

variable "vm_startup_down_delay" {
  type    = number
  default = 30
}

variable "vm_machine" {
  type    = string
  default = "q35"
}

variable "vm_bios" {
  type    = string
  default = "seabios"
}

variable "vm_operating_system_type" {
  type    = string
  default = "l26"
}

variable "vm_cpu_cores" {
  type    = number
  default = 2
}

variable "vm_cpu_sockets" {
  type    = number
  default = 1
}

variable "vm_cpu_type" {
  type    = string
  default = "x86-64-v2-AES"
}

variable "vm_memory_mb" {
  type    = number
  default = 2048
}

variable "vm_memory_balloon_mb" {
  type    = number
  default = 2048
}

variable "qemu_agent_enabled" {
  type    = bool
  default = false
}

variable "qemu_agent_timeout" {
  type    = string
  default = "15m"
}

variable "vm_disk_size_gb" {
  type    = number
  default = 20
}

variable "vm_disk_interface" {
  type    = string
  default = "virtio0"
}

variable "vm_disk_cache" {
  type    = string
  default = "none"
}

variable "vm_disk_iothread" {
  type    = bool
  default = true
}

variable "vm_disk_discard" {
  type    = string
  default = "on"
}

variable "vm_disk_ssd" {
  type    = bool
  default = false
}

variable "vm_efi_disk_enabled" {
  type    = bool
  default = false
}

variable "network_bridge" {
  type = string
}

variable "network_model" {
  type    = string
  default = "virtio"
}

variable "network_vlan_id" {
  type     = number
  default  = null
  nullable = true
}

variable "network_firewall_enabled" {
  type    = bool
  default = false
}

variable "vm_ipv4_mode" {
  type    = string
  default = "static"
}

variable "vm_ipv4_address" {
  type     = string
  default  = null
  nullable = true
}

variable "vm_ipv4_prefix" {
  type    = number
  default = 24
}

variable "vm_ipv4_gateway" {
  type     = string
  default  = null
  nullable = true
}

variable "dns_servers" {
  type    = list(string)
  default = []
}

variable "vm_username" {
  type = string
}

variable "vm_password" {
  type      = string
  default   = null
  nullable  = true
  sensitive = true
}

variable "ssh_public_key" {
  type     = string
  default  = null
  nullable = true
}

variable "ssh_password_auth_enabled" {
  type    = bool
  default = false
}

variable "install_qemu_guest_agent" {
  type    = bool
  default = false
}

variable "guest_agent_package" {
  type    = string
  default = "qemu-guest-agent"
}

variable "guest_agent_service" {
  type    = string
  default = "qemu-guest-agent"
}

variable "snippet_datastore" {
  type    = string
  default = "local"
}

variable "ssh_public_key_path" {
  type    = string
  default = "~/.ssh/id_ed25519.pub"
}
