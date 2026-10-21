variable "proxmox_endpoint" {
  description = "Endpoint API Proxmox VE, ad esempio https://172.168.100.10:8006/."
  type        = string
}

variable "proxmox_api_token" {
  description = "API token Proxmox nel formato utente@realm!token=secret. Passarlo tramite TF_VAR_proxmox_api_token."
  type        = string
  sensitive   = true
}

variable "proxmox_insecure" {
  description = "Consente il certificato TLS self-signed dell'API Proxmox. Impostare true solo con certificati non attendibili."
  type        = bool
  default     = false
}

variable "proxmox_node" {
  description = "Nodo Proxmox sul quale creare la VM."
  type        = string
}

variable "image_datastore" {
  description = "Datastore usato per scaricare/importare la cloud image."
  type        = string
  default     = "local"
}

variable "cloud_image_url" {
  description = "URL della cloud image compatibile Cloud-Init."
  type        = string
}

variable "cloud_image_file_name" {
  description = "Nome del file immagine su Proxmox. Per immagini QCOW2 pubblicate come .img usare un nome finale .qcow2."
  type        = string
}

variable "cloud_image_checksum" {
  description = "Checksum esadecimale opzionale dell'immagine, senza prefisso algoritmo. Richiede cloud_image_checksum_algorithm."
  type        = string
  default     = null
  nullable    = true
}

variable "cloud_image_checksum_algorithm" {
  description = "Algoritmo del checksum: md5, sha1, sha224, sha256, sha384 o sha512. Richiesto con cloud_image_checksum."
  type        = string
  default     = null
  nullable    = true

  validation {
    condition = (
      var.cloud_image_checksum_algorithm == null ||
      contains(["md5", "sha1", "sha224", "sha256", "sha384", "sha512"], var.cloud_image_checksum_algorithm)
    )
    error_message = "cloud_image_checksum_algorithm deve essere md5, sha1, sha224, sha256, sha384 oppure sha512."
  }
}

variable "cloud_image_overwrite" {
  description = "Se true, riscarica l'immagine quando cambia la dimensione remota o locale. Se false, non esegue controlli e non sostituisce mai il file esistente."
  type        = bool
  default     = false
}

variable "cloud_image_download_timeout" {
  description = "Timeout del download in secondi."
  type        = number
  default     = 1800
}

variable "vm_datastore" {
  description = "Datastore per disco VM, Cloud-Init ed eventuale EFI disk."
  type        = string
}

variable "vm_id" {
  description = "ID numerico univoco della VM."
  type        = number
}

variable "vm_hostname" {
  description = "Hostname corto della VM."
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9][a-zA-Z0-9-]{0,62}$", var.vm_hostname))
    error_message = "vm_hostname deve contenere solo lettere, numeri e trattini, senza iniziare con un trattino."
  }
}

variable "vm_domain" {
  description = "Dominio DNS/search domain della VM."
  type        = string
}

variable "vm_description" {
  description = "Descrizione della VM."
  type        = string
  default     = "VM gestita tramite Terraform"
}

variable "vm_tags" {
  description = "Tag Proxmox assegnati alla VM."
  type        = list(string)
  default     = ["terraform"]
}

variable "vm_started" {
  description = "Avvia la VM dopo la creazione."
  type        = bool
  default     = true
}

variable "vm_stop_on_destroy" {
  description = "Arresta la VM prima della distruzione."
  type        = bool
  default     = true
}

variable "vm_startup_order" {
  description = "Ordine di avvio Proxmox."
  type        = number
  default     = 3
}

variable "vm_startup_up_delay" {
  description = "Ritardo di avvio in secondi."
  type        = number
  default     = 30
}

variable "vm_startup_down_delay" {
  description = "Ritardo di arresto in secondi."
  type        = number
  default     = 30
}

variable "vm_machine" {
  description = "Tipo macchina QEMU."
  type        = string
  default     = "q35"
}

variable "vm_bios" {
  description = "Firmware: seabios oppure ovmf."
  type        = string
  default     = "seabios"

  validation {
    condition     = contains(["seabios", "ovmf"], var.vm_bios)
    error_message = "vm_bios deve essere seabios oppure ovmf."
  }
}

variable "vm_operating_system_type" {
  description = "Tipo sistema operativo Proxmox, ad esempio l26 per Linux."
  type        = string
  default     = "l26"
}

variable "vm_cpu_cores" {
  description = "Core per socket."
  type        = number
  default     = 2
}

variable "vm_cpu_sockets" {
  description = "Numero di socket virtuali."
  type        = number
  default     = 1
}

variable "vm_cpu_type" {
  description = "Tipo CPU QEMU."
  type        = string
  default     = "x86-64-v2-AES"
}

variable "vm_memory_mb" {
  description = "RAM dedicata in MB."
  type        = number
  default     = 2048
}

variable "vm_memory_balloon_mb" {
  description = "RAM minima ballooning in MB. Usare lo stesso valore di vm_memory_mb per evitare ballooning dinamico."
  type        = number
  default     = 2048
}

variable "qemu_agent_enabled" {
  description = "Abilita QEMU Guest Agent lato Proxmox. Impostare true solo se l'agent e installato e attivo nel guest."
  type        = bool
  default     = false
}

variable "qemu_agent_timeout" {
  description = "Durata massima di attesa del QEMU Guest Agent, ad esempio 15m o 90s."
  type        = string
  default     = "15m"
}

variable "vm_disk_size_gb" {
  description = "Dimensione disco in GB. Non deve essere inferiore alla dimensione dell'immagine importata."
  type        = number
  default     = 20
}

variable "vm_disk_interface" {
  description = "Interfaccia disco, ad esempio virtio0 o scsi0."
  type        = string
  default     = "virtio0"
}

variable "vm_disk_iothread" {
  description = "Abilita IO thread sul disco."
  type        = bool
  default     = true
}

variable "vm_disk_discard" {
  description = "Modalita discard/TRIM."
  type        = string
  default     = "on"
}

variable "vm_disk_ssd" {
  description = "Espone il disco come SSD. Ignorato con interfaccia virtio: usare scsi per abilitarlo."
  type        = bool
  default     = false
}

variable "vm_efi_disk_enabled" {
  description = "Crea un EFI disk. Deve essere true quando vm_bios e ovmf."
  type        = bool
  default     = false
}

variable "network_bridge" {
  description = "Bridge Proxmox."
  type        = string
}

variable "network_model" {
  description = "Modello scheda di rete virtuale."
  type        = string
  default     = "virtio"
}

variable "network_vlan_id" {
  description = "VLAN tag; null se la rete e presentata untagged alla VM."
  type        = number
  default     = null
  nullable    = true
}

variable "network_firewall_enabled" {
  description = "Abilita il firewall Proxmox sulla scheda virtuale."
  type        = bool
  default     = false
}

variable "vm_ipv4_mode" {
  description = "Modalita IPv4: static oppure dhcp."
  type        = string
  default     = "static"

  validation {
    condition     = contains(["static", "dhcp"], var.vm_ipv4_mode)
    error_message = "vm_ipv4_mode deve essere static oppure dhcp."
  }
}

variable "vm_ipv4_address" {
  description = "IPv4 statico senza prefisso; null con DHCP."
  type        = string
  default     = null
  nullable    = true
}

variable "vm_ipv4_prefix" {
  description = "Prefisso CIDR IPv4."
  type        = number
  default     = 24

  validation {
    condition     = var.vm_ipv4_prefix >= 1 && var.vm_ipv4_prefix <= 32
    error_message = "vm_ipv4_prefix deve essere compreso tra 1 e 32."
  }
}

variable "vm_ipv4_gateway" {
  description = "Gateway IPv4; null con DHCP."
  type        = string
  default     = null
  nullable    = true
}

variable "dns_servers" {
  description = "Server DNS della VM."
  type        = list(string)
  default     = []
}

variable "vm_username" {
  description = "Utente amministrativo creato/configurato da Cloud-Init."
  type        = string
}

variable "ssh_public_key" {
  description = "Contenuto della chiave SSH pubblica. Se impostato, ha precedenza su ssh_public_key_path e consente il plan senza file locale."
  type        = string
  default     = null
  nullable    = true
}

variable "ssh_public_key_path" {
  description = "Percorso locale della chiave SSH pubblica, usato solo se ssh_public_key e null."
  type        = string
  default     = "~/.ssh/id_ed25519.pub"
}
