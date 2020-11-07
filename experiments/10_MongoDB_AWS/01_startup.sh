#!/usr/bin/env bash

figlet -w 200 -f small "Startup MongoDB AWS"
terraform init
terraform apply -auto-approve

