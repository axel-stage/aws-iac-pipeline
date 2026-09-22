terraform {
  required_version = "~> 1.15"

  backend "s3" {
    # use values from backend/.env
    bucket = "aws-iac-pipeline-terraform-backend"
    key    = "infrastructure/terraform.tfstate"
    region = "eu-central-1"

    use_lockfile = true
    encrypt      = true
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
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = var.project_name
      Environment = var.environment
      ProvisionBy = var.iac_provisioning
    }
  }
}
