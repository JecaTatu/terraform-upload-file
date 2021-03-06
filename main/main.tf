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
  profile = "default"
  region  = var.region
}

resource "random_string" "random_bucket_name" {
  length           = 16
  special          = false
  upper            = false
}


resource "aws_s3_bucket" "b1" {
  bucket = random_string.random_bucket_name.result
  acl = "private"
}

resource "aws_s3_bucket_object" "object_1" {
  bucket = aws_s3_bucket.b1.id
  key    = "test1.txt"
  acl    = "private"

  content = timestamp()
}

resource "aws_s3_bucket_object" "object_2" {
  bucket = aws_s3_bucket.b1.id
  key    = "test2.txt"
  acl    = "private"

  content = timestamp()
}