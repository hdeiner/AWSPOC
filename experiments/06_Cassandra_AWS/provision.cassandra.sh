#!/usr/bin/env bash

sleep 15

sudo apt-get update -y -qq > provision.log
sudo apt-get install figlet -y -qq >> provision.log

figlet -w 160 -f small "Install openjdk-8-jre-headless"
sudo apt update -y -qq >> provision.log
sudo apt install openjdk-8-jre-headless awscli gnupg gnupg2 -y -qq >> provision.log

figlet -w 160 -f small "Install Cassandra"
echo "deb http://www.apache.org/dist/cassandra/debian 311x main" | sudo tee -a /etc/apt/sources.list.d/cassandra.sources.list
curl https://downloads.apache.org/cassandra/KEYS | sudo apt-key add -
sudo apt-get update -y -qq >> provision.log
sudo apt-get install cassandra -y -qq >> provision.log

figlet -w 160 -f small "Install Cassandra Tools"
sudo apt-get install cassandra-tools -y -qq >> provision.log

figlet -w 160 -f small "Bring Cassandra Up"
sudo service cassandra stop
sudo rm -rf /var/lib/cassandra/*
sudo service cassandra start
sudo systemctl is-enabled cassandra.service

figlet -w 160 -f small "Wait for Cassandra to start"
while true ; do
  result=$(grep -c "CassandraRoleManager.java:[0-9]* - Created default superuser role 'cassandra'" /var/log/cassandra/system.log)
  if [ $result = 1 ] ; then
    echo "Cassandra has started"
    break
  fi
  sleep 5
done
sleep 10

figlet -w 160 -f small "Enable Cassandra Thrift Clients"
nodetool enablethrift

figlet -w 160 -f small "Verify That Cassandra Is Up"
cqlsh -e "SHOW VERSION"
nodetool status
