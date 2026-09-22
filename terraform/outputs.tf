###############################################################################
# output

output "s3_bucket_name" {
  description = "Name of the S3 bucket"
  value       = aws_s3_bucket.this.id
}

output "ec2_role_name" {
  value = aws_iam_role.ec2.name
}

output "dbserver_ip" {
  value = aws_instance.dbserver.private_ip
}

output "appserver_ip" {
  value = aws_instance.appserver.private_ip
}

output "local_public_ip" {
  description = "Public IPv4 of the client"
  value       = data.external.local_public_ip.result.ipv4
}

output "bastion_host_eip" {
  description = "Elastic IP of the bastion host"
  value       = aws_eip.bastion.public_ip
}