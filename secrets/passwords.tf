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
