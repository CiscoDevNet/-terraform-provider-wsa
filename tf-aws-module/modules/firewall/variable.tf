variable "vpc_id" {
  default = null
}

variable "vpc_cidr" {
  type = string
}

variable "availability_zone_count" {
  type    = number
  default = 1
}

variable "ec2_route_table_id" {
    type = string
}

variable "ec2_subnet_cidrs" {
  type = list(string)
}

variable "firewall_subnet_cidr" {
    type = string
}

variable "firewall_subnet_name" {
    type = string
    default = "FirewallSubnet"
}

variable "igw_id" {
    type = string
}

variable "igw_route_table_id" {
  type = string
}

variable "firewall_subnet_route_table_name" {
    type = string
    default = "firewallRT"
}

variable "firewall_name" {
    type = string
    default = "NetworkFirewall"
}

variable "firewall_policy_arn" {
  type = string
}

