
# AWS Security Group module

Terraform module which creates security groups on AWS.


## Usage

**Create security groups for the instances**
```

module "security" {
  source = "../../modules/security-groups"

  vpc_id = module.network.vpc_id

  allow_mgmt_ports = {
    "rule1" = {
      from_port   = 8443
      to_port     = 8443
      protocol    = "tcp"
      cidr_blocks = ["192.0.2.146/32"]
      description = "HTTP"
    },
    "rule2" = {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["192.0.2.146/32"]
      description = "SSH"
    },
    "rule3" = {
      from_port   = 4431
      to_port     = 4431
      protocol    = "tcp"
      cidr_blocks = ["192.0.2.146/32"]
      description = "REST"
    },
    "rule4" = {
      from_port   = -1
      to_port     = -1
      protocol    = "icmp"
      cidr_blocks = ["192.0.2.146/32"]
      description = "PING"
    },
    "rule5" = {
      from_port   = -1
      to_port     = -1
      protocol    = "icmp"
      cidr_blocks = ["192.0.2.146/32"]
      description = "PING"
    }
  }

  allow_data_ports = {
    "rule1" = {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["192.0.2.146/32"]
      description = "PROXY 1"
    },
    "rule2" = {
      from_port   = 3128
      to_port     = 3128
      protocol    = "tcp"
      cidr_blocks = ["192.0.2.146/32"]
      description = "PROXY 2"
    }
  }
}
```

## Inputs

| Name      | Description   | Type   | Default | Required |
| ----------| ------------- | ------ | ------- | -------- |
| vpc_id      | Id of the existing vpc |  string | null | yes |
| allow_mgmt_ports   | Ingress security group rules for Management | map(any) | null| yes |
| allow_data_ports   | Ingress security group rules for Data | map(any) | null | yes |

## Outputs

| Name      | Description   |
| ----------| ------ |
| sg_mgmt      | ID of the security group created |
| sg_data | ID of the security group created |
