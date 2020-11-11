#!/usr/bin/env bash

figlet -w 200 -f small "Startup Ignite AWS Cluster"
terraform init
terraform apply -auto-approve

