#!/usr/bin/env bash

aws s3 cp s3://health-engine-aws-poc/Experimental\ Results\ Lock.txt Experimental\ Results\ Lock.txt > /dev/null
number=$(grep -Eo '[0-9]+' Experimental\ Results\ Lock.txt)
echo ${number}

