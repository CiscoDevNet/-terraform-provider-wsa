output "firewall_endpoint" {
    value = tolist(aws_networkfirewall_firewall.nw_firewall.*.firewall_status[0][0].sync_states)[0].attachment[0].endpoint_id
}

output "ec2_route" {
    value = aws_route.ec2_route
}

output "igw_route" {
    value = aws_route.igw_route
}