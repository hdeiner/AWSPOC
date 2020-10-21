#!/usr/bin/env bash

figlet -w 200 -f small "Startup PostgresSQL Clustered on AWS RDS Aurora"
terraform init
terraform apply -auto-approve

