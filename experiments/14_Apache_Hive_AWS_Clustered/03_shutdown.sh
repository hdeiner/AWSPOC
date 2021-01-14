#!/usr/bin/env bash

figlet -w 200 -f small "Shutdown Hive AWS Cluster"
terraform destroy -auto-approve
