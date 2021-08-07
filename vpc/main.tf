resource "random_id" "vpc" {
  keepers = {
    vpc_name = var.name
  }

  byte_length = 3
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.2.0"

  name = "${var.name}-${random_id.vpc.hex}"

  cidr = "10.0.1.0/24"

  azs             = ["${var.region}a"]
  public_subnets = ["10.0.1.0/24"]
  private_subnets  = []

  enable_nat_gateway = false
  enable_dns_hostnames = true
}