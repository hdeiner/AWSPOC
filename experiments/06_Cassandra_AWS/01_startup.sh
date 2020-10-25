#!/usr/bin/env bash

figlet -w 200 -f small "Startup Cassandra on AWS"
terraform init
terraform apply -auto-approve

