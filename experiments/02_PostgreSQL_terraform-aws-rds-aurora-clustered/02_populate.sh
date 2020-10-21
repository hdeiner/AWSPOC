#!/usr/bin/env bash

figlet -w 160 -f small "Populate Postgres Clustered on AWS RDS Aurora"
echo `terraform output database_dns | grep -o '".*"' | cut -d '"' -f2` > .database_dns
echo `terraform output database_port | grep -Eo '[0-9]{1,}' | cut -d '"' -f2` > .database_port
echo `terraform output database_username | grep -o '".*"' | cut -d '"' -f2` > .database_username
echo `terraform output database_password | grep -o '".*"' | cut -d '"' -f2` > .database_password

PGPASSWORD=$(<.database_password) psql --host=$(<.database_dns) --port=$(<.database_port) --username=$(<.database_username) --no-password --no-align -c 'create database testdatabase;'

echo 'changeLogFile: ../../src/db/changeset.xml' > liquibase.properties
echo 'url:  jdbc:postgresql://'$(<.database_dns)':'$(<.database_port)'/testdatabase' >> liquibase.properties
echo 'username: '$(<.database_username) >> liquibase.properties
echo 'password: '$(<.database_password) >> liquibase.properties
echo 'driver:  org.postgresql.Driver' >> liquibase.properties
echo 'classpath:  ../../liquibase_drivers/postgresql-42.2.18.jre6.jar' >> liquibase.properties
liquibase update

figlet -w 160 -f small "Check Postgres Clusdered on AWS RDS Aurora"
PGPASSWORD=$(<.database_password) psql --host=$(<.database_dns) --port=$(<.database_port) --username=$(<.database_username) --no-password -d testdatabase --no-align -c 'select * from DERIVEDFACT;'
PGPASSWORD=$(<.database_password) psql --host=$(<.database_dns) --port=$(<.database_port) --username=$(<.database_username) --no-password -d testdatabase --no-align -c 'select * from MEMBERHEALTHSTATE;'

rm .database_dns .database_port .database_username .database_password liquibase.properties