################################################################################
# Security Groups
################################################################################

resource "aws_security_group" "allow_mgmt" {
  name        = "Allow Custom"
  description = "Allow Traffic from custom IP Range"
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each = var.allow_mgmt_ports
    content {
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
      description = ingress.value.description
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Custom Allow"
  }
}

resource "aws_security_group" "allow_traffic" {
  name        = "Allow All"
  description = "Allow All traffic"
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each = var.allow_data_ports
    content {
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
      description = ingress.value.description
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Data Allow"
  }
}
