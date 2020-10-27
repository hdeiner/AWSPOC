#!/usr/bin/env bash

figlet -w 160 -f small "Shutdown Oracle Locally"
docker-compose -f docker-compose.yml down
docker volume rm 07_oracle_local_oracle_data