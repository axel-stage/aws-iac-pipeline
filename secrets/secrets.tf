###############################################################################
# secret manager

resource "aws_secretsmanager_secret" "secret" {
  name = "${var.project}/${var.environment}/secret"
}

resource "aws_secretsmanager_secret_version" "secret" {
  secret_id = aws_secretsmanager_secret.secret.id
  secret_string = jsonencode({
    environment = var.environment
    jwt_token   = data.external.jwt_token.result.jwt_token
    fernet_key  = data.external.fernet_key.result.fernet_key
    postgres_root = {
      db_port       = 5432
      db_name       = "postgres"
      db_schema     = "dev"
      db_role       = "postgres"
      db_pass       = random_password.postgres_root.result
      db_conn_limit = 20
    }
    postgres_admin = {
      db_port       = 5432
      db_name       = "postgres"
      db_schema     = "dev"
      db_role       = "dbadmin"
      db_pass       = random_password.postgres_admin.result
      db_conn_limit = 20
    }
    postgres_reader = {
      db_port       = 5432
      db_name       = "postgres"
      db_schema     = "dev"
      db_role       = "dbreader"
      db_pass       = random_password.postgres_reader.result
      db_conn_limit = 100
    }
    airflow_meta = {
      db_port       = 5432
      db_name       = "airflow_meta_db"
      db_schema     = "public"
      db_role       = "dbairflow"
      db_pass       = random_password.airflow_meta.result
      db_conn_limit = 100
    }
  })
}
