#!/usr/bin/env bash

#
# Run this shell script to provision a Vagrant ubuntu/trusty64 box with Python,
# Ruby, Node.js, and MySQL.
#

# Configuration Options
BOX_NAME="summer-ubuntu64"
BOX_VERSION="v0.2.0"
FILE="${BOX_NAME}-${BOX_VERSION}.box"
MYSQL_ROOT_PASSWORD="12345" # Replace with desired root password!

# Store Box Information.
echo $BOX_NAME > ./box-info/box-name.txt
echo $BOX_VERSION > ./box-info/box-version.txt
date > ./box-info/box-date.txt

# Create the Box
export MYSQL_ROOT_PASSWORD
vagrant destroy -f
vagrant up --destroy-on-error && \
vagrant package --vagrantfile Vagrantfile-include --output $FILE && \
vagrant destroy -f && \
mv $FILE dist/ && \
vagrant box add --name "${BOX_NAME}-${BOX_VERSION}" "dist/${FILE}" && \
sed -i "s/v[0-9]\.[0-9]\.[0-9]/${BOX_VERSION}/" dist/Vagrantfile
