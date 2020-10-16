#!/usr/bin/env bash

figlet -w 160 -f small "Startup PostgresSQL on AWS RDS Aurora"
docker init
terraform apply -auto-approve