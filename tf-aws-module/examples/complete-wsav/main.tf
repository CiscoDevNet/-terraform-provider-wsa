################################################################################
# AWS Provider
################################################################################
provider "aws" {
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  region     = var.region
}

locals {
  # instance count
  availability_zone_count = 3
  instances_per_az        = 1

  # interfaces
  create_network_interfaces = true

  # elastic_ips
  create_mgmt_eip = true
  create_data_eip = false

  # load Balancer
  create_lb                = true
  create_load_balancer_eip = true
}

################################################################################
# Security Module
################################################################################
module "security" {
  source = "../../modules/security-groups"

  vpc_id = module.network.vpc_id
  #vpc_id = "vpc-032af6698fe0ac080"

  allow_mgmt_ports = {
    "rule1" = {
      from_port   = 8443
      to_port     = 8443
      protocol    = "tcp"
      cidr_blocks = ["72.163.220.26/32"]
      description = "HTTP"
    },
    "rule2" = {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["72.163.220.26/32"]
      description = "SSH"
    },
    "rule3" = {
      from_port   = 4431
      to_port     = 4431
      protocol    = "tcp"
      cidr_blocks = ["72.163.220.26/32"]
      description = "REST"
    },
    "rule4" = {
      from_port   = -1
      to_port     = -1
      protocol    = "icmp"
      cidr_blocks = ["72.163.220.26/32"]
      description = "PING"
    },
    "rule5" = {
      from_port   = -1
      to_port     = -1
      protocol    = "icmp"
      cidr_blocks = ["72.163.220.26/32"]
      description = "PING"
    }
  }

  allow_data_ports = {
    "rule1" = {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["72.163.220.26/32"]
      description = "PROXY 1"
    },
    "rule2" = {
      from_port   = 3128
      to_port     = 3128
      protocol    = "tcp"
      cidr_blocks = ["72.163.220.26/32"]
      description = "PROXY 2"
    }
  }
}

################################################################################
# Network Module
################################################################################
module "network" {
  source = "../../modules/vpc"

  /*********************************************
  * If vpc_id is not provided, a new VPC will
  * be created with given vpc_cidr and vpc_name
  * Provide one of the following -
  * 1. vpc_id
  * 2. vpc_cidr and vpc_name
  **********************************************/
  # vpc_id = "vpc-032af6698fe0ac080" # Existing VPC
  vpc_cidr = "10.0.0.0/16" # New VPC CIDR
  vpc_name = "vpc-wsav"    # New VPC Name

  # subnets should be equal to the number of instances
  public_subnet_cidrs  = ["10.0.7.0/24", "10.0.8.0/24", "10.0.9.0/24"]
  private_subnet_cidrs = ["10.0.10.0/24", "10.0.11.0/24", "10.0.12.0/24"]

  /*********************************************
  * private_ip list [primary, secondary] should
  * be equal to the number of instances.
  * secondary ip is optional. If wsa_mgmt_ips,
  * wsa_data_ips are not provided, will be
  * auto-assigned
  **********************************************/
  #wsa_mgmt_ips     = [["10.0.0.10", "10.0.0.11"], ["10.0.0.12"]]
  #wsa_data_ips     = [["10.0.1.10", "10.0.1.11"], ["10.0.1.12"]]

  /*********************************************
  * security groups for data and management
  * interface
  **********************************************/
  sg_data = [module.security.sg_data]
  sg_mgmt = [module.security.sg_mgmt]

  # Number of instance to be created - defined in locals
  availability_zone_count = local.availability_zone_count
  instances_per_az        = local.instances_per_az

  # create multiple network interfaces - defined in locals
  create_network_interfaces = local.create_network_interfaces

  # eip allocations
  create_mgmt_eip          = local.create_mgmt_eip
  create_data_eip          = local.create_data_eip
  create_load_balancer_eip = local.create_load_balancer_eip
}

################################################################################
# WSAv Instance Module
################################################################################
module "wsav" {
  source = "../../modules/wsav-instances"

  /*********************************************
  * Provide one of the following -
  * 1. wsa_model and wsa_version
  * 2. ami_id, instance_type and volume_size
  **********************************************/
  # Available wsa versions: S100V, S300V, S600V
  #wsa_model   = "S300V"
  #wsa_version = "coeus-14-0-1"

  ami_id        = "ami-0f88dd74a14d7d766"
  instance_type = "c4.2xlarge"
  volume_size   = 1000

  /*********************************************
  * If create_key_pair is true, it will create
  * a key pair for the instance with given
  * key_pair_name
  * The private key pem file will be stored in
  * current directory
  * For create_key_pair set to false, it will
  * assign the existing key pair in AWS
  * with key name given in key_pair_name
  **********************************************/
  create_key_pair = true
  key_pair_name   = "wsa_key_pair" # Existing/New key pair name

  # The name of the wsa instance
  wsav_tags = {
    Name = "WSA-Instance"
  }

  # Number of instance to be created - defined in locals
  number_of_instances = local.availability_zone_count * local.instances_per_az

  /*********************************************
  * Provide one of the following -
  * 1. default interface - subnet_id, security_groups
  * and associate_public_ip_address
  * 2. multiple interface - create_network_interfaces,
  * data_network_interface and mgmt_network_interface
  **********************************************/
  # default interface
  # subnet_id                   = module.network.public_subnet_ids.*
  # security_groups             = [module.security.sg_data, module.security.sg_mgmt]
  # associate_public_ip_address = true

  # create multiple network interfaces during boot time - defined in locals
  create_network_interfaces = local.create_network_interfaces
  # output from vpc module
  data_network_interface = module.network.data_nw_interface_ids.*
  mgmt_network_interface = module.network.mgmt_nw_interface_ids.*


  # Boot config
  # For smart_license_token please contact to Cisco sales person.
  smart_license_token = "Put your smart license token here."

  # This password will be used for performing SSW.
  # The plain password must have following properties:
  # 1. At least one upper (A-Z)
  # 2. At least one lower (a-z) case letter.
  # 3. At least one number (0-9).
  # 4. At least one special character.
  # Only base64 encoded version of password will be supported here.
  # So, please encode it before storing it here.
  # Given example is base64 encoded value for 'Cisco@123'. Please change it.
  ssw_password       = "Q2lzY29AMTIz"
  notification_email = "admin@cisco.com"
  mgmt_interface_hostname = module.network.elastic_public_dns_mgmt.*
  # For disabling split routing, comment 4 lines bellow.
  data_interface_hostname = module.network.elastic_public_dns_data.*
  data_interface_private_ip = module.network.data_interface_private_ip.*
  data_interface_netmask = ["24"]
  data_interface_gateway_ip = ["10.0.2.1"]
}

################################################################################
# Elastic Load Balancer
################################################################################
module "load_balancer" {
  source = "../../modules/nlb"

  name = "External-elb"

  create_lb = local.create_lb

  vpc_id = module.network.vpc_id
  # vpc_id  = "vpc-032af6698fe0ac080"
  subnets = module.network.public_subnet_ids.*

  create_load_balancer_eip = local.create_load_balancer_eip
  eip                      = module.network.elastic_ip_nlb.*

  # instances to attach to the load balancer
  instances = module.wsav.instance_ids

  listeners = [{
    port     = 3128
    protocol = "TCP"
    },
    {
      port     = 80
      protocol = "TCP"
    }
  ]

  health_check = {
    port     = 3128
    protocol = "TCP"
    interval = 30
  }
}
