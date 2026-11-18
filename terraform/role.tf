###############################################################################
# ec2 role

resource "aws_iam_role" "ec2" {
  name = "${local.name}-ec2-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "EC2AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Service = "ec2"
  }
}

###############################################################################
# s3 read only

resource "aws_iam_role_policy_attachment" "ec2_s3_read" {
  role       = aws_iam_role.ec2.id
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}

###############################################################################
# cloudwatch agent

data "aws_iam_policy_document" "cloudwatch_agent" {
    statement {
      sid       = "PutMetrics"
      actions   = ["cloudwatch:PutMetricData"]
      resources = ["*"] # PutMetricData does not support resource-level permissions

    condition {
      test     = "StringEquals"
      variable = "cloudwatch:namespace"
      values   = ["CWAgent"]
    }
  }
}

resource "aws_iam_policy" "cloudwatch_agent" {
  name = "${local.name}-cloudwatch-agent"
  policy = aws_iam_policy_document.cloudwatch_agent.json
}

resource "aws_iam_role_policy_attachment" "ec2_cloudwatch_agent" {
  role       = aws_iam_role.ec2.id
  policy_arn = aws_iam_policy.cloudwatch_agent.arn
}
