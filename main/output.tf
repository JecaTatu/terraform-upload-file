output "bucket_name" {
  description = "bucket name."
  value = resource.aws_s3_bucket.b1.bucket
}

output "file1_name" {
  description = "file 1 name."
  value = resource.aws_s3_bucket_object.object_1.key
}

output "file2_name" {
  description = "file 2 name."
  value = resource.aws_s3_bucket_object.object_2.key
}