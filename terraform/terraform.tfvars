# project
region            = "eu-central-1"
project           = "aws-iac-pipline"
environment       = "dev"
iac_provisioning  = "Terraform"
iac_configuration = "Ansible"
# network
vpc_cidr_block = "10.10.0.0/16"
public_subnets = ["10.10.0.0/19", "10.10.96.0/19"]
# s3
force_destroy_bucket = true
bucket_versioning    = "Disabled"
# postgres
postgres_version     = "16.3"
postgres_port        = "5432"