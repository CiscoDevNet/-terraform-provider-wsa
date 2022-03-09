################################################################################
# VPC Resources
################################################################################
locals {
  create_vpc = var.vpc_id != null ? false : true
  add_default_route_to_public_rt = var.add_default_route_to_public_rt ? true : false
}

resource "aws_vpc" "wsa_vpc" {
  count                = local.create_vpc ? 1 : 0
  instance_tenancy     = "default"
  enable_dns_hostnames = true

  cidr_block = var.vpc_cidr
  tags = {
    Name = var.vpc_name
  }
}

################################################################################
# Subnets
################################################################################
locals {
  vpc = local.create_vpc ? aws_vpc.wsa_vpc[0].id : var.vpc_id

  public_subnet_count = (
    length(var.public_subnet_cidrs) == 0 ? 0 : var.availability_zone_count
  )

  private_subnet_count = (
    length(var.private_subnet_cidrs) == 0 ? 0 : var.availability_zone_count
  )
}

data "aws_availability_zones" "available" {}

# Create Public Subnet
resource "aws_subnet" "public_subnet" {
  count  = local.public_subnet_count
  vpc_id = local.vpc

  cidr_block = var.public_subnet_cidrs[count.index]

  availability_zone = (
    data.aws_availability_zones.available.names[count.index]
  )

  tags = {
    Name = "${var.vpc_name}-Public-Subnet"
  }
}

# Create Private Subnet
resource "aws_subnet" "private_subnet" {
  count  = local.private_subnet_count
  vpc_id = local.vpc

  cidr_block = var.private_subnet_cidrs[count.index]

  availability_zone = (
    data.aws_availability_zones.available.names[count.index]
  )

  tags = {
    Name = "${var.vpc_name}-Private-Subnet"
  }
}

################################################################################
# Internet Gateway and Routing Tables
################################################################################
data "aws_internet_gateway" "selected" {
  count = local.create_vpc ? 0 : 1

  filter {
    name   = "attachment.vpc-id"
    values = [var.vpc_id]
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = local.vpc

  tags = {
    Name = "InternetGateway"
  }
}

resource "aws_route_table" "igw_rt" {
  vpc_id = local.vpc
  tags = {
    Name = "IGWRouteTable"
  }
}

resource "aws_route_table" "public_rt" {
  count  = local.public_subnet_count > 0 ? 1 : 0
  vpc_id = local.vpc

  tags = {
    Name = "Public-Routing-Table"
  }
}

# resource "aws_route" "public_route_in_public_rt" {
#   count          = (local.add_default_route_to_public_rt == true && local.public_subnet_count > 0) ? 1 : 0
#   route_table_id = aws_route_table.public_rt[0].id
#   destination_cidr_block = "0.0.0.0/0"
#   gateway_id = aws_internet_gateway.igw.id
#   # vpc_endpoint_id = var.internet_access_endpoint == null ? aws_internet_gateway.igw.id : var.internet_access_endpoint
# }

resource "aws_route_table" "private_rt" {
  count  = local.private_subnet_count > 0 ? 1 : 0
  vpc_id = local.vpc

  tags = {
    Name = "Custom Allow"
    Name = "Private-Routing-Table"
  }
}

resource "aws_route" "route_with_gw_in_public_rt" {
  count = (var.internet_access_endpoint == null) ? 1 : 0
  route_table_id = aws_route_table.public_rt[0].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.igw.id
}

resource "aws_route" "route_with_endpoint_in_public_rt" {
  count = (var.internet_access_endpoint != null) ? 1 : 0
  route_table_id = aws_route_table.public_rt[0].id
  destination_cidr_block = "0.0.0.0/0"
  vpc_endpoint_id = var.internet_access_endpoint
}

resource "aws_route" "route_with_gw_in_private_rt" {
  count = (var.internet_access_endpoint == null) ? 1 : 0
  route_table_id = aws_route_table.private_rt[0].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.igw.id
}

resource "aws_route" "route_with_endpoint_in_private_rt" {
  count = (var.internet_access_endpoint != null) ? 1 : 0
  route_table_id = aws_route_table.private_rt[0].id
  destination_cidr_block = "0.0.0.0/0"
  vpc_endpoint_id = var.internet_access_endpoint
}




# resource "aws_route" "public_route_in_private_rt" {
#   count          = (local.add_default_route_to_public_rt == true && local.public_subnet_count > 0) ? 1 : 0
#   route_table_id = aws_route_table.private_rt[0].id
#   destination_cidr_block = "0.0.0.0/0"
#   gateway_id = aws_internet_gateway.igw.id
#   # vpc_endpoint_id = var.internet_access_endpoint == null ? aws_internet_gateway.igw.id : var.internet_access_endpoint
# }

resource "aws_route_table_association" "private_subnet_association" {
  count          = local.private_subnet_count
  subnet_id      = aws_subnet.private_subnet[count.index].id
  route_table_id = aws_route_table.private_rt[0].id
}

resource "aws_route_table_association" "public_subnet_association" {
  count          = local.public_subnet_count
  subnet_id      = aws_subnet.public_subnet[count.index].id
  route_table_id = aws_route_table.public_rt[0].id
}

resource "aws_route_table_association" "igw_rt_association" {
  gateway_id     = aws_internet_gateway.igw.id
  route_table_id = aws_route_table.igw_rt.id
}

################################################################################
# Network Interfaces
################################################################################
locals {
  number_of_instances = var.availability_zone_count * var.instances_per_az

  private_ips_mgmt = (
    [
      for i in range(var.availability_zone_count * var.instances_per_az) :
      (var.wsa_mgmt_ips != null ? var.wsa_mgmt_ips[i] : null)
    ]
  )

  private_ips_data = (
    [
      for i in range(var.availability_zone_count * var.instances_per_az) :
      (var.wsa_data_ips != null ? var.wsa_data_ips[i] : null)
    ]
  )
}

# Create Management Network Interface
resource "aws_network_interface" "wsa_mgmt" {
  description       = "wsa-mgmt-interface"
  source_dest_check = false

  count = var.create_network_interfaces ? local.number_of_instances : 0

  # subnet_id = (
  #   local.private_subnet_count == 0 ?
  #   aws_subnet.public_subnet[floor(count.index / var.instances_per_az)].id :
  #   aws_subnet.private_subnet[floor(count.index / var.instances_per_az)].id
  # )

  subnet_id = (
    local.public_subnet_count > 0 ?
    aws_subnet.public_subnet[floor(count.index / var.instances_per_az)].id :
    aws_subnet.private_subnet[floor(count.index / var.instances_per_az)].id
  )

  private_ips     = local.private_ips_mgmt[count.index]
  security_groups = var.sg_mgmt
}

# Create Data Network Interface
resource "aws_network_interface" "wsa_data" {
  description       = "wsa-data-interface"
  source_dest_check = false

  count = (
    local.private_subnet_count == 0 ?
    ((var.create_network_interfaces ? local.number_of_instances : 0)) :
    local.number_of_instances
  )

  subnet_id = (
    local.private_subnet_count == 0 ?
    aws_subnet.public_subnet[floor(count.index / var.instances_per_az)].id :
    aws_subnet.private_subnet[floor(count.index / var.instances_per_az)].id
  )

  private_ips     = local.private_ips_data[count.index]
  security_groups = var.sg_data
}

################################################################################
# Elastic IPs
################################################################################
resource "aws_eip" "wsa_mgmt_eip" {
  count = var.create_mgmt_eip ? local.number_of_instances : 0
  vpc   = true

  network_interface = aws_network_interface.wsa_mgmt[count.index].id

  tags = {
    "Name" = "WSA-Management-IP"
  }
}

resource "aws_eip" "wsa_data_eip" {
  count = var.create_data_eip ? local.number_of_instances : 0
  vpc   = true

  network_interface = aws_network_interface.wsa_data[count.index].id

  tags = {
    "Name" = "WSA-Data-IP"
  }
}

resource "aws_eip" "wsa_nlb" {
  count = var.create_load_balancer_eip ? local.public_subnet_count : 0
  vpc   = true

  tags = {
    "Name" = "WSA-NLB-IP"
  }
}
