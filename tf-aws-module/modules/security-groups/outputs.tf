output "sg_mgmt" {
  description = "ID of the security group created"
  value       = aws_security_group.allow_mgmt.id
}

output "sg_data" {
  description = "ID of the security group created"
  value       = aws_security_group.allow_traffic.id
}
