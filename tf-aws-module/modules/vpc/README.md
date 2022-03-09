
# AWS VPC module

Terraform module which creates VPC, subnets, network interfaces and elastic ips on AWS.


## Usage

**Create vpc and subnet for single wsav instance**
```

locals {
  availability_zone_count = 1
}

module "network" {
  source = "../../modules/vpc"

  vpc_cidr = "10.0.0.0/16" # New VPC CIDR
  vpc_name = "vpc-wsav"    # New VPC Name

  # subnets should be equal to the number of availability_zone_count
  public_subnet_cidrs  = ["10.0.1.0/24"]

  availability_zone_count = local.availability_zone_count
}
```

**Create subnet in existing vpc for single wsav instance**
```

locals {
  availability_zone_count = 1
}

module "network" {
  source = "../../modules/vpc"

  vpc_id = "vpc-04995c0b912f29903" # Existing VPC

  # subnets should be equal to the number of availability_zone_count
  public_subnet_cidrs  = ["10.0.1.0/24"]

  availability_zone_count = local.availability_zone_count
}
```

**Create vpc and subnet for multiple wsav instance**
```
locals {
  availability_zone_count = 3
}

module "network" {
  source = "../../modules/vpc"

  vpc_cidr = "10.0.0.0/16" # New VPC CIDR
  vpc_name = "vpc-wsav"    # New VPC Name

  # subnets should be equal to the number of availability_zone_count
  public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]

  availability_zone_count = local.availability_zone_count
}
```

**Create vpc and subnet for wsav instances with multiple Network Interfaces**
```
locals {
  availability_zone_count = 3
  instances_per_az        = 2

  create_network_interfaces = true
}

module "network" {
  source = "../../modules/vpc"

  vpc_cidr = "10.0.0.0/16" # New VPC CIDR
  vpc_name = "vpc-wsav"    # New VPC Name

  # subnets should be equal to the number of availability_zone_count
  public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  private_subnet_cidrs = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]

  wsa_mgmt_ips     = [["10.0.1.10", "10.0.1.11"], ["10.0.2.11"], ["10.0.3.12"]]  # optional
  wsa_data_ips     = [["10.0.4.10", "10.0.4.11"], ["10.0.5.11"], ["10.0.6.12"]]  # optional

  sg_data = [module.security.sg_data]
  sg_mgmt = [module.security.sg_mgmt]

  # Number of instance to be created - defined in locals
  availability_zone_count = local.availability_zone_count
  instances_per_az        = local.instances_per_az

  # create multiple network interfaces - defined in locals
  create_network_interfaces = local.create_network_interfaces

  # eip allocations
  create_mgmt_eip          = local.create_mgmt_eip  # optional
  create_data_eip          = local.create_data_eip  # optional
}
```


## Conditional creation
The following combinations are supported to conditionally create resources:


* ### vpc

  Create vpc
  ```
  vpc_cidr = "10.0.0.0/16" # New VPC CIDR
  vpc_name = "vpc-wsav"    # New VPC Name
  ```
  Existing vpc
  ```
  vpc_id = "vpc-04995c0b912f29903" # Existing VPC
  ```

* ### Subnets

  Assign private ips for subnets.
  Default is auto assigned
  ```
  wsa_mgmt_ips     = [["10.0.0.10", "10.0.0.11"], ["10.0.0.12"]]
  wsa_data_ips     = [["10.0.1.10", "10.0.1.11"], ["10.0.1.12"]]
  ```

* ### Interface

  Create network interfaces
  ```
  create_network_interfaces = true
  ```

* ### Elastic ips

  Create elastic ips
  ```
  create_mgmt_eip          = true
  create_data_eip          = true
  create_load_balancer_eip = true
  ```

## Resources

| Name      | Type   |
| ----------| ------ |
| aws_vpc      | resource |
| aws_subnet | resource |
| aws_internet_gateway | resource |
| aws_route_table | resource |
| aws_route_table_association | resource |
| aws_network_interface | resource |
| aws_eip | resource |
| aws_availability_zones | data source|

## Inputs

| Name      | Description   | Type   | Default | Required |
| ----------| ------------- | ------ | ------- | -------- |
| vpc_id      | Id of the existing vpc |  string | null | no |
| vpc_cidr   | CIDR of the VPC to be created | string | "10.0.0.0/16" | no |
| vpc_name         | Name of the vpc to be created | string | "vpc-wsav"| no |
| public_subnet_cidrs   | CIDR of the public subnets to be created | list(string) | [] | no |
| private_subnet_cidrs    | CIDR of the private subnets to be created  | list(string) | [] | no |
| wsa_mgmt_ips | Private ip to be assigned | list(list(string)) | null | no |
| wsa_data_ips | Private ip to be assigned | list(list(string)) | null | no |
| availability_zone_count | Number of availability zone to be created | number | 1 | no |
| instances_per_az | Number of instances to be created per avialbility zone| number | 1 | no |
| sg_mgmt | Security group id to be assigned to the management interface | list(string) | null | yes |
| sg_data | Security group id to be assigned to the data interface | list(string) | null | yes |
| create_network_interfaces | Whether to create multiple network interface for the instance| bool | false | no |
| create_data_eip | Whether to create eip for the data interface | bool | false | no |
| create_mgmt_eip  | Whether to create eip for the management interface | bool | false | no |
| create_load_balancer_eip | Whether to create eip for the load balancer | bool | false | no |

## Outputs

| Name      | Description   |
| ----------| ------ |
| vpc_id      | ID of the VPC created |
| data_nw_interface_ids | Network interface IP created |
| mgmt_nw_interface_ids | Network interface IP created |
| public_subnet_ids | subnet ids of the public network |
| private_subnet_ids | subnet ids of the private network |
| elastic_public_ip_mgmt | Public IP address of Management Interface |
| elastic_public_ip_data | Public IP address of Data Interface |
| elastic_ip_nlb | Public IP address of Load Balancer |
