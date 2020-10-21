#!/usr/bin/env bash

figlet -w 200 -f small "Populate MySQL Clustered on AWS RDS Aurora"
echo `terraform output database_dns | grep -o '".*"' | cut -d '"' -f2` > .database_dns
echo `terraform output database_port | grep -Eo '[0-9]{1,}' | cut -d '"' -f2` > .database_port
echo `terraform output database_username | grep -o '".*"' | cut -d '"' -f2` > .database_username
echo `terraform output database_password | grep -o '".*"' | cut -d '"' -f2` > .database_password

echo "CREATE DATABASE testdatabase;" | mysql -h $(<.database_dns) -P $(<.database_port) -u $(<.database_username) --password=$(<.database_password)

echo 'changeLogFile: ../../src/db/changeset.xml' > liquibase.properties
echo 'url:  jdbc:mysql://'$(<.database_dns)':'$(<.database_port)'/testdatabase?autoReconnect=true&verifyServerCertificate=false&useSSL=false' >> liquibase.properties
echo 'username: '$(<.database_username) >> liquibase.properties
echo 'password: '$(<.database_password) >> liquibase.properties
echo 'driver:  org.gjt.mm.mysql.Driver' >> liquibase.properties
echo 'classpath:  ../../liquibase_drivers/mysql-connector-java-5.1.48.jar' >> liquibase.properties
liquibase update

figlet -w 200 -f small "Check MySQL Clustered on AWS RDS Aurora"
echo "select * from DERIVEDFACT;" | mysql -h $(<.database_dns) -P $(<.database_port) -u $(<.database_username) --password=$(<.database_password) testdatabase
echo "select * from MEMBERHEALTHSTATE;" | mysql -h $(<.database_dns) -P $(<.database_port) -u $(<.database_username) --password=$(<.database_password) testdatabase

rm .database_dns .database_port .database_username .database_password liquibase.properties