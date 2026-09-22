###############################################################################
# security groups

resource "aws_default_security_group" "default" {
  vpc_id = aws_vpc.this.id

  ingress {
    description = "Allow all internal TCP and UDP"
    self        = true
    protocol    = -1
    from_port   = 0
    to_port     = 0
  }

  egress {
    description = "Allow all external TCP and UDP"
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${local.name}-sg-default"
  }
}

resource "aws_security_group" "dbserver" {
  name        = "${local.name}-sg-dbserver"
  description = "Security group for dbserver instance"
  vpc_id      = aws_vpc.this.id

  ingress {
    description     = "Allow PostgreSQL from app server"
    protocol        = "tcp"
    from_port       = var.postgresql_port
    to_port         = var.postgresql_port
    security_groups = [aws_security_group.appserver.id]
    self            = true
    #cidr_blocks = ["${var.vpc_cidr_block}"]
  }

  ingress {
    description     = "Allow SSH from Bastion Host"
    protocol        = "tcp"
    from_port       = var.ansible_port
    to_port         = var.ansible_port
    security_groups = [aws_security_group.bastion.id]
  }

  ingress {
    description     = "Allow all ICMP (ping, traceroute, ...) from Bastion Host"
    from_port       = -1
    to_port         = -1
    protocol        = "icmp"
    security_groups = [aws_security_group.bastion.id]
  }

  # ingress {
  #   description = "Allow PostgreSQL from NLB"
  #   protocol    = "tcp"
  #   from_port   = var.postgresql_port
  #   to_port     = var.postgresql_port
  #   security_groups = [ aws_security_group.nlb ]
  # }

  # ingress {
  #   description = "Allow PostgreSQL from my IP"
  #   from_port   = var.postgresql_port
  #   to_port     = var.postgresql_port
  #   protocol    = "tcp"
  #   cidr_blocks = ["0.0.0.0/0", "${data.external.local_public_ip.result.ipv4}/32"]
  # }

  # ingress {
  #   description = "Allow SSH from my IP"
  #   from_port   = 22
  #   to_port     = 22
  #   protocol    = "tcp"
  #   cidr_blocks = ["0.0.0.0/0", "${data.external.local_public_ip.result.ipv4}/32"]
  # }

  # ingress {
  #   description = "Allow all ICMP (ping, traceroute, ...) from my IP"
  #   from_port   = -1
  #   to_port     = -1
  #   protocol    = "icmp"
  #   cidr_blocks = ["0.0.0.0/0", "${data.external.local_public_ip.result.ipv4}/32"]
  # }

  egress {
    description = "Allow all external TCP and UDP"
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${local.name}-sg-dbserver"
  }
}

resource "aws_security_group" "appserver" {
  name        = "${local.name}-sg-appserver"
  description = "Security group for appserver instance"
  vpc_id      = aws_vpc.this.id

  ingress {
    description     = "Allow airflow api server from NLB"
    protocol        = "tcp"
    from_port       = 8080
    to_port         = 8080
    security_groups = [aws_security_group.nlb.id]
  }

  ingress {
    description     = "Allow SSH from Bastion Host"
    protocol        = "tcp"
    from_port       = var.ansible_port
    to_port         = var.ansible_port
    security_groups = [aws_security_group.bastion.id]
  }

  ingress {
    description     = "Allow all ICMP (ping, traceroute, ...) from Bastion Host"
    from_port       = -1
    to_port         = -1
    protocol        = "icmp"
    security_groups = [aws_security_group.bastion.id]
  }

  # ingress {
  #   description = "Allow SSH from my IP"
  #   from_port   = 22
  #   to_port     = 22
  #   protocol    = "tcp"
  #   cidr_blocks = ["0.0.0.0/0", "${data.external.local_public_ip.result.ipv4}/32"]
  # }

  # ingress {
  #   description = "Allow all ICMP (ping, traceroute, ...) from my IP"
  #   from_port   = -1
  #   to_port     = -1
  #   protocol    = "icmp"
  #   cidr_blocks = ["0.0.0.0/0", "${data.external.local_public_ip.result.ipv4}/32"]
  # }

  egress {
    description = "Allow all external TCP and UDP"
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${local.name}-sg-appserver"
  }
}

resource "aws_security_group" "bastion" {
  name        = "${local.name}-sg-bastion"
  description = "Security group for bastion host"
  vpc_id      = aws_vpc.this.id

  ingress {
    description = "Allow SSH from All"
    protocol    = "tcp"
    from_port   = var.ansible_port
    to_port     = var.ansible_port
    cidr_blocks = ["0.0.0.0/0"]
    #security_groups = [aws_security_group.nlb.id]
    #cidr_blocks = ["${data.external.local_public_ip.result.ipv4}/32"]
  }

  egress {
    description = "Allow all external TCP and UDP"
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${local.name}-sg-bastion"
  }
}

resource "aws_security_group" "nlb" {
  name        = "${local.name}-sg-nlb"
  description = "Security group for the Network Load Balancer"
  vpc_id      = aws_vpc.this.id

  # ingress {
  #   description = "Allow SSH from my IP"
  #   protocol    = "tcp"
  #   from_port   = 22
  #   to_port     = 22
  #   cidr_blocks = ["0.0.0.0/0"]
  # }

  ingress {
    description = "Allow airflow api server from my IP"
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow airflow api server from my IP"
    protocol    = "tcp"
    from_port   = 443
    to_port     = 443
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all external TCP and UDP"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${local.name}-sg-nlb"
  }
}

###############################################################################
# bucket policies

resource "aws_s3_bucket_policy" "secure" {
  bucket = aws_s3_bucket.this.id
  policy = data.aws_iam_policy_document.enforce_ssl.json
}

data "aws_iam_policy_document" "enforce_ssl" {
  # Deny any request not using SSL
  statement {
    sid    = "EnforceSSLOnly"
    effect = "Deny"

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    actions = ["s3:*"]

    resources = [
      aws_s3_bucket.this.arn,
      "${aws_s3_bucket.this.arn}/*",
    ]

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }

    condition {
      test     = "Bool"
      variable = "aws:PrincipalIsAWSService"
      values   = ["false"]
    }
  }

  # Deny TLS versions below 1.2
  statement {
    sid    = "EnforceTLS12"
    effect = "Deny"

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    actions = ["s3:*"]

    resources = [
      aws_s3_bucket.this.arn,
      "${aws_s3_bucket.this.arn}/*",
    ]

    condition {
      test     = "NumericLessThan"
      variable = "s3:TlsVersion"
      values   = ["1.2"]
    }

    condition {
      test     = "Bool"
      variable = "aws:PrincipalIsAWSService"
      values   = ["false"]
    }
  }
}