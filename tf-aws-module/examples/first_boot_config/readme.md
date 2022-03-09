
# first_boot_config

This example creates a WSA instance by performing first time config. It will do following provisioning activities on WSA instance:

1. Enable smart license
2. Register smart license
3. Perform minimal SSW with given admin password and network interfaces.
4. Perform requests for smart licensing entitlements.

After these operations WSA will be ready to handle traffic.


## Usage

To run this example you need to execute:
```bash
$ terraform init
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

## Inputs

| Name      | Description   | Type   | Default | Required |
| ----------| ------------- | ------ | ------- | -------- |
| aws_access_key | AWS access key |  string | configure via aws cli | yes |
| aws_secret_key | AWS secret key | string | configure via aws cli | yes |
| region         | AWS region to deploy the instance | string | us-east-2 | yes |

## Outputs

| Name      | Description   |
| ----------| ------ |
| module.network.elastic_public_ip_mgmt | Public IP of the WSA instance |
