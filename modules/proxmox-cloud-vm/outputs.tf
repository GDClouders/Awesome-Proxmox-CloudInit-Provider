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
  value = var.vm_ipv4_mode == "dhcp" ? "Assegnato tramite DHCP" : var.vm_ipv4_address
}

output "ssh_command" {
  value = var.vm_ipv4_mode == "dhcp" ? "Recuperare l'indirizzo dal DHCP o da Proxmox" : "ssh ${var.vm_username}@${var.vm_ipv4_address}"
}
