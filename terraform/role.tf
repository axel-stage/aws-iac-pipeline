###############################################################################
# ec2 role

resource "aws_iam_role" "dbserver" {
  name = "${var.project}-${var.environment}-dbserver-role"
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

resource "aws_iam_role_policy_attachment" "s3_read" {
  role       = aws_iam_role.dbserver.id
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}
