terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }

  required_version = ">= 0.14.9"
}

provider "aws" {
  region = var.region
}

module "vpc" {
  source = "../vpc"

  name   = "my_test_vpc"
  region = var.region
}

module "alb_instance_profile" {
  source = "../ec2_iam"

  name          = "alb-instance-profile"
  allow_actions = ["ec2:Describe*", "s3:PutObject", "s3:GetObject", "s3:DeleteObject"]
}

module "alb" {
  source = "../alb"

  name                  = "ec2-traefik-alb"
  instance_profile_name = module.alb_instance_profile.name
  instance_type         = "t2.micro"
  subnets_ids           = module.vpc.public_subnets_ids
  vpc_id                = module.vpc.id
}

module "s3" {
  source = "../s3"
}

module "ec2_cluster" {
  source = "../ec2_cluster"

  instance_profile_name = module.alb_instance_profile.name
  cluster_name          = "traefik-cluster"
  instance_count        = 2
  subnets_ids           = module.vpc.public_subnets_ids
  vpc_id                = module.vpc.id
  instance_type         = "t2.micro"
  lb_security_group     = module.alb.security_group_id
}
