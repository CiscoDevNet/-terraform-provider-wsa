data "vsphere_datacenter" "dc" {
  name = var.dc
}

data "vsphere_datastore" "datastore" {
  name          = var.vs_datastore
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_resource_pool" "pool" {
  name          = var.vs_resource_pool
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_network" "Mgmt" {
  name          = var.vs_network_management
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_network" "P1" {
  name          = var.vs_network_data1
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_network" "P2" {
  name          = var.vs_network_data2
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_host" "host" {
  name          = var.vs_host_cluster
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_ovf_vm_template" "ovf" {
  name             = var.virtual_machine_name
  resource_pool_id = data.vsphere_resource_pool.pool.id
  datastore_id     = data.vsphere_datastore.datastore.id
  host_system_id   = data.vsphere_host.host.id
  folder           = var.folder_in_vsphere
  local_ovf_path   = var.ovf_file
}

resource "vsphere_virtual_machine" "vm" {
  datacenter_id = data.vsphere_datacenter.dc.id

  name             = data.vsphere_ovf_vm_template.ovf.name
  num_cpus         = data.vsphere_ovf_vm_template.ovf.num_cpus
  memory           = data.vsphere_ovf_vm_template.ovf.memory
  guest_id         = data.vsphere_ovf_vm_template.ovf.guest_id
  resource_pool_id = data.vsphere_ovf_vm_template.ovf.resource_pool_id
  datastore_id     = data.vsphere_ovf_vm_template.ovf.datastore_id
  host_system_id   = data.vsphere_ovf_vm_template.ovf.host_system_id
  wait_for_guest_net_timeout = 0
  wait_for_guest_ip_timeout  = 0
  scsi_type = "lsilogic"
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
  ovf_deploy {
    disk_provisioning    = var.disk_provisioning
    local_ovf_path       = data.vsphere_ovf_vm_template.ovf.local_ovf_path
  }
  provisioner "local-exec" {
    # This provisioner will do following things:
    # 1. Load smart license
    # 2. Perform SSW
    # 3. Requests for some License Authorization, which are necessary
    #    to run some traffic
    command = "python3 ../../scripts/python_scripts/first_boot_config/first_boot_config.py -st ${var.boot_config.smart_license_registration_token} -hn ${self.name} -sp ${var.boot_config.ssw_password} -ne ${var.boot_config.notification_email}"
  }
}