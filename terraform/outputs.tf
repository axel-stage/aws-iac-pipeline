###############################################################################
# s3

output "s3_bucket_name" {
  description = "Name of the S3 bucket"
  value       = aws_s3_bucket.dbserver.id
}

output "dbserver_ip" {
  value = aws_instance.dbserver.public_ip
}

output "dbserver_role_name" {
  value = aws_iam_role.dbserver.name
}