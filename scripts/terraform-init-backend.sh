#!/bin/bash
# Initialize terraform S3 backend to store and share terraform state
# Creates a S3 bucket and DynamoDB table to store the Terraform state
# Run this once per AWS account!!!

set -e

cd backend && pwd

terraform init
terraform workspace select default
terraform fmt
terraform validate
terraform apply --auto-approve
terraform output > .env

cd ..

# clean
#######
# rm .terraform.lock.hcl terraform.tfstate.backup terraform.tfstate
# rm .env.github
# rm -r .terraform