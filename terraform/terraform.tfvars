# project
region            = "eu-central-1"
project           = "aws-iac-pipline"
environment       = "dev"
iac_provisioning  = "Terraform"
iac_configuration = "Ansible"
# network
vpc_cidr_block = "10.10.0.0/16"
public_subnets = ["10.10.0.0/19", "10.10.96.0/19"]
# ec2
dbserver_instance_type         = "t3.medium"
dbserver_instance_volume_size  = 16
appserver_instance_type        = "t3.medium"
appserver_instance_volume_size = 8
# s3
force_destroy_bucket = true
bucket_versioning    = "Disabled"
# postgres
postgresql_port = "5432"
meta_db_name = "airflow_meta_db"
meta_db_role = "dbairflow"
meta_db_conn_limit = 50
# airflow
fernet_key = "s2jQh6OXf3r7f5Ulf-CRTk7AKZpTGFh0E8zpvXuhdUg="
jwt_secret = "5Sd/ACLwIt7cXtJ+PrWn2w/8"
# ansible
ansible_port = "22"
ansible_user = "ubuntu"