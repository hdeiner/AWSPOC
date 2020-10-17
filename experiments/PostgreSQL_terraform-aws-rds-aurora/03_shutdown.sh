#!/usr/bin/env bash

figlet -w 200 -f small "Shutdown PostgresSQL on AWS RDS Aurora"
terraform destroy -auto-approve