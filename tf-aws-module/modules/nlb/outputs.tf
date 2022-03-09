output "nlb_dns_name" {
  description = "The name of the NLB"
  value       = concat([], aws_lb.external_lb.*.dns_name)
}
