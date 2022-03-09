
# Simple WSAV

Configuration in this directory creates set of resources which can be used
to deploy wsav instance in the network

The wsav instances uses the default interface (eth0) for the management and data
interface

There is a public subnet created for the availability zone


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
