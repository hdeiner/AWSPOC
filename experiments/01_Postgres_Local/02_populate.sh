#!/usr/bin/env bash

figlet -w 160 -f small "Populate Postgres Locally"
docker exec postgres_container psql --port=5432 --username=postgres --no-password --no-align -c 'create database testdatabase;'
liquibase update

figlet -w 160 -f small "Check Postgres Locally"
docker exec postgres_container psql --port=5432 --username=postgres --no-password -d testdatabase --no-align -c 'select * from DERIVEDFACT;'
docker exec postgres_container psql --port=5432 --username=postgres --no-password -d testdatabase --no-align -c 'select * from MEMBERHEALTHSTATE;'