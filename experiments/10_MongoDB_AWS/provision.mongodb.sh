#!/usr/bin/env bash

sleep 15

sudo apt-get update
sudo apt-get install -y -qq figlet

figlet -w 160 -f small "Install Prerequisites"
sudo apt-get install -y -qq gnupg

figlet -w 160 -f small "Import MongoDB public GPG Key"
wget -qO - https://www.mongodb.org/static/pgp/server-4.4.asc | sudo apt-key add -

figlet -w 160 -f small "Create list file for MongoDB"
echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu bionic/mongodb-org/4.4 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-4.4.list

figlet -w 160 -f small "Install MongoDB packages"
sudo apt-get update
sudo apt-get install -y -qq mongodb-org

figlet -w 160 -f small "Start MongoDB"
sudo systemctl daemon-reload
sudo systemctl start mongod
sudo systemctl enable mongod

figlet -w 160 -f small "Verify That MongoDB Is Up"
echo -e `sudo systemctl status mongod`




