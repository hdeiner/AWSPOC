#!/usr/bin/env bash

aws s3 cp s3://health-engine-aws-poc/$1 $1.gpg
gpg2 --decrypt --batch --passphrase xyzzy $1.gpg > $1
rm $1.gpg
