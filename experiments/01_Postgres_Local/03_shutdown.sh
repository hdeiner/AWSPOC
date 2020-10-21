#!/usr/bin/env bash

figlet -w 160 -f small "Shutdown Postgres Locally"
docker-compose -f docker-compose.yml down
docker volume rm 01_postgres_local_postgres_data