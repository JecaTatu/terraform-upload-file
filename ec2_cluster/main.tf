resource "random_id" "ec2_cluster" {
  keepers = {
    cluster_name = var.cluster_name
  }

  byte_length = 3
}

data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-ebs"]
  }
}

module "ec2_cluster" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "2.19.0"

  name                 = "${var.cluster_name}-${random_id.ec2_cluster.hex}"
  instance_count       = var.instance_count
  iam_instance_profile = var.instance_profile_name
  user_data = file("M:/Work/processo-seletivo/terraform-upload-file/ec2_cluster/scripts/install_docker.sh")

  ami                    = data.aws_ami.amazon_linux_2.id
  instance_type          = var.instance_type
  monitoring             = true
  vpc_security_group_ids = [aws_security_group.allow_alb.id]
  subnet_ids             = var.subnets_ids
}