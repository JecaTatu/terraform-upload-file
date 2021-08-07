  
output "security_group_id" {
  value = aws_security_group.allow_alb.id
}

output "public_ip" {
  value = module.loadbalancer.public_ip[0]
}