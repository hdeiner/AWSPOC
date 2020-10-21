#!/usr/bin/env bash

figlet -w 160 -f small "Shutdown MySQL Locally"
docker-compose -f docker-compose.yml down
docker volume rm 03_mysql_local_mysql_data