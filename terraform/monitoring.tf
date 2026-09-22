###############################################################################
# logs

resource "aws_cloudwatch_log_group" "vpc" {
  name = "${local.name}-vpc-lg"
}

resource "aws_cloudwatch_log_group" "ec2" {
  name = "${local.name}-ec2-lg"
}