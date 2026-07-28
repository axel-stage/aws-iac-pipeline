###############################################################################
# ansible

resource "local_file" "ansible_inventory_yaml" {
  content = yamlencode({
    all = {
      vars = {
        region                       = var.region
        project                      = var.project
        environment                  = var.environment
        ansible_user                 = "ubuntu"
        ansible_python_interpreter   = "/usr/bin/python3"
        ansible_ssh_private_key_file = "${path.module}/../ansible/keys/ansible-key.pem"
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
          vars = {
            postgresql_version = var.postgres_version
            postgres_port     = var.postgres_port
          }
        }
      }
    }
  })
  filename = "${path.module}/../ansible/inventories/hosts.yml"
}

# resource "local_file" "ansible_vars" {
#   content = yamlencode({
#     environment = var.environment
#     db_host     = aws_instance.dbserver.public_ip
#   })
#   filename = "${path.module}/../ansible/group_vars/all.yml"
# }