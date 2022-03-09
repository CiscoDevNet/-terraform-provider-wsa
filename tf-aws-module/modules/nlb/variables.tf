variable "create_lb" {
  description = "Whether to create load balancer"
  type        = bool
  default     = false
}

variable "name" {
  description = "The name of the ELB"
  type        = string
  default     = null
}

variable "instances" {
  description = "List of instances ID to place in the ELB pool"
  type        = list(string)
  default     = []
}

variable "subnets" {
  description = "A list of subnet IDs to attach to the ELB"
  type        = list(string)
}

variable "create_load_balancer_eip" {
  description = "whether to create elastic ip for the load balancer"
  type        = bool
  default     = false
}
variable "eip" {
  description = "elastic ip of the load balancer"
  type        = list(string)
}

variable "vpc_id" {
  description = "Existing vpc id"
  type        = string
}

variable "elb_tags" {
  description = "A mapping of tags to assign to the resource"
  type        = map(string)
  default     = {}
}

variable "listeners" {
  description = "A list of listener blocks"
  type        = list(map(string))
}

variable "health_check" {
  description = "A health check block"
  type        = map(string)
}
