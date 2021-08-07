resource "random_id" "security_group" {
  keepers = {
    security_group = var.cluster_name
  }

  byte_length = 3
}


resource "aws_security_group" "allow_alb" {
  name        = "allow-alb-${var.cluster_name}-${random_id.security_group.hex}"
  description = "Allows alb to serve the files in the S3 bucket from cluster ${var.cluster_name}"
  vpc_id      = var.vpc_id

  ingress {
    description = "Allows connection to s3 from cluster"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    security_groups = [var.lb_security_group]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}