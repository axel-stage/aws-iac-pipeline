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

variable "iac_provisioning" {
  description = "Infrastructure provisioning tool (Terraform, OpenTofu)"
  type        = string
  default     = "Terraform"
  validation {
    condition     = contains(["Terraform", "OpenTofu"], var.iac_provisioning)
    error_message = "IaC tool must be one of: Terraform, OpenTofu."
  }
}

variable "project" {
  description = "The Project name"
  type        = string
}

variable "github_repository_name" {
  description = "GitHub repository name"
  type        = string
}

###############################################################################
# secrets

variable "github_owner_login" {
  type      = string
  sensitive = true
}

variable "github_owner_id" {
  type      = string
  sensitive = true
}

variable "github_repository_id" {
  type      = string
  sensitive = true
}
