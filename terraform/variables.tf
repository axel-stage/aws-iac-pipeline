###############################################################################
# module: root
###############################################################################
# project

variable "region" {
  description = "Primary AWS region"
  type        = string
  default     = "eu-central-1"

  validation {
    condition     = var.region == "eu-central-1"
    error_message = "region must be 'eu-central-1'"
  }
}

variable "project" {
  description = "The Project name"
  type        = string
  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.project))
    error_message = "Project name must contain only lowercase letters, numbers, and hyphens."
  }
}

variable "environment" {
  description = "Environment name (dev, test, prod)"
  type        = string
  default     = "dev"
  validation {
    condition     = contains(["dev", "test", "prod"], var.environment)
    error_message = "Environment must be one of: dev, test, prod."
  }
}

variable "iac_provisioning" {
  description = "Infrastructure provisioning tool (Terraform, OpenTofu)"
  type        = string
  default     = "Terraform"
  validation {
    condition     = contains(["Terraform", "OpenTofu"], var.iac_provisioning)
    error_message = "IaC tool must be one of: Terraform, OpenTofu."
  }
}

variable "iac_configuration" {
  description = "Infrastructure configuration tool (Ansible)"
  type        = string
  default     = "Ansible"
  validation {
    condition     = var.iac_configuration == "Ansible"
    error_message = "IaC tool must be: Ansible."
  }
}

###############################################################################
# vpc

variable "vpc_cidr_block" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnets" {
  description = "AWS VPC public subnets"
  type        = list(string)
}

###############################################################################
# s3

variable "force_destroy_bucket" {
  description = "forcing to destroy a bucket"
  type        = bool
  default     = false
}

variable "bucket_versioning" {
  description = "Enable bucket versioning"
  type        = string
  default     = "Disabled"
  validation {
    condition     = contains(["Enabled", "Suspended", "Disabled"], var.bucket_versioning)
    error_message = "Bucket versioning must be one of: Enabled, Suspended, Disabled."
  }
}

###############################################################################
# postgres

variable "postgres_version" {
  description = "PostgreSQL DMBS version"
  type        = string
  default     = "16.3"
}

variable "postgres_port" {
  description = "Port for PostgreSQL"
  type        = string
  default     = "5432"
}

###############################################################################
# secrets

# variable "secret" {
#   type      = string
#   sensitive = true
# }
