output "instance_public_dnss" {
  description = "Public_DNS of the WSA instance created"
  value       = concat([], vsphere_virtual_machine.vm.*.name)
}

output "ssw_password" {
  description = "ID of the WSA instance created"
  value       = var.boot_config.ssw_password
}