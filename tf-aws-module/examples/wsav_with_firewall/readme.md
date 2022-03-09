
# WSAV with firewall

This example creates WSA instance along with AWS network firewall.

For network toplogy, please take a look into firewall module.

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
| firewall | ../../modules/firewall |

## Inputs

| Name      | Description   | Type   | Default | Required |
| ----------| ------------- | ------ | ------- | -------- |
| aws_access_key | AWS access key |  string | configure via aws cli | yes |
| aws_secret_key | AWS secret key | string | configure via aws cli | yes |
| region         | AWS region to deploy the instance | string | us-east-2 | yes |

## Outputs

Currently none.
