#!/bin/bash
# Deploy local dags to a Airflow server running on a VM

SECRET_NAME=aws-iac-pipeline/dev/ansible-private-key
AIRFLOW_HOST_PUBLIC_IP=63.185.78.219
AIRFLOW_USER=airflow

aws secretsmanager get-secret-value \
  --secret-id ${SECRET_NAME} \
  --query SecretString \
  --output text > ~/.ssh/airflow-key.pem

chmod 600 ~/.ssh/airflow-key.pem

ssh-keyscan -H "${AIRFLOW_HOST_PUBLIC_IP}" >> ~/.ssh/known_hosts

rsync --verbose --archive --partial --progress --compress \
  -e "ssh -i ~/.ssh/airflow_key" \
  dags/ ${AIRFLOW_USER}@${AIRFLOW_HOST_PUBLIC_IP}:/opt/airflow/dags/

rm ~/.ssh/airflow-key.pem