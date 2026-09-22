###############################################################################
# data

data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

data "aws_availability_zones" "available" {
  state = "available"
  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
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

data "aws_route53_zone" "root" {
  name         = var.domain_name
  private_zone = false
}

###############################################################################
# extern

data "external" "local_public_ip" {
  program = ["bash", "../scripts/myip.sh"]
}
