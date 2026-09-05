###############################################################################
# output

output "ansible_key_name" {
  value = aws_key_pair.ansible.key_name
}