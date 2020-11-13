#!/usr/bin/env bash

figlet -w 160 -f small "Export GPG2 Public and Private Keys"
figlet -w 160 -f slant "NEVER CHECK THESE INTO GIT"

gpg2 --export -a "Howard Deiner" > HealthEngine.AWSPOC.public.key
echo 'xyzzy' | gpg2 --batch --yes --pinentry-mode loopback --passphrase-fd 0 --export-secret-key -a "Howard Deiner"  > HealthEngine.AWSPOC.private.key