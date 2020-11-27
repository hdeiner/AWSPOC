#!/usr/bin/env bash

aws s3 cp s3://health-engine-aws-poc/Experimental\ Results\ Lock.txt Experimental\ Results\ Lock.txt > /dev/null
sed --in-place --regexp-extended 's/running/complete/g' Experimental\ Results\ Lock.txt
aws s3 cp Experimental\ Results\ Lock.txt s3://health-engine-aws-poc/Experimental\ Results\ Lock.txt > /dev/null
rm Experimental\ Results\ Lock.txt

