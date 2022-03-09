# output "wsav_elastic_public_ip_mgmt" {
#   value = module.eip.elastic_public_ip_mgmt.*
# }
#
# output "wsav_elastic_public_ip_data" {
#   value = module.eip.elastic_public_ip_data.*
# }
#
output "instance" {
  value = module.wsav.instance_ids
}

# output "data_nw_interface_ids" {
#   value = concat(module.vpc.data_nw_interface_ids.*, [""])
# }
#
# output "mgmt_nw_interface_ids" {
#   value = join(", ", module.vpc.mgmt_nw_interface_ids.*)
# }

# output "data_nw_interface_ids" {
#   value = module.vpc.data_nw_interface_ids.*
# }
#
# output "mgmt_nw_interface_ids" {
#   value = module.vpc.mgmt_nw_interface_ids.*
# }

################################################
# Values used by Configuration management module
################################################
output "ALL_WSA" {
#  value = module.wsav.public_dns
   value = module.wsav.instance_public_dnss
}

output "WSA_USERNAME" {
  value = "admin"
}

output "WSA_PASSWORD" {
   value = module.wsav.ssw_password
}

output "WSA_PORT" {
  value = 4431
}
################################################