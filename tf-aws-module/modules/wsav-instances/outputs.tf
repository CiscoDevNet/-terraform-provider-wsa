output "public_ip" {
  description = "Public IP address of the WSA instance created"
  value       = aws_instance.wsav.*
}

output "instance_ids" {
  description = "ID of the WSA instance created"
  value       = concat([], aws_instance.wsav.*.id)
}

output "instance_public_dnss" {
  description = "Public_DNS of the WSA instance created"
  value       = concat([], aws_instance.wsav.*.public_dns)
}

output "ssw_password" {
  description = "ID of the WSA instance created"
  value       = var.ssw_password
}
