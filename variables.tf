variable "proxmox_endpoint" {
  description = "Proxmox VE API endpoint, for example https://172.168.100.10:8006/."
  type        = string
}

variable "proxmox_api_token" {
  description = "Proxmox API token in the format user@realm!token=secret. Pass it via TF_VAR_proxmox_api_token."
  type        = string
  sensitive   = true
}

variable "proxmox_insecure" {
  description = "Allow the Proxmox API's self-signed TLS certificate. Set to true only with untrusted certificates."
  type        = bool
  default     = false
}

variable "proxmox_node" {
  description = "Proxmox node where the VM is created."
  type        = string
}

variable "image_datastore" {
  description = "Datastore used to download/import the cloud image."
  type        = string
  default     = "local"
}

variable "cloud_image_url" {
  description = "URL of the Cloud-Init compatible cloud image."
  type        = string
}

variable "cloud_image_file_name" {
  description = "Image file name on Proxmox. For QCOW2 images published as .img, use a final .qcow2 name."
  type        = string
}

variable "cloud_image_checksum" {
  description = "Optional hexadecimal image checksum, without an algorithm prefix. Requires cloud_image_checksum_algorithm."
  type        = string
  default     = null
  nullable    = true
}

variable "cloud_image_checksum_algorithm" {
  description = "Checksum algorithm: md5, sha1, sha224, sha256, sha384, or sha512. Required with cloud_image_checksum."
  type        = string
  default     = null
  nullable    = true

  validation {
    condition = (
      var.cloud_image_checksum_algorithm == null ||
      contains(["md5", "sha1", "sha224", "sha256", "sha384", "sha512"], var.cloud_image_checksum_algorithm)
    )
    error_message = "cloud_image_checksum_algorithm must be md5, sha1, sha224, sha256, sha384, or sha512."
  }
}

variable "cloud_image_overwrite" {
  description = "If true, re-download the image when the remote or local size changes. If false, performs no checks and never replaces the existing file."
  type        = bool
  default     = false
}

variable "cloud_image_download_timeout" {
  description = "Download timeout in seconds."
  type        = number
  default     = 1800
}

variable "vm_datastore" {
  description = "Datastore for the VM disk, Cloud-Init, and optional EFI disk."
  type        = string
}

variable "vm_id" {
  description = "Unique numeric VM ID."
  type        = number
}

variable "vm_hostname" {
  description = "VM short hostname."
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9][a-zA-Z0-9-]{0,62}$", var.vm_hostname))
    error_message = "vm_hostname may contain only letters, numbers, and hyphens, and must not start with a hyphen."
  }
}

variable "vm_domain" {
  description = "VM DNS/search domain."
  type        = string
}

variable "vm_description" {
  description = "VM description."
  type        = string
  default     = "VM managed by Terraform"
}

variable "vm_tags" {
  description = "Proxmox tags assigned to the VM."
  type        = list(string)
  default     = ["terraform"]
}

variable "vm_started" {
  description = "Start the VM after creation."
  type        = bool
  default     = true
}

variable "vm_stop_on_destroy" {
  description = "Stop the VM before destruction."
  type        = bool
  default     = true
}

variable "vm_startup_order" {
  description = "Proxmox boot order."
  type        = number
  default     = 3
}

variable "vm_startup_up_delay" {
  description = "Boot delay in seconds."
  type        = number
  default     = 30
}

variable "vm_startup_down_delay" {
  description = "Shutdown delay in seconds."
  type        = number
  default     = 30
}

variable "vm_machine" {
  description = "QEMU machine type."
  type        = string
  default     = "q35"
}

variable "vm_bios" {
  description = "Firmware: seabios or ovmf."
  type        = string
  default     = "seabios"

  validation {
    condition     = contains(["seabios", "ovmf"], var.vm_bios)
    error_message = "vm_bios must be seabios or ovmf."
  }
}

variable "vm_operating_system_type" {
  description = "Proxmox OS type, for example l26 for Linux."
  type        = string
  default     = "l26"
}

variable "vm_cpu_cores" {
  description = "Cores per socket."
  type        = number
  default     = 2
}

variable "vm_cpu_sockets" {
  description = "Number of virtual sockets."
  type        = number
  default     = 1
}

variable "vm_cpu_type" {
  description = "QEMU CPU type."
  type        = string
  default     = "x86-64-v2-AES"
}

variable "vm_memory_mb" {
  description = "Dedicated RAM in MB."
  type        = number
  default     = 2048
}

variable "vm_memory_balloon_mb" {
  description = "Minimum ballooning RAM in MB. Use the same value as vm_memory_mb to prevent dynamic ballooning."
  type        = number
  default     = 2048
}

variable "qemu_agent_enabled" {
  description = "Enable the QEMU Guest Agent on the Proxmox side. Set to true only if the agent is installed and running in the guest."
  type        = bool
  default     = false
}

variable "qemu_agent_timeout" {
  description = "Maximum wait for the QEMU Guest Agent, for example 15m or 90s."
  type        = string
  default     = "15m"
}

variable "vm_disk_size_gb" {
  description = "Disk size in GB. Must not be smaller than the imported image size."
  type        = number
  default     = 20
}

variable "vm_disk_interface" {
  description = "Disk interface, for example virtio0 or scsi0."
  type        = string
  default     = "virtio0"
}

variable "vm_disk_cache" {
  description = "Disk cache mode, for example none, writeback, writethrough, directsync, or unsafe."
  type        = string
  default     = "none"
}

variable "vm_disk_iothread" {
  description = "Enable the IO thread on the disk."
  type        = bool
  default     = true
}

variable "vm_disk_discard" {
  description = "Discard/TRIM mode."
  type        = string
  default     = "on"
}

variable "vm_disk_ssd" {
  description = "Expose the disk as an SSD. Ignored with the virtio interface: use scsi to enable it."
  type        = bool
  default     = false
}

variable "vm_efi_disk_enabled" {
  description = "Create an EFI disk. Must be true when vm_bios is ovmf."
  type        = bool
  default     = false
}

variable "network_bridge" {
  description = "Proxmox bridge."
  type        = string
}

variable "network_model" {
  description = "Virtual network card model."
  type        = string
  default     = "virtio"
}

variable "network_vlan_id" {
  description = "VLAN tag; null if the network is presented untagged to the VM."
  type        = number
  default     = null
  nullable    = true
}

variable "network_firewall_enabled" {
  description = "Enable the Proxmox firewall on the virtual NIC."
  type        = bool
  default     = false
}

variable "vm_ipv4_mode" {
  description = "IPv4 mode: static or dhcp."
  type        = string
  default     = "static"

  validation {
    condition     = contains(["static", "dhcp"], var.vm_ipv4_mode)
    error_message = "vm_ipv4_mode must be static or dhcp."
  }
}

variable "vm_ipv4_address" {
  description = "Static IPv4 address without prefix; null with DHCP."
  type        = string
  default     = null
  nullable    = true
}

variable "vm_ipv4_prefix" {
  description = "IPv4 CIDR prefix."
  type        = number
  default     = 24

  validation {
    condition     = var.vm_ipv4_prefix >= 1 && var.vm_ipv4_prefix <= 32
    error_message = "vm_ipv4_prefix must be between 1 and 32."
  }
}

variable "vm_ipv4_gateway" {
  description = "IPv4 gateway; null with DHCP."
  type        = string
  default     = null
  nullable    = true
}

variable "dns_servers" {
  description = "VM DNS servers."
  type        = list(string)
  default     = []
}

variable "vm_username" {
  description = "Administrative user created/configured by Cloud-Init."
  type        = string
}

variable "vm_password" {
  description = "Optional Cloud-Init user password. If null, access uses only the SSH key. Terraform stores it in plain text in the state."
  type        = string
  default     = null
  nullable    = true
  sensitive   = true
}

variable "ssh_password_auth_enabled" {
  description = "Enable SSH password login in the guest via a Cloud-Init vendor-data snippet. Requires a snippets-enabled datastore and provider SSH access to the Proxmox node. Defaults to false because cloud images usually disable password auth."
  type        = bool
  default     = false
}

variable "snippet_datastore" {
  description = "Datastore for the Cloud-Init vendor-data snippet. Must have the snippets content type enabled. Used only when ssh_password_auth_enabled is true."
  type        = string
  default     = "local"
}

variable "ssh_public_key" {
  description = "Public SSH key contents. If set, it takes precedence over ssh_public_key_path and allows planning without a local file."
  type        = string
  default     = null
  nullable    = true
}

variable "ssh_public_key_path" {
  description = "Local path to the SSH public key, used only when ssh_public_key is null."
  type        = string
  default     = "~/.ssh/id_ed25519.pub"
}
