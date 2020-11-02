#!/usr/bin/env bash

figlet -w 200 -f small "Run Liquibase Locally Against Oracle AWS"
echo `terraform output database_dns | grep -o '".*"' | cut -d '"' -f2` > .database_dns
java -jar ../06_Cassandra_AWS/liquibase.jar --driver=oracle.jdbc.OracleDriver --url="jdbc:oracle:thin:@$(<.database_dns):1521:ORCL" --username=system --password=OraPasswd1 --classpath="ojdbc14.jar" --changeLogFile=../../src/db/changeset.oracle.xml --logLevel=debug update
rm .database_dns