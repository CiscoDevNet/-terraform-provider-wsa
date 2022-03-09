
# Complete WSAV

Configuration in this directory creates set of resources which can be used
to deploy wsav instances in the network

The wsav instances in this configuration uses sepearte interfaces
for management(eth0) and data interface(eth1)

There is a public and private subnet created per availability zone
in addition to single Internet Gateway shared between all availability zones.

The management interface(eth1) is deployed in the public interface
and is configured to use elastic ip in thsi configuration.

Creates a Network Load balancer with subnet and elastic IP mappings,
used to direct traffic to the data interfaces of the instances
deployed in the private subnet

## Usage

To run this example you need to execute:
```bash
$ terraform init
$ terraform plan
$ terraform apply
```

## Requirements

| Name      | Type   |
| ----------| ------ |
| terraform | >= 1.0.5 |
| aws| >= 3.56.0 |

## Providers
| Name      | Type   |
| ----------| ------ |
| aws| >= 3.56.0|

## Modules
| Name      | Source |  
| ----------| ------ |
| security| ../../modules/security-groups |
| network | ../../modules/vpc |
| wsav | ../../modules/wsav-instances |
| load_balancer| ../../modules/nlb |


## Resources

No resources.

## Inputs

| Name      | Description   | Type   | Default | Required |
| ----------| ------------- | ------ | ------- | -------- |
| aws_access_key | AWS access key |  string | configure via aws cli | yes |
| aws_secret_key | AWS secret key | string | configure via aws cli | yes |
| region         | AWS region to deploy the instance | string | us-east-2 | yes |


## Outputs

| Name      | Description   |
| ----------| ------ |
| wsav.instance_ids | Instance ID of the WSAv |
| load_balancer_dns_name | Load balanacer dns name |
