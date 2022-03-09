variable "ovf_file" {
  description = "vSphere GuestOS Local OVF"
  type        = string
}

variable "virtual_machine_name" {
  description = "Mandatory field : Name of the deployed virtual machine as visibl on vCenter"
}

variable "vsphere_ovf_vm_template_name" {
  default = "OVF_WSA"
}

variable "dc" {
  description = "vSphere Datastore name"
  type        = string
}

variable "vs_datastore" {
  description = "vSphere Datastore name"
  type        = string
}

variable "vs_resource_pool" {
  description = "vSphere Resource Pool name"
  type        = string
}

variable "vs_network_management" {
  description = "vSphere VM Management Network Config"
  type        = string
}

variable "vs_management_mac" {
  description = "vSphere VM Management MAC Address"
  type        = string
}

variable "vs_network_data1" {
  description = "vSphere VM Data1 / P1 Network Config"
  type        = string
}

variable "vs_network_data2" {
  description = "vSphere VM Data2 / P2 Network Config"
  type        = string
}

variable "vs_host_cluster" {
  description = "vSphere Host or Cluster"
  type        = string
}

variable "folder_in_vsphere" {
  description = "vSphere GuestOS Folder"
  type        = string
}

variable "disk_provisioning" {
  description = "Choose the Disk allocation type : Thin, Thick Layered, Thick Lazy Zero or Same as source format"
  default = "thin"
}

variable "boot_config" {
  type = object({
    smart_license_registration_token = string
    ssw_password                     = string
    notification_email               = string
  })

  default = {
    smart_license_registration_token = ""
    ssw_password                     = "Q2lzY29AMTIz"
    notification_email               = "admin@cisco.com"
  }
}
