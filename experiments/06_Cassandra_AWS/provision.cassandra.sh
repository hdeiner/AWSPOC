#!/usr/bin/env bash

bash -c 'cat << "EOF" > /tmp/.script
#!/usr/bin/env bash

sudo apt-get update -y -qq > provision.log
sudo apt-get install figlet -y -qq >> provision.log

figlet -w 160 -f small "Install Cassandra Prerequisites"
sudo apt update -y -qq >> provision.log
sudo apt install openjdk-8-jre-headless awscli gnupg gnupg2 -y -qq >> provision.log

echo "Install Cassandra"
echo "deb http://www.apache.org/dist/cassandra/debian 311x main" | sudo tee -a /etc/apt/sources.list.d/cassandra.sources.list
curl https://downloads.apache.org/cassandra/KEYS | sudo apt-key add - >> provision.log
sudo apt-get update -y -qq >> provision.log
sudo apt-get install cassandra -y -qq > provision.log

echo "Install Cassandra Tools"
sudo apt-get install cassandra-tools -y -qq >> provision.log

echo "Bring Cassandra Up"
sudo service cassandra stop >> provision.log
sudo rm -rf /var/lib/cassandra/* >> provision.log
sudo service cassandra start >> provision.log
sudo systemctl is-enabled cassandra.service >> provision.log

echo "Wait for Cassandra to start"
while true ; do
  result=$(grep -c "CassandraRoleManager.java:[0-9]* - Created default superuser role '"'"'cassandra'"'"'" /var/log/cassandra/system.log)
  if [ $result = 1 ] ; then
    echo "Cassandra has started"
    break
  fi
  sleep 5
done
sleep 10

echo "Enable Cassandra Thrift Clients"
nodetool enablethrift >> provision.log

echo "Verify That Cassandra Is Up"
cqlsh -e "SHOW VERSION"
nodetool status
EOF'
chmod +x /tmp/.script
command time -v /tmp/.script 2> /tmp/.results
aws ec2 describe-instances --region "us-east-1" --instance-id "`curl -s http://169.254.169.254/latest/meta-data/instance-id`" --query 'Reservations[].Instances[].[Tags[0].Value]' --output text > /tmp/.instanceName
sed --in-place --regexp-extended 's/ /_/g' /tmp/.instanceName
/tmp/getExperimentalResults.sh
experiment=$(/tmp/getExperimentNumber.sh)
/tmp/getDataAsCSVline.sh /tmp/.results ${experiment} "06_Cassandra_AWS: Install Prerequisites "$(</tmp/.instanceName) >> Experimental\ Results.csv
/tmp/putExperimentalResults.sh
rm /tmp/.script /tmp/.results