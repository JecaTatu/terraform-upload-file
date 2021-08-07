output "instances_ids" {
  value = module.ec2_cluster.instance_id
}

output "lb_public_ip" {
  value = module.alb.public_ip
}