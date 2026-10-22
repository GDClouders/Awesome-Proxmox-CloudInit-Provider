output "vm_id" {
  value = proxmox_virtual_environment_vm.this.vm_id
}

output "vm_name" {
  value = proxmox_virtual_environment_vm.this.name
}

output "vm_fqdn" {
  value = "${var.vm_hostname}.${var.vm_domain}"
}

output "vm_ip_address" {
  value = (
    var.vm_ipv4_mode == "dhcp"
    ? "Assigned via DHCP"
    : coalesce(var.vm_ipv4_address, "Not configured")
  )
}

output "ssh_command" {
  value = (
    var.vm_ipv4_mode == "dhcp"
    ? "Retrieve the address from DHCP or Proxmox"
    : (var.vm_ipv4_address == null ? "Configure vm_ipv4_address" : "ssh ${var.vm_username}@${var.vm_ipv4_address}")
  )
}
