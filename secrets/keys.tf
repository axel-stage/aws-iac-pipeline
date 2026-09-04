##############################################################################
# ssh key

resource "tls_private_key" "ansible_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "ansible" {
  key_name   = "${var.project}-${var.environment}-ansible-key"
  public_key = tls_private_key.ansible_key.public_key_openssh
}

##############################################################################
# fernet key

data "external" "fernet_key" {
  program = [
    "python3",
    "-c",
    <<-PYTHON
      import json
      from cryptography.fernet import Fernet
      fernet_key = Fernet.generate_key()
      output = json.dumps({"fernet_key": fernet_key.decode()})
      print(output)
    PYTHON
  ]
}

##############################################################################
# jwt key

data "external" "jwt_key" {
  program = [
    "python3",
    "-c",
    <<-PYTHON
      import json, secrets
      jwt_token = secrets.token_hex(32)
      output = json.dumps({"jwt_token": jwt_token})
      print(output)
    PYTHON
  ]
}