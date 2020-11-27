#!/usr/bin/env bash

gotLock=false
while [ $gotLock == false ] ; do
  aws s3 cp s3://health-engine-aws-poc/Experimental\ Results\ Lock.txt Experimental\ Results\ Lock.txt > /dev/null
  result=$(grep -cE 'running' Experimental\ Results\ Lock.txt)
  if [ $result == 1 ]
  then
    echo "Don't have experiment lock"
    sleep 5
  else
    break
  fi
done

number=$(grep -Eo '[0-9]+' Experimental\ Results\ Lock.txt)
number=$((number+1))
echo ${number}" running" > Experimental\ Results\ Lock.txt
aws s3 cp Experimental\ Results\ Lock.txt s3://health-engine-aws-poc/Experimental\ Results\ Lock.txt > /dev/null
rm Experimental\ Results\ Lock.txt


