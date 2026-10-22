output "vm_id" {
  description = "VM ID."
  value       = module.vm.vm_id
}

output "vm_name" {
  description = "VM name."
  value       = module.vm.vm_name
}

output "vm_fqdn" {
  description = "VM FQDN."
  value       = module.vm.vm_fqdn
}

output "vm_ip_address" {
  description = "Configured IPv4 address or DHCP indicator."
  value       = module.vm.vm_ip_address
}

output "ssh_command" {
  description = "Suggested SSH command."
  value       = module.vm.ssh_command
}
