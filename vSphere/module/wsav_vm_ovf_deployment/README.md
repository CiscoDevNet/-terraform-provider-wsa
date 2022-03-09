
# Vmware ESXi (vSphere) hosted VM module

Terraform module which creates a WSAv virtual machine (VM)
WSA on VMware ESXi (vSphere).


## Usage

**WSAv (Virtual Machine) with multiple Network Interfaces**

```
module "wsav" {
  source = "../../modules/wsav_vm_ovf_deployment"
  virtual_machine_name = "wsa001"
  dc = "pcloud-test-datacenter"
  vs_datastore = "u32c01p07esx11-Lun1"
  vs_resource_pool = "test_RP"
  vs_network_management = "192esx11"
  vs_management_mac = "00:50:56:87:19:86"
  vs_network_data1 = "1760esx11"
  vs_network_data2 = "1760esx11"
  vs_host_cluster = "u32c01p07esx11.cisco.com"
  folder_in_vsphere = "DUTs"
  ovf_file="/home/rtestuser/terraform_automation/deploy_os/coeus-14-0-0-369-S300V.ovf"
  disk_provisioning = "thin"
}
```


## WSAv Deployment Attributes
The following combinations are supported to conditionally create resources:


###  Downloaded WSAv OVF image 

  Provide the values for the attributes of WSAv OVF file
  ```
   ovf_file="/home/rtestuser/terraform_automation/deploy_os/coeus-14-0-0-369-S300V.ovf"
   disk_provisioning = "thin"
   ```


### Network Interface and configuration

  ####Default Interface - Network Adapter1 for management
  ```
  network_interface {
    network_id = "${data.vsphere_network.Mgmt.id}"
    adapter_type         = "e1000"
    use_static_mac       = true
    mac_address          = var.vs_management_mac
  }
  network_interface {
    network_id = "${data.vsphere_network.P1.id}"
  }
  network_interface {
    network_id = "${data.vsphere_network.P2.id}"
  }
  ```

### Notes
* For configuring the network interface on WSAv on first time boot up, the MAC entry needs to be created on the DHCP server. The WSAv appliance fetch the values for IP address of WSAv, DNS server and default route using the DHCP discovery/offer protocol. 
* The file path of the WSAv OVF need to be assigned for the deployment and disk provisioning can be chosen from variety of options like "Thin", "thick provisioned". (Optional) If true, this disk is thin provisioned, with space for the file being allocated on an as-needed basis. Cannot be set to true when eagerly_scrub is true
## Resources

| Name      | Type   |
| ----------| ------ |
|vsphere_virtual_machine| vm|


## Inputs

| Name                  | Description           | Type   | Default | Required |
| --------------------  | --------------------- | ------ | ------- | -------- |
| virtual_machine_name      | Name of the WSAv Virtual machine to be listed on vpshere |  string | null | yes |
| dc | The vsphere datacenter data source can be used to discover the ID of a vSphere datacenter. | string | null | yes |
| vs_datastore         |The vsphere_datastore_data source can be used to discover the ID of a datastore in vSphere. This is useful to fetch the ID of a datastore that you want to use to create virtual machines in using the vsphere_virtual_machine resource. | string | null | yes |
| vs_resource_pool   | The vsphere_resource_pool data source can be used to discover the ID of a resource pool in vSphere. This is useful to fetch the ID of a resource pool that you want to use to create virtual machines in using the vsphere_virtual_machine resource. | string | null | yes |
| vs_network_management    | This is essentially the VLAN to be assigned to the network adapter. This can be any network that can be used as the backing for a network interface for vsphere_virtual_machine that requires a network.  | string | null | yes |
| vs_management_mac | Provide the MAC address as mapped in the DHCP server to auto-configure the IP address and other network components in the deployed WSAv |string | null | no |
| vs_network_data1 | This is the VLAN to be assigned to the network adapter 2 / Data P1 interface, if you're planning to use split routing or a separate interface for the Data Traffic. | string | null | no |
| vs_network_data2 | This is the VLAN to be assigned to the network adapter 2 / Data P2 interface, if you're planning to use split routing (say with P1 as ingress and P2 as egress interface)  | string | null | no |
| vs_host_cluster | The vsphere_compute_cluster resource can be used to create and manage clusters of hosts allowing for resource control of compute resources, load balancing through DRS, and high availability through vSphere HA.| string | null | yes |
| folder_in_vsphere | To launch the VM under a specific directory, the folder name can be assigned using the attribute "folder_in_vsphere"  | string| null | no |
| ovf_file | Locally downloaded OVF file path, which is required to deploy the WSAv image on vSphere | string | null | yes |
| disk_provisioning | disk_provisioning - The disk provisioning. If set, all the disks in the deployed OVF will have the same specified disk type (accepted values {thin, flat, thick, sameAsSource}). | string |  | no |

##Outputs
| Name | Description           |
|------|----------------------|
|instance_public_dnss| Deployed WSA name as per terraform output (***Should be Qualified DNS resolvable name***)|
|ssw_password| Password of the WSAv as configured by the admin in example scripts |