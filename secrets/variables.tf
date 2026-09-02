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

variable "region" {
  description = "Primary AWS region"
  type        = string
  default     = "eu-central-1"

  validation {
    condition     = var.region == "eu-central-1"
    error_message = "region must be 'eu-central-1'"
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

variable "environment" {
  description = "Environment name (dev, test, prod)"
  type        = string
  default     = "dev"
  validation {
    condition     = contains(["dev", "test", "prod"], var.environment)
    error_message = "Environment must be one of: dev, test, prod."
  }
}
