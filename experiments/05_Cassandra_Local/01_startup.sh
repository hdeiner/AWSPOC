#!/usr/bin/env bash

figlet -w 160 -f small "Startup Cassandra Locally"
docker volume rm 01_Cassandra_local_cassandra_data
docker-compose -f docker-compose.yml up -d

figlet -w 160 -f small "Wait For Cassandra To Start"
while true ; do
  docker logs cassandra_container > stdout.txt 2> stderr.txt
  result=$(grep -c "CassandraRoleManager.java:372 - Created default superuser role 'cassandra'" stdout.txt)
  if [ $result = 1 ] ; then
    echo "Cassandra has started"
    break
  fi
  sleep 5
done
rm stdout.txt stderr.txt