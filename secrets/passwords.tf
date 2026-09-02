###############################################################################
# random passwords

# PostgreSQL - most characters allowed, max 128 chars

resource "random_password" "postgres_root" {
  length           = 50
  special          = true
  override_special = "!#%*()-_=+[]?"
}

resource "random_password" "postgres_admin" {
  length           = 50
  special          = true
  override_special = "!#%*()-_=+[]?"
}

resource "random_password" "postgres_reader" {
  length           = 50
  special          = true
  override_special = "!#%*()-_=+[]?"
}

resource "random_password" "airflow_meta" {
  length  = 50
  special = false
}

###############################################################################
# python passwords

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

data "external" "jwt_token" {
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