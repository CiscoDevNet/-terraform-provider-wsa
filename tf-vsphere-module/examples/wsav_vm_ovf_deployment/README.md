

#  WSAv Deployment on VMware ESXi vSphere

Configuration in this directory creates set of resources which can be used
to deploy WSAv virtual machine in the network

The WSAv VM uses the default interface (Network Adapter1) for the management and data
interface


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
| hashicorp/vsphere | >= v2.0.2 |

## Providers
| Name      | Type   |
| ----------| ------ |
| hashicorp/vsphere | >= v2.0.2|


### Login Credentials for the logging in to vSphere
####Usage
  ```
  provider "vsphere" {
  user = var.vsphere_user
  password = var.vsphere_password
  vsphere_server = var.vsphere_host
  allow_unverified_ssl = true
  }
  ```

  * The Username, Password, Hostname can be set from variables.tf file to login to your vSphere host.


## Modules
| Name      | Source |  
| ----------| ------ |
| wsav| ../../modules/wsav_vm_ovf_deployment |


## Resources

No resources.


## Outputs
 Name       |  Description|
| --------- |-------------|
| ALL_WSA |  Qualified DNS name of the WSAv virtual machines |
|WSA_USERNAME|  Default admin login name |
|WSA_PASSWORD|  Default login password |
|WSA_PORT|   Default WSA REST API port  |
