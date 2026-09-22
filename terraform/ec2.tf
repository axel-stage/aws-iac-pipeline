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

  lifecycle {
    prevent_destroy = false
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

  root_block_device {
    volume_size           = var.dbserver_instance_volume_size
    volume_type           = "gp3"
    delete_on_termination = true
  }

  lifecycle {
    prevent_destroy = false
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
    delete_on_termination = true
  }

  lifecycle {
    prevent_destroy = false
  }

  tags = {
    Name          = "${local.name}-appserver-instance"
    Type          = "appserver"
    Configuration = "Ansible"
  }
}