project     = "aws-iac-pipline"
environment = "dev"
region      = "eu-central-1"

vpc_cidr_block = "10.10.0.0/16"
public_subnets = ["10.10.0.0/19", "10.10.96.0/19"]


force_destroy_bucket = true
bucket_versioning = "Disabled"

postgres_password = "secret"
postgres_port = 5432


ssh_port = 22