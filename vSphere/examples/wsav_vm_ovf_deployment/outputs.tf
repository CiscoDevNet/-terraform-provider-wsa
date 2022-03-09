################################################
# Values used by Configuration management module
################################################
output "ALL_WSA" {
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