variable "vpc_id" {
  description = "Id of the existing vpc"
  type        = string
}

variable "allow_mgmt_ports" {
  description = "Ingress security group rules for Management"
  type        = map(any)
}

variable "allow_data_ports" {
  description = "Ingress security group rules for Data"
  type        = map(any)
}
