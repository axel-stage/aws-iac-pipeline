###############################################################################
# aws

data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

data "aws_ami" "ubuntu_noble_2404" {
  most_recent = true
  owners      = ["amazon"] # ["099720109477"]
  name_regex  = "ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04"

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}


# data "aws_ssm_parameter" "db_password" {
#   name = "/rds/dev/rds_password"
#   with_decryption = true
# }

###############################################################################
# extern

data "external" "local_public_ip" {
  program = ["bash", "../scripts/myip.sh"]
}
