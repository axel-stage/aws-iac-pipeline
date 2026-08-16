###############################################################################
# iam

data "aws_iam_policy_document" "github_trust" {
  statement {
    effect = "Allow"

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github_actions.arn]
    }

    actions = ["sts:AssumeRoleWithWebIdentity"]

    # Verify the audience
    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    # Restrict to specific repository and branch
    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = [
        "repo:*",
      ]
    }
  }
}

resource "aws_iam_role" "github_actions" {
  name = "${var.project}-${var.environment}-github-actions-role"
  assume_role_policy = data.aws_iam_policy_document.github_trust.json

  tags = {
    Description = "GitHub Actions deployment role"
  }
}

# Attach necessary policies
resource "aws_iam_role_policy_attachment" "github_iam_read" {
  policy_arn = "arn:aws:iam::aws:policy/IAMReadOnlyAccess"
  role       = aws_iam_role.github_actions.name
}

resource "aws_iam_role_policy_attachment" "github_s3" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
  role       = aws_iam_role.github_actions.name
}

resource "aws_iam_role_policy_attachment" "github_ec2" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
  role       = aws_iam_role.github_actions.name
}

# Custom policy for additional permissions
resource "aws_iam_role_policy" "github_sts" {
  name = "github-actions-additional"
  role = aws_iam_role.github_actions.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
            "sts:AssumeRoleWithWebIdentity"
#           "iam:CreateRole",
#           "iam:DeleteRole",
#           "iam:AttachRolePolicy",
#           "iam:DetachRolePolicy",
#           "iam:PutRolePolicy",
#           "iam:DeleteRolePolicy",
#           "iam:GetRole",
#           "iam:GetRolePolicy",
#           "iam:ListRolePolicies",
#           "iam:ListAttachedRolePolicies",
#           "iam:UpdateAssumeRolePolicy",
#           "iam:PassRole",
#           "iam:TagRole",
#           "iam:UntagRole",
#           "iam:ListInstanceProfilesForRole",
        ]
        Resource = "*"
      }
    ]
  })
}
