#!/usr/bin/env bash

sudo apt update -y -qq > provision.log
sudo apt-get update -y -qq >> provision.log
sudo apt-get install -y -qq figlet >> provision.log

figlet -w 240 -f small "Install Prerequisites"
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends openjdk-8-jdk net-tools curl netcat gnupg libsnappy-dev awscli jq moreutils xmlstarlet libxml2-utils >> provision.log
sudo rm -rf /var/lib/apt/lists/*
export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64/

figlet -w 240 -f small "Configure ssh"
ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa
cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
chmod 755 ~/.ssh
chmod 600 ~/.ssh/id_rsa
chmod 755 ~/.ssh/id_rsa.pub
chmod 755 ~/.ssh/authorized_keys
echo "    StrictHostKeyChecking no" | sudo sponge -a /etc/ssh/ssh_config
sudo systemctl restart ssh.service
sudo systemctl restart ssh

export INSTANCE_DNS_NAME=$(curl http://169.254.169.254/latest/meta-data/public-hostname)
aws s3 cp ~/.ssh/id_rsa s3://hdfs-tmp/$INSTANCE_DNS_NAME.id_rsa
aws s3 cp ~/.ssh/id_rsa.pub s3://hdfs-tmp/$INSTANCE_DNS_NAME.id_rsa.pub

figlet -w 240 -f small "Set CLUSTER_NAME"
export INSTANCE_ID=$(curl http://169.254.169.254/latest/meta-data/instance-id)
export CLUSTER_NAME=$(aws ec2 describe-instances --region=us-east-1 --instance-id=$INSTANCE_ID --query 'Reservations[].Instances[].Tags[?Key==`Environment`].Value' --output text)

export HADOOP_VERSION=3.3.0
figlet -w 240 -f small "Install Hadoop $HADOOP_VERSION"
curl -sO https://dist.apache.org/repos/dist/release/hadoop/common/KEYS > /dev/null
gpg --quiet --import KEYS >> provision.log

export HADOOP_URL=https://www.apache.org/dist/hadoop/common/hadoop-$HADOOP_VERSION/hadoop-$HADOOP_VERSION.tar.gz
curl -sfSL "$HADOOP_URL" -o /tmp/hadoop.tar.gz > /dev/null
curl -sfSL "$HADOOP_URL.asc" -o /tmp/hadoop.tar.gz.asc > /dev/null
gpg --quiet --verify /tmp/hadoop.tar.gz.asc
sudo tar -xf /tmp/hadoop.tar.gz -C /opt/
rm /tmp/hadoop.tar.gz*

sudo ln -s /opt/hadoop-$HADOOP_VERSION/etc/hadoop /etc/hadoop
sudo mkdir /opt/hadoop-$HADOOP_VERSION/logs
sudo chmod 777 /opt/hadoop-$HADOOP_VERSION/logs
sudo mkdir /hadoop-data
sudo chmod 777 /hadoop-data
sudo mkdir /hadoop-tmp
sudo chmod 777 /hadoop-tmp

figlet -w 240 -f small "Configure Hadoop Core"

export HADOOP_HOME=/opt/hadoop-$HADOOP_VERSION
export HADOOP_CONF_DIR=/etc/hadoop
export MULTIHOMED_NETWORK=1
export USER=ubuntu
export PATH=$HADOOP_HOME/bin/:$HADOOP_HOME/sbin/:$PATH

export HDFS_NAMENODE_USER=ubuntu
export HDFS_DATANODE_USER=ubuntu
export HDFS_SECONDARYNAMENODE_USER=ubuntu
export YARN_RESOURCEMANAGER_USER=ubuntu
export YARN_NODEMANAGER_USER=ubuntu

echo "Fix bash_profile"
echo # Hadoop ENVIRONMENT VARIABLES | sudo sponge -a /home/ubuntu/.bash_profile
echo export CLUSTER_NAME=$CLUSTER_NAME | sudo sponge -a /home/ubuntu/.bash_profile
echo export INSTANCE_DNS_NAME=$INSTANCE_DNS_NAME | sudo sponge -a /home/ubuntu/.bash_profile
echo export INSTANCE_ID=$INSTANCE_ID | sudo sponge -a /home/ubuntu/.bash_profile
echo export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64/ | sudo sponge -a /home/ubuntu/.bash_profile
echo export HADOOP_VERSION=$HADOOP_VERSION | sudo sponge -a /home/ubuntu/.bash_profile
echo export HADOOP_HOME=$HADOOP_HOME | sudo sponge -a /home/ubuntu/.bash_profile
echo export HADOOP_CONF_DIR=$HADOOP_CONF_DIR | sudo sponge -a /home/ubuntu/.bash_profile
echo export MULTIHOMED_NETWORK=$MULTIHOMED_NETWORK | sudo sponge -a /home/ubuntu/.bash_profile
echo export USER=$USER | sudo sponge -a /home/ubuntu/.bash_profile
echo export PATH=$PATH | sudo sponge -a /home/ubuntu/.bash_profile
echo export HDFS_NAMENODE_USER=$HDFS_NAMENODE_USER | sudo sponge -a /home/ubuntu/.bash_profile
echo export HDFS_DATANODE_USER=$HDFS_DATANODE_USER | sudo sponge -a /home/ubuntu/.bash_profile
echo export HDFS_SECONDARYNAMENODE_USER=$HDFS_SECONDARYNAMENODE_USER | sudo sponge -a /home/ubuntu/.bash_profile
echo export YARN_RESOURCEMANAGER_USER=$YARN_RESOURCEMANAGER_USER | sudo sponge -a /home/ubuntu/.bash_profile
echo export YARN_NODEMANAGER_USER=$YARN_NODEMANAGER_USER | sudo sponge -a /home/ubuntu/.bash_profile
source /home/ubuntu/.bash_profile

echo "Configure Hadoop Environment"
echo "export JAVA_HOME=$JAVA_HOME" | sudo -- sponge -a /etc/hadoop/hadoop-env.sh
echo "export HADOOP_HOME=$HADOOP_HOME" | sudo -- sponge -a /etc/hadoop/hadoop-env.sh
echo "export HADOOP_CONF_DIR=$HADOOP_CONF_DIR" | sudo -- sponge -a /etc/hadoop/hadoop-env.sh
echo "export HDFS_NAMENODE_USER=$HDFS_NAMENODE_USER" | sudo -- sponge -a /etc/hadoop/hadoop-env.sh
echo "export HDFS_DATANODE_USER=$HDFS_DATANODE_USER" | sudo -- sponge -a /etc/hadoop/hadoop-env.sh
echo "export HDFS_SECONDARYNAMENODE_USER=$HDFS_SECONDARYNAMENODE_USER" | sudo -- sponge -a /etc/hadoop/hadoop-env.sh
echo "export YARN_RESOURCEMANAGER_USER=$YARN_RESOURCEMANAGER_USER" | sudo -- sponge -a /etc/hadoop/hadoop-env.sh
echo "export YARN_NODEMANAGER_USER=$YARN_NODEMANAGER_USER" | sudo -- sponge -a /etc/hadoop/hadoop-env.sh

aws ec2 describe-instances --region=us-east-1 | jq '.Reservations[].Instances[] | select(.State.Code == 16) | [(.Tags[]|select(.Key=="Name")|.Value), .PublicDnsName]' | paste - - - - > HDFS_INSTANCES
echo "HDFS_INSTANCES"
let datanode_count=0
while IFS= read -r line
do
  namenode=$(echo $line | sed -r 's/^.*"HDFS Namenode Instance ([0-9]+)".*"([a-z0-9\.\-]+)".*$/\1/')
  if [[ ${namenode:0:1} != "[" ]]
  then
      namenode_dns=$(echo $line | sed -r 's/^.*"HDFS Namenode Instance ([0-9]+)".*"([a-z0-9\.\-]+)".*$/\2/')
#      aws s3api delete-object --bucket hdfs-tmp --key $namenode_dns.id_rsa
#      aws s3api delete-object --bucket hdfs-tmp --key $namenode_dns.id_rsa.pub
  fi
  datanode=$(echo $line | sed -r 's/^.*"HDFS Datanode Instance ([0-9]+)".*"([a-z0-9\.\-]+)".*$/\1/')
  if [[ ${datanode:0:1} != "[" ]]
  then
      let datanode_count=datanode_count+1
      datanode_dns=$(echo $line | sed -r 's/^.*"HDFS Datanode Instance ([0-9]+)".*"([a-z0-9\.\-]+)".*$/\2/')
#      aws s3api delete-object --bucket hdfs-tmp --key $datanode_dns.id_rsa
#      aws s3api delete-object --bucket hdfs-tmp --key $datanode_dns.id_rsa.pub
  fi
done < "HDFS_INSTANCES"

echo "<configuration>" | sudo -- sponge  /etc/hadoop/core-site.xml
echo "  <property>" | sudo -- sponge -a /etc/hadoop/core-site.xml
echo "    <name>hadoop.tmp.dir</name>" | sudo -- sponge -a /etc/hadoop/core-site.xml
echo "    <value>file:///hadoop-tmp</value>" | sudo -- sponge -a /etc/hadoop/core-site.xml
echo "  </property>" | sudo -- sponge -a /etc/hadoop/core-site.xml
echo "  <property>" | sudo -- sponge -a /etc/hadoop/core-site.xml
echo "    <name>fs.default.name</name>" | sudo -- sponge -a /etc/hadoop/core-site.xml
echo "    <value>hdfs://$namenode_dns:9000</value>" | sudo -- sponge -a /etc/hadoop/core-site.xml
echo "  </property>" | sudo -- sponge -a /etc/hadoop/core-site.xml
echo "</configuration>" | sudo -- sponge -a /etc/hadoop/core-site.xml

echo "<configuration>" | sudo -- sponge /etc/hadoop/hdfs-site.xml
echo "  <property>" | sudo -- sponge -a /etc/hadoop/hdfs-site.xml
echo "    <name>dfs.replication</name>" | sudo -- sponge -a /etc/hadoop/hdfs-site.xml
echo "    <value>$datanode_count</value>" | sudo -- sponge -a /etc/hadoop/hdfs-site.xml
echo "  </property>" | sudo -- sponge -a /etc/hadoop/hdfs-site.xml
echo "  <property>" | sudo -- sponge -a /etc/hadoop/hdfs-site.xml
echo "    <name>dfs.namenode.name.dir</name>" | sudo -- sponge -a /etc/hadoop/hdfs-site.xml
echo "    <value>file:///hadoop-data/namenode</value>" | sudo -- sponge -a /etc/hadoop/hdfs-site.xml
echo "  </property>" | sudo -- sponge -a /etc/hadoop/hdfs-site.xml
echo "  <property>" | sudo -- sponge -a /etc/hadoop/hdfs-site.xml
echo "    <name>dfs.datanode.data.dir</name>" | sudo -- sponge -a /etc/hadoop/hdfs-site.xml
echo "    <value>file:///hadoop-data/datanode</value>" | sudo -- sponge -a /etc/hadoop/hdfs-site.xml
echo "  </property>" | sudo -- sponge -a /etc/hadoop/hdfs-site.xml
echo "</configuration>" | sudo -- sponge -a /etc/hadoop/hdfs-site.xml

sudo -- bash -c "cat /dev/null > /etc/hadoop/workers"
while IFS= read -r line
do
  datanode=$(echo $line | sed -r 's/^.*"HDFS Datanode Instance ([0-9]+)".*"([a-z0-9\.\-]+)".*$/\2/')
  if [[ ${datanode:0:1} != "[" ]]
  then
      echo $datanode | sudo -- sponge -a /etc/hadoop/workers
  fi
done < "HDFS_INSTANCES"

sudo cp /tmp/capacity-scheduler.xml /etc/hadoop/capacity-scheduler.xml
sudo cp /tmp/mapred-site.xml /etc/hadoop/mapred-site.xml
sudo cp /tmp/yarn-site.xml /etc/hadoop/yarn-site.xml

figlet -w 240 -f small "Update Instance Status Tag to provisioned"
aws ec2 create-tags --region us-east-1 --resources $INSTANCE_ID --tags Key=Status,Value=provisioned