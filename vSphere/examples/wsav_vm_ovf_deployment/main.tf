################################################################################
# VMware ESXi - Provider
################################################################################

provider "vsphere" {
  user = var.vsphere_user
  password = var.vsphere_password
  vsphere_server = var.vsphere_host
  allow_unverified_ssl = true
}

################################################################################
# Cisco WSAv ESXi VM
################################################################################
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
  boot_config = {
    # For smart_license_registration_token please contact with Cisco sales person.
    smart_license_registration_token = "MWU2NWE5YTgtYmE2NC00ZDExLTlmY2QtODE0ZTkwMjMxNTY4LTE2NDA4NTI3%0AMjYyNjZ8VUE4c1lUSlNldFcrb1Q2bzIyVS9saUdTU3hQOGlRdGZNQkVJQUJl%0AMnM5QT0%3D%0A"
    # smart_license_registration_token = "ZTEzZGQ5MzYtODA1OS00NjZmLTkxM2ItNmYxMjkzOWEwMzA1LTE2NTUyNzU5%0AMTI3OTh8bGM1UXV2UjBSR1RmdTBxVFN0QXhNRkY5R1NZaFlqUmRyWUFUYStn%0AZ1Rzcz0%3D%0A"
    # This password will be used for performing SSW.
    # The plain password must have following properties:
    # 1. At least one upper (A-Z)
    # 2. At least one lower (a-z) case letter.
    # 3. At least one number (0-9).
    # 4. At least one special character.
    # Only base64 encoded version of password will be supported here.
    # So, please encode it before storing it here.
    # Given example is base64 encoded value for 'Cisco@123'. Please change it.
    ssw_password       = "Q2lzY29AMTIz"
    notification_email = "admin@cisco.com"
  }
}

