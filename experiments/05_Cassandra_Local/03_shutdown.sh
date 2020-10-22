#!/usr/bin/env bash

figlet -w 160 -f small "Shutdown Cassandra Locally"
docker-compose -f docker-compose.yml down
docker volume rm 01_cassandra_local_cassandra_data