
# AWS EC2 Instance module

Terraform module which creates an EC2 instance of WSA on AWS.


## Usage

**Single WSA EC2 Instance**
```

locals {
  availability_zone_count = 1
  instances_per_az        = 1
}

module "wsav" {
  source = "../../modules/wsav-instances"

  wsa_model   = "S300V"
  wsa_version = "coeus-14-0-1"

  create_key_pair = true
  key_pair_name   = "wsa_key_pair" # Existing/New key pair name

  wsav_tags = {
    Name = "WSA-Instance"
  }

  number_of_instances = local.availability_zone_count * local.instances_per_az

  subnet_id                   = module.network.public_subnet_ids.*
  security_groups             = [module.security.sg_data, module.security.sg_mgmt]
  associate_public_ip_address = true
}
```

**Multiple WSA EC2 Instance**
```
locals {
  availability_zone_count = 3
  instances_per_az        = 2
}

module "wsav" {
  source = "../../modules/wsav-instances"

  wsa_model   = "S300V"
  wsa_version = "coeus-14-0-1"

  create_key_pair = true
  key_pair_name   = "wsa_key_pair" # Existing/New key pair name

  wsav_tags = {
    Name = "WSA-Instance"
  }

  number_of_instances = local.availability_zone_count * local.instances_per_az

  subnet_id                   = module.network.public_subnet_ids.*
  security_groups             = [module.security.sg_data, module.security.sg_mgmt]
  associate_public_ip_address = true
}
```

**WSA EC2 Instance with multiple Network Interfaces**
```
locals {
  availability_zone_count = 3
  instances_per_az        = 2

  create_network_interfaces = true
}

module "wsav" {
  source = "../../modules/wsav-instances"

  wsa_model   = "S300V"
  wsa_version = "coeus-14-0-1"

  create_key_pair = true
  key_pair_name   = "wsa_key_pair" # Existing/New key pair name

  wsav_tags = {
    Name = "WSA-Instance"
  }

  number_of_instances = local.availability_zone_count * local.instances_per_az

  create_network_interfaces = local.create_network_interfaces

  data_network_interface = module.network.data_nw_interface_ids.*
  mgmt_network_interface = module.network.mgmt_nw_interface_ids.*
}
```


## Conditional creation
The following combinations are supported to conditionally create resources:


* ###  AMI Id, instance type and volume size

  Based on model and version of WSA
  ```
   wsa_model   = "S300V"
   wsa_version = "coeus-14-0-1"
  ```
  Provide the values for the attributes
  ```
   ami_id        = "ami-0f88dd74a14d7d766"
   instance_type = "c4.2xlarge"
   volume_size   = 1000
   ```

* ### Key Pair

  Creates key pair with provided name
  ```
   create_key_pair = true
   key_pair_name   = "wsa_key_pair"
  ```

  Provide existing key pair name
  ```
   create_key_pair = false
   key_pair_name   = "wsa_key_pair"
  ```

* ### Interface

  Default Interface
  ```
   subnet_id                   = module.network.public_subnet_ids.*
   security_groups             = [module.security.sg_data, module.security.sg_mgmt]
   associate_public_ip_address = true
  ```
  Multiple Interface
  ```
   create_network_interfaces = true
   data_network_interface = module.network.data_nw_interface_ids.*
   mgmt_network_interface = module.network.mgmt_nw_interface_ids.*
  ```

## Notes
* data_network_interface and mgmt_network_interface can't be specified together with subnet_id, security_groups, associate_public_ip_address. If create_network_interfaces is set to true, data_network_interface and mgmt_network_interface will be used otherwise subnet_id, security_groups and associate_public_ip_address will be used. See complete-wsav example for details.
* If ami_id is known, specify ami_id, instance_type and volume_size otherwise ami_id, instance_type and volume size will be configured based on specified wsa_model and wsa_version.
## Resources

| Name      | Type   |
| ----------| ------ |
| aws_instance      | resource |
| tls_private_key | resource |
| aws_key_pair | resource |
| aws_ami | data source|

## Inputs

| Name      | Description   | Type   | Default | Required |
| ----------| ------------- | ------ | ------- | -------- |
| wsa_model      | Model type of WSA |  string | null | yes |
| wsa_version   | Version of WSA to be used | string | null | yes |
| ami_id         | ID of AMI to use for the instance | string | null | no |
| instance_type   | The type of instance to start | string | null | no |
| volume_size    | The storage type of the instance | number | null | no |
| create_key_pair | Whether to create a key pair | bool | true | no |
| key_pair_name | Name of the key pair to be created or existing key pair name if create_key_pair is set to false | string | WSA-AUTOGEN-KP | no |
| wsav_tags | A mapping of tags to assign to the resource | map(string) | {} | no |
| number_of_instances | Number of instances to be created | number | 1 | no |
| subnet_id | The VPC Subnet ID to launch in | list(string) | null | yes |
| security_groups | A list of security group IDs to associate with | list(string) | null | yes |
| associate_public_ip_address | Whether to associate a public IP address with an instance in a VPC | bool | null | no |
| create_network_interfaces | Whether to create customized network interfaces to be attached at instance boot time | bool | false | no |
| mgmt_network_interface  | Primary network interface (eth0) to be used for Management Data | list(string) | null | no |
| data_network_interface | Secondary network interface (eth1) to be used for data | list(string) | null | no |

## Outputs

| Name      | Description   |
| ----------| ------ |
| instance_ids      | ID of the WSA instance created |
