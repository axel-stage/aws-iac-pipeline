###############################################################################
# ansible

resource "local_file" "ansible_inventory_yaml" {
  content = yamlencode({
    all = {
      vars = {
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
            postgresql_port = var.postgresql_port
            local_public_ip = data.external.local_public_ip.result.ipv4
          }
        }
      }
    }
  })
  filename = "${path.module}/../ansible/inventories/hosts.yml"
}

resource "local_file" "terraform_vars" {
  content = <<EOYAML
terraform:
  region: ${var.region}
  project: ${var.project}
  environment: ${var.environment}
  bucket_name: ${aws_s3_bucket.dbserver.bucket}
  iac_provisioning: ${var.iac_provisioning}
  iac_configuration: ${var.iac_configuration}
EOYAML
  filename = "${path.module}/../ansible/group_vars/terraform_vars.yml"
}