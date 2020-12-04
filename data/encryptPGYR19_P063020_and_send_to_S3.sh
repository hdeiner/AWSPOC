#!/usr/bin/env bash

echo "Encrypting PGYR19_P063020 from /tmp"
gpg2 --batch --passphrase xyzzy --symmetric --cipher-algo AES256 --output PGYR19_P063020.ZIP < /tmp/PGYR19_P063020.ZIP
echo "Sending PGYR19_P063020 to S3"
aws s3 cp PGYR19_P063020.ZIP s3://health-engine-aws-poc/PGYR19_P063020.ZIP
echo "Removing PGYR19_P063020 from machine"
rm PGYR19_P063020.ZIP /tmp/PGYR19_P063020.ZIP



