output "instance_ips" {
  description = "The IPs of the created instances"
  value       = module.my_instance.instance_ips
}

output "instance_hostnames" {
  description = "The hostnames of the created instances"
  value       = module.my_instance.instance_hostnames
}
