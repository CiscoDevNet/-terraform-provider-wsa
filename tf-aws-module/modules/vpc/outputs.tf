output "vpc_id" {
  description = "ID of the VPC created"
  value       = join("", aws_vpc.wsa_vpc.*.id)
}

output "data_nw_interface_ids" {
  description = "Network interface IP created"
  value       = concat([], aws_network_interface.wsa_data.*.id)
}

output "mgmt_nw_interface_ids" {
  description = "Network interface IP created"
  value       = concat([], aws_network_interface.wsa_mgmt.*.id)
}

output "public_subnet_ids" {
  description = "subnet ids created"
  value       = concat([], aws_subnet.public_subnet.*.id)
}

output "private_subnet_ids" {
  description = "subnet ids created "
  value       = concat([], aws_subnet.private_subnet.*.id)
}

output "elastic_public_ip_mgmt" {
  description = "Public IP address of Management Interface"
  value       = concat([], aws_eip.wsa_mgmt_eip.*.public_ip)
}

output "elastic_public_ip_data" {
  description = "Public IP address of Data Interface"
  value       = concat([], aws_eip.wsa_data_eip.*.public_ip)
}

output "elastic_ip_nlb" {
  description = "Public IP address of Load Balancer"
  value       = concat([], aws_eip.wsa_nlb.*.id)
}

output "data_interface_private_ip" {
  description = "Private IP address of Network Interface"
  # value       = aws_eip.wsa_data-EIP.*.private_ip
  value = aws_network_interface.wsa_data.*.private_ip
}

output "elastic_public_dns_mgmt" {
  value = aws_eip.wsa_mgmt_eip.*.public_dns
}

output "elastic_public_dns_data" {
  value = aws_eip.wsa_data_eip.*.public_dns
}

output "id" {
  value = aws_vpc.wsa_vpc.*.id
}

output "aws_internet_gateway_id" {
  value = aws_internet_gateway.igw.id
}

output "aws_ec2_route_table_id" {
  value = aws_route_table.public_rt[0].id
}

output "aws_igw_route_table_id" {
  value = aws_route_table.igw_rt.id
}
