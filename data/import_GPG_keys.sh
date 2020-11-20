#!/usr/bin/env bash

figlet -w 160 -f small "Import GPG2 Public and Private Keys"

figlet -w 160 -f small "Before Import"
figlet -w 160 -f small "Public"
gpg2 --list-public-keys
figlet -w 160 -f small "Private"
gpg2 --list-secret-keys

gpg2 --import < $1
touch ~/.gnupg/secring.gpg
gpg2 --batch  --import  < $2

figlet -w 160 -f small "After Import"
figlet -w 160 -f small "Public"
gpg2 --list-public-keys
figlet -w 160 -f small "Private"
gpg2 --list-secret-keys
