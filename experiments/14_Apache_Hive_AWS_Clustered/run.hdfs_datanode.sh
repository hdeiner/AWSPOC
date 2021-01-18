#!/usr/bin/env bash

figlet -w 240 -f small "Run Hadoop Datanode"
source /home/ubuntu/.bash_profile

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
      echo "Datanode asks status of "$node" for not provisioning so it can ssh to it and finds it "$node_status
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

figlet -w 240 -f small "Update Instance Status Tag to running"
aws ec2 create-tags --region us-east-1 --resources $INSTANCE_ID --tags Key=Status,Value=running