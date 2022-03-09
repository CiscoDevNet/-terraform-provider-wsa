data "aws_availability_zones" "available" {}

resource "aws_subnet" "firewall_subnet" {
  count      = var.availability_zone_count
  vpc_id     = var.vpc_id
  cidr_block = var.firewall_subnet_cidr
  availability_zone = (
    data.aws_availability_zones.available.names[count.index]
  )
  map_public_ip_on_launch = true
  tags = {
    Name = var.firewall_subnet_name
  }
}

resource "aws_route_table" "firewall_rt" {
  count          = var.availability_zone_count
  vpc_id = var.vpc_id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = var.igw_id
  }
  tags = {
    Name = var.firewall_subnet_route_table_name
  }
}

resource "aws_route_table_association" "firewall_subnet_association" {
  count          = var.availability_zone_count
  subnet_id      = aws_subnet.firewall_subnet[count.index].id
  route_table_id = aws_route_table.firewall_rt[count.index].id
}

resource "aws_route" "ec2_route" {
  count          = var.availability_zone_count
  route_table_id = var.ec2_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  vpc_endpoint_id = tolist(aws_networkfirewall_firewall.nw_firewall.*.firewall_status[0][0].sync_states)[0].attachment[0].endpoint_id
}

resource "aws_route" "igw_route" {
  for_each = toset(var.ec2_subnet_cidrs)
  route_table_id = var.igw_route_table_id
  destination_cidr_block = each.key
  vpc_endpoint_id = tolist(aws_networkfirewall_firewall.nw_firewall.*.firewall_status[0][0].sync_states)[0].attachment[0].endpoint_id
}


resource "aws_networkfirewall_firewall" "nw_firewall" {
    count = var.availability_zone_count
    name = var.firewall_name
    vpc_id = var.vpc_id
    firewall_policy_arn = var.firewall_policy_arn
    subnet_mapping {
        subnet_id = aws_subnet.firewall_subnet[count.index].id
    }
    tags = {
        Name = var.firewall_name
    }
}

