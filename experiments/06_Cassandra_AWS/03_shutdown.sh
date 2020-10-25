#!/usr/bin/env bash

figlet -w 200 -f small "Shutdown Cassandra on AWS"
terraform destroy -auto-approve