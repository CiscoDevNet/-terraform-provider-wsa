output "load_balancer_dns_name" {
  value = module.load_balancer.nlb_dns_name
}

output "instance_ids" {
  value = module.wsav.instance_ids
}
