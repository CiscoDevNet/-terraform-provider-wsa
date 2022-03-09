variable "wsa_model" {
  description = "Model type of WSA"
  type        = string
  default     = null
}
variable "wsa_version" {
  description = "Version of WSA to be used"
  type        = string
  default     = null
}

variable "ami_id" {
  description = "ID of AMI to use for the instance"
  type        = string
  default     = null
}

variable "instance_type" {
  description = "The type of instance to start"
  type        = string
  default     = null
}

variable "volume_size" {
  description = "The storage type of the instance"
  type        = number
  default     = null
}

variable "create_key_pair" {
  description = "Whether to create a key pair"
  type        = bool
  default     = true
}

variable "key_pair_name" {
  description = "Name of the key pair to be created or existing key pair name"
  type        = string
  default     = "WSA-AUTOGEN-KP"
}

variable "subnet_id" {
  description = "The VPC Subnet ID to launch in"
  type        = list(string)
  default     = null
}

variable "associate_public_ip_address" {
  description = "Whether to associate a public IP address with an instance in a VPC"
  type        = bool
  default     = null
}

variable "security_groups" {
  description = "A list of security group IDs to associate with"
  type        = list(string)
  default     = null
}

variable "create_network_interfaces" {
  description = "Whether to create customized network interfaces to be attached at instance boot time"
  type        = bool
  default     = false
}

variable "data_network_interface" {
  description = "Secondary network interface (eth1) to be used for data"
  type        = list(string)
  default     = null
}

variable "mgmt_network_interface" {
  description = "Primary network interface (eth0) to be used for Management Data"
  type        = list(string)
  default     = null
}

variable "number_of_instances" {
  description = "Number of instances to be created"
  type        = number
  default     = 1
}

variable "wsav_tags" {
  description = "A mapping of tags to assign to the resource"
  type        = map(string)
  default     = {}
}

variable "smart_license_token" {
  type = string
}

variable "ssw_password" {
  type = string
}

variable "notification_email" {
  type = string
}

variable "mgmt_interface_hostname" {
  type = list(string)
}

variable "data_interface_hostname" {
  type = list(string)
  default = [""]
}

variable "data_interface_private_ip" {
  type = list(string)
  default = [""]
}

variable "data_interface_netmask" {
  type = list(string)
  default = [""]
}

variable "data_interface_gateway_ip" {
  type = list(string)
  default = [""]
}





# variable "boot_config" {
#   type = object({
#     smart_license_token= string
#     ssw_password = string
#     notification_email = string
#     mgmt_interface_hostname = list(string)
#     data_interface_hostname = list(string)
#     data_interface_private_ip = list(string)
#     data_interface_netmask = list(number)
#     data_interface_gateway_ip = list(string)
#   })

#   default = {
#     smart_license_token = ""
#     ssw_password = "Q2lzY29AMTIz"
#     notification_email = "admin@cisco.com"
#     mgmt_interface_hostname = []
#     data_interface_hostname = []
#     data_interface_private_ip = []
#     data_interface_netmask = []
#     data_interface_gateway_ip = []
#   }
# }
