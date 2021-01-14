#!/usr/bin/env bash

figlet -w 200 -f small "Startup Hive AWS Cluster"
terraform init
terraform apply -auto-approve


