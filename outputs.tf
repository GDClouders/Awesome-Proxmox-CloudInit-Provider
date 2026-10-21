output "vm_id" {
  description = "ID della VM."
  value       = module.vm.vm_id
}

output "vm_name" {
  description = "Nome della VM."
  value       = module.vm.vm_name
}

output "vm_fqdn" {
  description = "FQDN della VM."
  value       = module.vm.vm_fqdn
}

output "vm_ip_address" {
  description = "Indirizzo IPv4 configurato o indicazione DHCP."
  value       = module.vm.vm_ip_address
}

output "ssh_command" {
  description = "Comando SSH suggerito."
  value       = module.vm.ssh_command
}
