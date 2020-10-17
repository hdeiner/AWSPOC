#!/usr/bin/env bash

figlet -w 200 -f small "Startup PostgresSQL on AWS RDS Aurora"
terraform init
terraform apply -auto-approve

