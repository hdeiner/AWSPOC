#!/usr/bin/env bash

figlet -w 160 -f small "Import GPG2 Public and Private Keys"

figlet -w 160 -f small "Before Import"
figlet -w 160 -f small "Public"
gpg2 --list-public-keys
figlet -w 160 -f small "Private"
gpg2 --list-secret-keys

gpg2 --import < $1
gpg2 --import < $2
#echo 'xyzzy' | gpg2 --batch --yes --pinentry-mode loopback --passphrase-fd 0 --import-secret-key -a "Howard Deiner"  < $2

figlet -w 160 -f small "After Import"
figlet -w 160 -f small "Public"
gpg2 --list-public-keys
figlet -w 160 -f small "Private"
gpg2 --list-secret-keys
