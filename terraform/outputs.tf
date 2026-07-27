###############################################################################
# s3

output "s3_bucket_name" {
  description = "Name of the S3 bucket"
  value       = aws_s3_bucket.postgres.id
}


output "ubuntu_ip" {
  value = aws_instance.ubuntu.public_ip
}