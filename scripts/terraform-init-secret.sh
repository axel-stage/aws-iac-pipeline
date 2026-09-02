#!/bin/bash
# Generates secrets and stores them in AWS secret manager
# Pricing:
# - $0.40 per secret per month
# - $0.05 per 10,000 API calls
# Run this once per AWS account!!!

set -e

cd secrets && pwd

terraform init
terraform workspace select default
terraform fmt
terraform validate
terraform plan --out tfplan
terraform apply tfplan

rm tfplan

cd ..

# clean
#######
# rm -r .terraform/
# rm -r infrastructure/
# rm .terraform.lock.hcl
