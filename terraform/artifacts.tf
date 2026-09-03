###############################################################################
# artifacts

resource "local_file" "artifact_hosts" {
  content = yamlencode({
    all = {
      vars = {
        ansible_connection         = "smart"
        ansible_port               = var.ansible_port
        ansible_user               = var.ansible_user
        ansible_shell_type         = "sh"
        ansible_python_interpreter = "/usr/bin/python3"
        #ansible_ssh_private_key_file = "${path.module}/../ansible/keys/ansible-key.pem"
        ansible_ssh_private_key_file = "ansible/keys/ansible-key.pem"
        ansible_ssh_common_args      = "-o StrictHostKeyChecking=no"
      }
      children = {
        dbserver = {
          hosts = {
            (aws_instance.dbserver.tags.Name) = {
              ansible_host = aws_instance.dbserver.public_ip
              instance_id  = aws_instance.dbserver.id
              public_ip    = aws_instance.dbserver.public_ip
              private_ip   = aws_instance.dbserver.private_ip
              az           = aws_instance.dbserver.availability_zone
            }
          }
          # vars = {
          #   DB_PORT      = var.postgresql_port
          #   DB_ROOT_NAME = var.db_root_name
          #   DB_ROOT_ROLE = var.db_root_role
          #   DB_ROOT_PASS = random_password.root.result
          # }
        }
        appserver = {
          hosts = {
            (aws_instance.appserver.tags.Name) = {
              ansible_host = aws_instance.appserver.public_ip
              instance_id  = aws_instance.appserver.id
              public_ip    = aws_instance.appserver.public_ip
              private_ip   = aws_instance.appserver.private_ip
              az           = aws_instance.appserver.availability_zone
            }
          }
          # vars = {
          #   DB_HOST_PRIVATE = aws_instance.dbserver.private_ip
          #   DB_PORT         = var.postgresql_port
          #   META_DB_NAME    = var.meta_db_name
          #   META_DB_ROLE    = var.meta_db_role
          #   META_DB_PASS    = random_password.airflow_meta_db.result
          #   FERNET_KEY      = var.fernet_key
          #   JWT_SECRET      = var.jwt_secret
          # }
        }
      }
    }
  })
  #filename = "${path.module}/../ansible/inventory/hosts.yml"
  filename = "${path.module}/artifacts/hosts.yml"
}

resource "local_file" "artifact_terraform" {
  content = <<-YAML
    terraform:
      region: ${var.region}
      project: ${var.project}
      environment: ${var.environment}
      bucket_name: ${aws_s3_bucket.this.bucket}
      iac_provisioning: ${var.iac_provisioning}
      iac_configuration: ${var.iac_configuration}
    YAML
  #filename = "${path.module}/../ansible/group_vars/terraform_vars.yml"
  filename = "${path.module}/artifacts/terraform_vars.yml"
}


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

resource "local_sensitive_file" "artifact_private_key" {
  content  = tls_private_key.ansible.private_key_pem
  filename = "${path.module}/artifacts/ansible-key.pem"
  # filename        = "../${path.module}/ansible/keys/ansible-key.pem"
  file_permission = "0600"
}

# resource "local_file" "artifact_psql" {
#   content  = <<EOF
# # server
# DB_HOST_PUBLIC=${aws_instance.dbserver.public_ip}
# DB_HOST_PRIVATE=${aws_instance.dbserver.private_ip}
# DB_PORT=${var.postgresql_port}
# DB_NAME=sandbox
# DB_SCHEMA=dev
# # root
# DB_ROOT_NAME=${var.db_root_name}
# DB_ROOT_ROLE=${var.db_root_role}
# DB_ROOT_PASS='${random_password.root.result}'
# # admin
# DB_ADMIN_ROLE=dbadmin
# DB_ADMIN_PASS='${random_password.admin.result}'
# DB_ADMIN_CONN_LIMIT=50
# # reader
# DB_READ_ROLE=dbreader
# DB_READ_PASS='${random_password.reader.result}'
# DB_READ_CONN_LIMIT=20
# # airflow meta db
# META_DB_NAME=${var.meta_db_name}
# META_DB_ROLE=${var.meta_db_role}
# META_DB_PASS='${random_password.airflow_meta_db.result}'
# META_DB_CONN_LIMIT=${var.meta_db_conn_limit}
# EOF
#   #filename = "${path.module}/../.env.psql"
#   filename = "${path.module}/artifacts/.env.psql"
# }