###############################################################################
# ssh key

resource "tls_private_key" "ansible" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "ansible" {
  key_name   = "${var.project}-${var.environment}-ansible-key"
  public_key = tls_private_key.ansible.public_key_openssh
}

resource "local_sensitive_file" "private_key" {
  content         = tls_private_key.ansible.private_key_pem
  filename        = "../${path.module}/ansible/keys/ansible-key.pem"
  file_permission = "0600"
}

###############################################################################
# ec2

resource "aws_iam_instance_profile" "ubuntu" {
  name = "${var.project}-${var.environment}-ubuntu-profile"
  role = aws_iam_role.ubuntu.id
}

resource "aws_instance" "ubuntu" {
  ami                         = data.aws_ami.ubuntu.id
  subnet_id                   = aws_subnet.public_az_a.id
  security_groups             = [aws_security_group.ubuntu.id]
  iam_instance_profile        = aws_iam_instance_profile.ubuntu.id
  key_name                    = aws_key_pair.ansible.key_name
  instance_type               = "t3.medium"
  associate_public_ip_address = true
  monitoring                  = true

  root_block_device {
    volume_size           = 16
    volume_type           = "gp3"
    delete_on_termination = true
  }

  tags = {
    Name = "${var.project}-${var.environment}-ubuntu-instance"
    Role = "db-server"
    Configuration = "Ansible"
  }
}
