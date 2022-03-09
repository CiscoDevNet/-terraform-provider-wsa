
# AWS VPC module

Terraform module which creates VPC, subnets, network interfaces and elastic ips on AWS.


## Usage

**Create load balancer for wsav instance**
```

locals {
  # load Balancer
  create_lb                = true
  create_load_balancer_eip = true
}

module "load_balancer" {
  source = "../../modules/nlb"

  name = "External-elb"

  create_lb = local.create_lb

  vpc_id  = module.network.vpc_id
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
```

## Conditional creation
The following combinations are supported to conditionally create resources:


* ### Load Balancer

  Create load balancer
  ```
  create_lb = true
  ```

* ### EIPs

  Create EIP for load balancer
  ```
  create_load_balancer_eip = true
  eip                      = []
  ```

* ### Interface

  Create network interfaces
  ```
  create_network_interfaces = true
  ```

## Resources

| Name      | Type   |
| ----------| ------ |
| aws_lb      | resource |
| aws_lb_target_group | resource |
| aws_internet_gateway | resource |
| aws_lb_listener | resource |
| aws_lb_target_group_attachment | resource |

## Inputs

| Name      | Description   | Type   | Default | Required |
| ----------| ------------- | ------ | ------- | -------- |
| create_lb      | Whether to create load balancer |  bool | false | yes |
| name   | The name of the ELB| string | null | yes |
| instances         | List of instances ID to place in the ELB pool | list(string) | [] | yes |
| subnets   | A list of subnet IDs to attach to the ELB | list(string) | null | yes |
| create_load_balancer_eip    | Ehether to create elastic ip for the load balancer  | bool | false | no |
| eip | Elastic ip of the load balancer| list(string) | null | no |
| vpc_id | Existing vpc id | string | null | yes |
| elb_tags | A mapping of tags to assign to the resource| map(string) | {} | no |
| listeners | A list of listener blocks | list(map(string)) | null | yes |
| health_check | A health check block | map(string) | null | yes |

## Outputs

| Name      | Description   |
| ----------| ------ |
| nlb_dns_name      | The name of the NLB |
