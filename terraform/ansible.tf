
resource "local_file" "ansible_inventory_yaml" {
  content = yamlencode({
    all = {
      vars = {
        ansible_user                 = "ubuntu"
        ansible_python_interpreter   = "/usr/bin/python3"
        ansible_ssh_private_key_file = "~/projects/aws_iac_pipeline/ansible/keys/ansible-key.pem"
        ansible_ssh_common_args      = "-o StrictHostKeyChecking=no"
      }
      children = {
        # webservers = {
        #   hosts = {
        #     for idx, instance in aws_instance.web : instance.tags.Name => {
        #       ansible_host = instance.public_ip
        #       ansible_user = "ec2-user"
        #       instance_id  = instance.id
        #       private_ip   = instance.private_ip
        #       az           = instance.availability_zone
        #     }
        #   }
        #   vars = {
        #     nginx_port = 80
        #     app_env    = var.environment
        #   }
        # }
        db-servers = {
          hosts = {
            (aws_instance.ubuntu.tags.Name) = {
              ansible_host = aws_instance.ubuntu.public_ip
              instance_id  = aws_instance.ubuntu.id
              public_ip    = aws_instance.ubuntu.public_ip
              private_ip   = aws_instance.ubuntu.private_ip
              az           = aws_instance.ubuntu.availability_zone
            }
          }
          vars = {
            postgresql_version = "16"
          }
        }
      }
    }
  })
  filename = "../${path.module}/ansible/inventory/hosts.yml"
}

# Generate Ansible variables
resource "local_file" "ansible_vars" {
  content = yamlencode({
    environment          = var.environment
    db_host             = aws_instance.ubuntu.public_ip
  })
  filename = "../${path.module}/ansible/group_vars/all.yml"
}