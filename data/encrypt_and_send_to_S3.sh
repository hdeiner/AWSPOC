#!/usr/bin/env bash

cd oracle ; ls -1 *.csv > ../.filesToEncrypt ; cd ..

cat .filesToEncrypt |
  while read LINE;
    do
      echo "Working on ${LINE}"
      gpg2 --batch --passphrase xyzzy --symmetric --cipher-algo AES256 --output ${LINE} <  oracle/${LINE}
      aws s3 cp ${LINE} s3://health-engine-aws-poc/${LINE}
      rm ${LINE}
      rm oracle/{LINE}
    done

rm .filesToEncrypt


