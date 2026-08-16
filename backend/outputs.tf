output "bucket" {
  value = aws_s3_bucket.terraform.id
}

output "key" {
  value = aws_s3_object.terraform.key
}

output "region" {
  value = var.region
}

output "github_actions_role_arn" {
  value = aws_iam_role.github_actions.arn
}
