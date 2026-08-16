terraform {
  required_version = ">=1.9"

  backend "s3" {
    # use values from backend/.env
    bucket  = "aws-iac-pipline-global-terraform-backend"
    key     = "infrastructure/terraform.tfstate"
    region  = "eu-central-1"

    use_logfile = true
    encrypt = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.56"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.9"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.9"
    }
    external = {
      source  = "hashicorp/external"
      version = "~> 2.4"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.3"
    }
  }
}

provider "aws" {
  region                   = var.region
  profile                  = "default"
  shared_config_files      = ["/home/xl/.aws/config"]
  shared_credentials_files = ["/home/xl/.aws/credentials"]
  default_tags {
    tags = {
      Project     = var.project
      Environment = var.environment
      ProvisionBy = var.iac_provisioning
    }
  }
}
