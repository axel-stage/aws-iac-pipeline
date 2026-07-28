###############################################################################
# logs

resource "aws_cloudwatch_log_group" "vpc" {
  name = "${var.project}-${var.environment}-vpc-lg"
}

resource "aws_cloudwatch_log_group" "ec2" {
  name = "${var.project}-${var.environment}-ec2-lg"
}