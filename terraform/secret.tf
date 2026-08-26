###############################################################################
# secret manager

# PostgreSQL - most characters allowed, max 128 chars

resource "random_password" "root" {
  length           = 50
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>?"
}

resource "random_password" "admin" {
  length           = 50
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>?"
}

resource "random_password" "reader" {
  length           = 50
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>?"
}

resource "random_password" "airflow_meta_db" {
  length  = 50
  special = false
  # override_special = "#*-_=+<>"
}
