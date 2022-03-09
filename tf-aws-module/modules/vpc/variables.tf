variable "vpc_id" {
  description = "Id of the existing vpc"
  type        = string
  default     = null
}

variable "vpc_cidr" {
  description = "CIDR of the VPC to be created"
  type        = string
  default     = "10.0.0.0/16"
}

variable "vpc_name" {
  description = "Name of the vpc to be created"
  type        = string
  default     = "vpc-wsav"
}

variable "public_subnet_cidrs" {
  description = "CIDR of the public subnets to be created"
  type        = list(string)
  default     = []
}

variable "private_subnet_cidrs" {
  description = "CIDR of the private subnets to be created"
  type        = list(string)
  default     = []
}

variable "wsa_mgmt_ips" {
  description = "Private ip to be assigned "
  type        = list(list(string))
  default     = null
}

variable "wsa_data_ips" {
  description = "Private ip to be assigned "
  type        = list(list(string))
  default     = null
}

variable "availability_zone_count" {
  description = "Number of availability zone to be created "
  type        = number
  default     = 1
}

variable "instances_per_az" {
  description = "Number of instances to be created per avialbility zone"
  type        = number
  default     = 1
}

variable "sg_mgmt" {
  description = "Security group id to be assigned to the management interface"
  type        = list(string)
  default     = null
}

variable "sg_data" {
  description = "Security group id to be assigned to the data interface"
  type        = list(string)
  default     = null
}

variable "create_network_interfaces" {
  description = "Whether to create multiple network interface for the instance"
  type        = bool
  default     = false
}

variable "create_data_eip" {
  description = "Whether to create eip for the data interface"
  type        = bool
  default     = false
}

variable "create_mgmt_eip" {
  description = "Whether to create eip for the management interface"
  type        = bool
  default     = false
}

variable "create_load_balancer_eip" {
  description = "Whether to create eip for the load balancer "
  type        = bool
  default     = false
}

variable "add_default_route_to_public_rt" {
  type = bool
  default = true
}

variable "internet_access_endpoint" {
  type = string
  default = null
}