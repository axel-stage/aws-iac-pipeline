###############################################################################
# iam

data "aws_iam_policy_document" "github_trust" {
  statement {
    effect = "Allow"

    principals {
      type = "Federated"

      identifiers = [
        aws_iam_openid_connect_provider.github_actions.arn
      ]
    }

    actions = [
      "sts:AssumeRoleWithWebIdentity"
    ]

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"

      values = [
        "sts.amazonaws.com"
      ]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:sub"

      values = [
        "repo:${var.github_owner_login}@${var.github_owner_id}/${var.github_repository_name}@${var.github_repository_id}:ref:refs/heads/main"
      ]
    }
  }
}

data "aws_iam_policy_document" "github_kms" {
  statement {
    sid = "ManageKeys"
    actions = [
      "kms:CreateKey",
      "kms:CreateAlias",
      "kms:DeleteAlias",
      "kms:UpdateAlias",
      "kms:ListAliases",
      "kms:DescribeKey",
      "kms:GetKeyPolicy",
      "kms:PutKeyPolicy",
      "kms:GetKeyRotationStatus",
      "kms:EnableKeyRotation",
      "kms:ListResourceTags",
      "kms:TagResource",
      "kms:UntagResource",
      "kms:ScheduleKeyDeletion",
    ]
    resources = ["*"]
  }

  statement {
    sid = "UseKeysForEbs"
    actions = [
      "kms:CreateGrant",
      "kms:GenerateDataKeyWithoutPlaintext",
      "kms:Decrypt",
      "kms:ReEncrypt*",
    ]
    resources = ["*"]

    condition {
      test     = "StringEquals"
      variable = "kms:ViaService"
      values   = ["ec2.${var.region}.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "github_actions" {
  name               = "${var.project}-github-actions-role"
  assume_role_policy = data.aws_iam_policy_document.github_trust.json

  tags = {
    Description = "GitHub Actions deployment role"
  }
}

resource "aws_iam_role_policy" "github_kms" {
  name   = "${var.project}-github-kms"
  role   = aws_iam_role.github_actions.id
  policy = data.aws_iam_policy_document.github_kms.json
}

resource "aws_iam_role_policy_attachment" "github_iam" {
  policy_arn = "arn:aws:iam::aws:policy/IAMFullAccess"
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

resource "aws_iam_role_policy_attachment" "github_cloudwatch" {
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchFullAccess"
  role       = aws_iam_role.github_actions.name
}

resource "aws_iam_role_policy_attachment" "github_secretsmanager" {
  policy_arn = "arn:aws:iam::aws:policy/SecretsManagerReadWrite"
  role       = aws_iam_role.github_actions.name
}

resource "aws_iam_role_policy_attachment" "github_route53" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonRoute53FullAccess"
  role       = aws_iam_role.github_actions.name
}

resource "aws_iam_role_policy_attachment" "github_acm" {
  policy_arn = "arn:aws:iam::aws:policy/AWSCertificateManagerFullAccess"
  role       = aws_iam_role.github_actions.name
}
