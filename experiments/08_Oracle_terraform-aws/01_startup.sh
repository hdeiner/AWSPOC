#!/usr/bin/env bash

figlet -w 200 -f small "Startup Oracle AWS"
terraform init
terraform apply -auto-approve

