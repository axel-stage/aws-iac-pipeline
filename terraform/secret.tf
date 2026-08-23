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

resource "local_file" "psql" {
  content  = <<EOF
# server
DB_HOST_PUBLIC=${aws_instance.dbserver.public_ip}
DB_HOST_PRIVATE=${aws_instance.dbserver.private_ip}
DB_PORT=${var.postgresql_port}
DB_NAME=sandbox
DB_SCHEMA=dev
# root
DB_ROOT_NAME=${var.db_root_name}
DB_ROOT_ROLE=${var.db_root_role}
DB_ROOT_PASS='${random_password.root.result}'
# admin
DB_ADMIN_ROLE=dbadmin
DB_ADMIN_PASS='${random_password.admin.result}'
DB_ADMIN_CONN_LIMIT=50
# reader
DB_READ_ROLE=dbreader
DB_READ_PASS='${random_password.reader.result}'
DB_READ_CONN_LIMIT=20
# airflow meta db
META_DB_NAME=${var.meta_db_name}
META_DB_ROLE=${var.meta_db_role}
META_DB_PASS='${random_password.airflow_meta_db.result}'
META_DB_CONN_LIMIT=${var.meta_db_conn_limit}
EOF
  filename = "${path.module}/../.env.psql"
}