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
  region  = "us-east-2"
}


resource "aws_s3_bucket" "b1" {
  bucket = "gas5-terraform-bucket-test"
  acl = "private"

}

resource "aws_s3_bucket_object" "object" {

  bucket = aws_s3_bucket.b1.id
  key    = "new_txt"
  acl    = "private"

  source = "./text1.txt"
  etag = filemd5("./text1.txt")

}