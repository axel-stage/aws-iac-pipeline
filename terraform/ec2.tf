###############################################################################
# ec2

resource "aws_iam_instance_profile" "bastion" {
  name = "${local.name}-bastion-profile"
  role = aws_iam_role.ec2.id
}

resource "aws_instance" "bastion" {
  ami                         = data.aws_ami.ubuntu_noble_2404.id
  subnet_id                   = aws_subnet.public_az_a.id
  vpc_security_group_ids      = [aws_security_group.bastion.id]
  iam_instance_profile        = aws_iam_instance_profile.bastion.id
  key_name                    = var.key_name
  instance_type               = "t3.micro"
  associate_public_ip_address = false
  monitoring                  = false

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  lifecycle {
    prevent_destroy = false
    ignore_changes  = [ami]
  }

  tags = {
    Name = "${local.name}-bastion-host"
    Type = "jumpbox"
  }
}

resource "aws_iam_instance_profile" "dbserver" {
  name = "${local.name}-dbserver-profile"
  role = aws_iam_role.ec2.id
}

resource "aws_instance" "dbserver" {
  ami                         = data.aws_ami.ubuntu_noble_2404.id
  subnet_id                   = aws_subnet.private_az_a.id
  vpc_security_group_ids      = [aws_security_group.dbserver.id]
  iam_instance_profile        = aws_iam_instance_profile.dbserver.id
  key_name                    = var.key_name
  instance_type               = var.dbserver_instance_type
  associate_public_ip_address = false
  monitoring                  = true
  disable_api_termination     = var.dbserver_termination_protection

  # IMDSv2 is AWS’s hardened Instance Metadata Service for EC2
  # that requires a session token before you can read instance metadata.
  # It helps reduce abuse of metadata access (for example, SSRF-style attacks)
  # by making the metadata retrieval flow stateful instead of simple unauthenticated requests.
  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  root_block_device {
    volume_size           = var.dbserver_instance_volume_size
    volume_type           = "gp3"
    delete_on_termination = local.delete_on_termination
    encrypted             = true
    kms_key_id            = aws_kms_key.this.arn
  }

  lifecycle {
    prevent_destroy = false
    ignore_changes  = [ami]
  }

  tags = {
    Name          = "${local.name}-dbserver-instance"
    Type          = "dbserver"
    Configuration = "Ansible"
  }
}

resource "aws_iam_instance_profile" "appserver" {
  name = "${local.name}-appserver-profile"
  role = aws_iam_role.ec2.id
}

resource "aws_instance" "appserver" {
  ami                         = data.aws_ami.ubuntu_noble_2404.id
  subnet_id                   = aws_subnet.private_az_a.id
  vpc_security_group_ids      = [aws_security_group.appserver.id]
  iam_instance_profile        = aws_iam_instance_profile.appserver.id
  key_name                    = var.key_name
  instance_type               = var.appserver_instance_type
  associate_public_ip_address = false
  monitoring                  = true

  root_block_device {
    volume_size           = var.appserver_instance_volume_size
    volume_type           = "gp3"
    delete_on_termination = local.delete_on_termination
    encrypted             = true
    kms_key_id            = aws_kms_key.this.arn
  }

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  lifecycle {
    prevent_destroy = false
    ignore_changes  = [ami]
  }

  tags = {
    Name          = "${local.name}-appserver-instance"
    Type          = "appserver"
    Configuration = "Ansible"
  }
}
