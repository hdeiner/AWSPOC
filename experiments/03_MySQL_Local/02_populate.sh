#!/usr/bin/env bash

figlet -w 160 -f small "Populate MySQL Locally"
docker exec mysql_container echo 'CREATE DATABASE testdatabase;' | mysql -h 127.0.0.1 -P 3306 -u root --password=password
liquibase update

figlet -w 160 -f small "Check Postgres Locally"
docker exec mysql_container echo 'select * from DERIVEDFACT;' | mysql -h 127.0.0.1 -P 3306 -u root --password=password testdatabase
docker exec mysql_container echo 'select * from MEMBERHEALTHSTATE;' | mysql -h 127.0.0.1 -P 3306 -u root --password=password testdatabase
