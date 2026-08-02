###############################################################################
# ec2

resource "aws_iam_instance_profile" "dbserver" {
  name = "${var.project}-${var.environment}-dbserver-profile"
  role = aws_iam_role.ec2.id
}

resource "aws_instance" "dbserver" {
  ami                         = data.aws_ami.ubuntu_noble_2404.id
  subnet_id                   = aws_subnet.public_az_a.id
  vpc_security_group_ids      = [aws_security_group.dbserver.id]
  iam_instance_profile        = aws_iam_instance_profile.dbserver.id
  key_name                    = aws_key_pair.ansible.key_name
  instance_type               = var.ec2_instance_type
  associate_public_ip_address = true
  monitoring                  = true

  root_block_device {
    volume_size           = var.ec2_instance_volume_size
    volume_type           = "gp3"
    delete_on_termination = true
  }

  lifecycle {
    prevent_destroy = false
  }

  tags = {
    Name          = "${var.project}-${var.environment}-dbserver-instance"
    Type          = "dbserver"
    Configuration = "Ansible"
  }
}
