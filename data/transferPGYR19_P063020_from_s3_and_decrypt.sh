#!/usr/bin/env bash

echo "Retrieving PGYR19_P063020 from S3"
aws s3 cp s3://health-engine-aws-poc/PGYR19_P063020.ZIP /tmp/PGYR19_P063020.ZIP.gpg
echo "Decrypting PGYR19_P063020 in /tmp"
gpg2 --decrypt --batch --passphrase xyzzy /tmp/PGYR19_P063020.ZIP.gpg > /tmp/PGYR19_P063020.ZIP
rm /tmp/PGYR19_P063020.ZIP.gpg
echo "Creating PGYR19_P063020 in /tmp"
unzip  /tmp/PGYR19_P063020.ZIP -d /tmp/PGYR19_P063020
rm /tmp/PGYR19_P063020.ZIP