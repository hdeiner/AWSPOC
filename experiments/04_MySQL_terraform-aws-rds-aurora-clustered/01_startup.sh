#!/usr/bin/env bash

figlet -w 200 -f small "Startup MySQL Clustered on AWS RDS Aurora"
terraform init
terraform apply -auto-approve

