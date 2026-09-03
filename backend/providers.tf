###############################################################################
# terraform configuration

terraform {
  required_version = "~> 1.15.8"

  backend "local" {
    path = "infrastructure/terraform.state"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.56"
    }
  }
}

###############################################################################
# provider configuration

provider "aws" {
  region                   = var.region
  profile                  = "default"
  shared_config_files      = ["/home/xl/.aws/config"]
  shared_credentials_files = ["/home/xl/.aws/credentials"]
  default_tags {
    tags = {
      Project     = var.project
      ProvisionBy = var.iac_provisioning
    }
  }
}
