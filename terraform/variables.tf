###############################################################################
# module: root
###############################################################################
# project

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

variable "region" {
  description = "Primary AWS region"
  type        = string
  default     = "eu-central-1"

  validation {
    condition     = var.region == "eu-central-1"
    error_message = "region must be 'eu-central-1'"
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
# iam

variable "lambda_role_name" {
  description = "Name of the IAM role"
  type        = string
  default     = "lambda-role"
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
# ports

variable "postgres_port" {
  description = "Port for PostgreSQL"
  type        = number
  default     = 5432
}


variable "ssh_port" {
  description = "Port for SSH"
  type        = number
  default     = 22
}

###############################################################################
# secrets

variable "postgres_password" {
  type      = string
  sensitive = true
}
