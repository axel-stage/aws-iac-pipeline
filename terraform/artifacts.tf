###############################################################################
# artifacts

resource "local_file" "artifact_hosts" {
  content = yamlencode({
    all = {
      vars = {
        ansible_connection           = "smart"
        ansible_port                 = var.ansible_port
        ansible_user                 = var.ansible_user
        ansible_shell_type           = "sh"
        ansible_python_interpreter   = "/usr/bin/python3"
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
        }
      }
    }
  })
  filename = "${path.module}/artifacts/hosts.yml"
}

resource "local_file" "artifact_terraform" {
  content  = <<-YAML
    terraform:
      region: ${var.region}
      project: ${var.project}
      environment: ${var.environment}
      bucket_name: ${aws_s3_bucket.this.bucket}
      iac_provisioning: ${var.iac_provisioning}
      iac_configuration: ${var.iac_configuration}
    YAML
  filename = "${path.module}/artifacts/terraform_vars.yml"
}
