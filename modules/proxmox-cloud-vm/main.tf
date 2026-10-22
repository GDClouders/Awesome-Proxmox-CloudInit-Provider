locals {
  ssh_public_key = (
    var.ssh_public_key != null
    ? trimspace(var.ssh_public_key)
    : trimspace(file(pathexpand(var.ssh_public_key_path)))
  )

  vm_ipv4_address = (
    var.vm_ipv4_mode == "dhcp"
    ? "dhcp"
    : (var.vm_ipv4_address == null ? null : "${var.vm_ipv4_address}/${var.vm_ipv4_prefix}")
  )

  vendor_data_lines = concat(
    ["#cloud-config"],
    var.ssh_password_auth_enabled ? ["ssh_pwauth: true"] : [],
    var.install_qemu_guest_agent ? [
      "runcmd:",
      "  - |",
      "    install_status=0",
      "    if command -v apt-get >/dev/null 2>&1; then",
      "      apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y ${var.guest_agent_package} || install_status=1",
      "    elif command -v dnf >/dev/null 2>&1; then",
      "      dnf install -y ${var.guest_agent_package} || install_status=1",
      "    elif command -v yum >/dev/null 2>&1; then",
      "      yum install -y ${var.guest_agent_package} || install_status=1",
      "    elif command -v pacman >/dev/null 2>&1; then",
      "      if ! pacman -Qq ${var.guest_agent_package} >/dev/null 2>&1; then",
      "        pacman -Syu --needed --noconfirm ${var.guest_agent_package} || install_status=1",
      "      fi",
      "    else",
      "      echo 'Unsupported package manager' >&2",
      "      install_status=1",
      "    fi",
      "    if [ \"$install_status\" -ne 0 ]; then",
      "      echo 'Package install failed; checking existing agent service' >&2",
      "    fi",
      "    if ! systemctl enable --now ${var.guest_agent_service}; then",
      "      echo 'Failed to enable the guest agent service' >&2",
      "      exit 1",
      "    fi",
      "    exit 0",
    ] : [],
  )

  vendor_data_enabled = var.ssh_password_auth_enabled || var.install_qemu_guest_agent
}

resource "proxmox_download_file" "cloud_image" {
  content_type = "import"
  datastore_id = var.image_datastore
  node_name    = var.proxmox_node

  url                = var.cloud_image_url
  file_name          = var.cloud_image_file_name
  checksum           = var.cloud_image_checksum
  checksum_algorithm = var.cloud_image_checksum_algorithm
  overwrite          = var.cloud_image_overwrite
  upload_timeout     = var.cloud_image_download_timeout

  lifecycle {
    precondition {
      condition     = (var.cloud_image_checksum == null) == (var.cloud_image_checksum_algorithm == null)
      error_message = "cloud_image_checksum and cloud_image_checksum_algorithm must be set together."
    }
  }
}

resource "proxmox_virtual_environment_file" "vendor_data" {
  count = local.vendor_data_enabled ? 1 : 0

  content_type = "snippets"
  datastore_id = var.snippet_datastore
  node_name    = var.proxmox_node
  overwrite    = true

  source_raw {
    data      = "${join("\n", local.vendor_data_lines)}\n"
    file_name = "vm-${var.vm_id}-vendor-data.yaml"
  }
}

resource "proxmox_virtual_environment_vm" "this" {
  name        = var.vm_hostname
  description = var.vm_description
  node_name   = var.proxmox_node
  vm_id       = var.vm_id
  tags        = var.vm_tags

  started         = var.vm_started
  stop_on_destroy = var.vm_stop_on_destroy

  lifecycle {
    precondition {
      condition     = var.vm_ipv4_mode == "dhcp" || (var.vm_ipv4_address != null && var.vm_ipv4_gateway != null)
      error_message = "With vm_ipv4_mode=static you must specify vm_ipv4_address and vm_ipv4_gateway."
    }

    precondition {
      condition     = var.vm_bios != "ovmf" || var.vm_efi_disk_enabled
      error_message = "With vm_bios=ovmf you must set vm_efi_disk_enabled=true."
    }
  }

  machine = var.vm_machine
  bios    = var.vm_bios

  startup {
    order      = var.vm_startup_order
    up_delay   = var.vm_startup_up_delay
    down_delay = var.vm_startup_down_delay
  }

  operating_system {
    type = var.vm_operating_system_type
  }

  agent {
    enabled = var.qemu_agent_enabled
    timeout = var.qemu_agent_timeout
  }

  cpu {
    cores   = var.vm_cpu_cores
    sockets = var.vm_cpu_sockets
    type    = var.vm_cpu_type
  }

  memory {
    dedicated = var.vm_memory_mb
    floating  = var.vm_memory_balloon_mb
  }

  disk {
    datastore_id = var.vm_datastore
    import_from  = proxmox_download_file.cloud_image.id
    interface    = var.vm_disk_interface
    size         = var.vm_disk_size_gb
    cache        = var.vm_disk_cache
    iothread     = var.vm_disk_iothread
    discard      = var.vm_disk_discard
    ssd          = var.vm_disk_ssd
  }

  dynamic "efi_disk" {
    for_each = var.vm_efi_disk_enabled ? [1] : []

    content {
      datastore_id = var.vm_datastore
      type         = "4m"
    }
  }

  network_device {
    bridge   = var.network_bridge
    model    = var.network_model
    vlan_id  = var.network_vlan_id
    firewall = var.network_firewall_enabled
  }

  initialization {
    datastore_id = var.vm_datastore

    vendor_data_file_id = (
      local.vendor_data_enabled
      ? proxmox_virtual_environment_file.vendor_data[0].id
      : null
    )

    dns {
      domain  = var.vm_domain
      servers = var.dns_servers
    }

    ip_config {
      ipv4 {
        address = local.vm_ipv4_address
        gateway = var.vm_ipv4_mode == "dhcp" ? null : var.vm_ipv4_gateway
      }
    }

    user_account {
      username = var.vm_username
      password = var.vm_password
      keys     = [local.ssh_public_key]
    }
  }
}
