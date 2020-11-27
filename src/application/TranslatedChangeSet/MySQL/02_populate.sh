#!/usr/bin/env bash

figlet -w 160 -f small "Populate MySQL Locally"
docker exec mysql_container echo 'CREATE DATABASE CE;' | mysql -h 127.0.0.1 -P 3306 -u root --password=password
docker exec mysql_container echo 'CREATE SCHEMA IF NOT EXISTS CE;' | mysql -h 127.0.0.1 -P 3306 -u root --password=password
liquibase update

figlet -w 160 -f small "Check MySQL Locally"
docker exec mysql_container echo 'select * from CE.RECOMMENDATIONTEXT;' | mysql -h 127.0.0.1 -P 3306 -u root --password=password CE
