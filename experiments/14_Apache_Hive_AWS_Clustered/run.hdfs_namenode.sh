#!/usr/bin/env bash

figlet -w 240 -f small "Run Hadoop Namenodee"
source /home/ubuntu/.bash_profile

figlet -w 240 -f small "Wait for Datanodes to start running"
while IFS= read -r line
do
  datanode=$(echo $line | sed -r 's/^.*"HDFS Datanode Instance ([0-9]+)".*"([a-z0-9\.\-]+)".*$/\2/')
  if [[ ${datanode:0:1} != "[" ]]
  then
    datanode_status=""
    while [[ $datanode_status != "running" ]]; do
      datanode_status=$(aws ec2 describe-instances --region=us-east-1 | jq '.Reservations[].Instances[] | select(.PublicDnsName == "'$datanode'") | (.Tags[]|select(.Key=="Status")|.Value)')
      datanode_status=$(echo $datanode_status | sed 's/^"\(.*\)"$/\1/')
      echo "Namenode asks status of Datanode "$datanode" to see if it is running and finds it is "$datanode_status
      sleep 5
    done
  fi
done < "HDFS_INSTANCES"

figlet -w 240 -f small "Allow Hadoop Cluster SSH Access"
while IFS= read -r line
do
  node=$(echo $line | sed -r 's/^.*"HDFS (Name|Data)node Instance ([0-9]+)".*"([a-z0-9\.\-]+)".*$/\3/')
  if [[ ${node:0:1} != "[" ]]
  then
    node_status="provisioning"
    if [[ $node_status == "provisioning" ]]
    then
      node_status=$(aws ec2 describe-instances --region=us-east-1 | jq '.Reservations[].Instances[] | select(.PublicDnsName == "'$node'") | (.Tags[]|select(.Key=="Status")|.Value)')
      node_status=$(echo $node_status | sed 's/^"\(.*\)"$/\1/')
      echo "Namenode asks status of "$node" for not provisioning so it can ssh to it and finds it is "$node_status
      sleep 5
    fi
    echo "Adding "$node" to ssh authorized_keys for "$INSTANCE_DNS_NAME
    aws s3api wait object-exists --bucket hdfs-tmp --key $node.id_rsa.pub
    aws s3 cp s3://hdfs-tmp/$node.id_rsa.pub /tmp/id_rsa.pub
    chmod 777 ~/.ssh/authorized_keys
    cat /tmp/id_rsa.pub >> ~/.ssh/authorized_keys
    chmod 755 ~/.ssh/authorized_keys
  fi
done < "HDFS_INSTANCES"

namedir=file:///hadoop-data/namenode
figlet -w 240 -f small "Format namenode name directory: $namedir"
hdfs namenode -format > /dev/null

figlet -w 240 -f small "Start HDFS"
start-dfs.sh
echo "Wait For HDFS To Start"
while true ; do
  result=$(jps | grep -cE "^[0-9 ]*((Name|SecondaryName)Node)$")
  if [ $result == 2 ] ; then
#    sleep 10 # give it just a bit more for safety
    echo "HDFS has started"
    break
  fi
  sleep 5
done

figlet -w 240 -f small "Update Instance Status Tag to running"
aws ec2 create-tags --region us-east-1 --resources $INSTANCE_ID --tags Key=Status,Value=running