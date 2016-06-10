Summer: Vagrant Base Box
===========================

This package produces a Vagrant base box provisioned with Ruby, Python, Node.js,
MySQL, and Linux Brew for use as a development environment.

# 1. Underlying OS
*Ubuntu Server 14.04 LTS (Trusty Tahr)* generated with
https://vagrantcloud.com/ubuntu/

# 2. Build from Source

## 2.1. Change Software Versions
Edit the `provision.sh` file to change the language versions.

## 2.2. Change Database Password
Edit the `build.sh` file to change the *MySQL* root account password.

## 2.3. Run the Shell Script
    source build.sh

# 3. Troubleshooting
When in doubt, use `vagrant destroy -f` and `vagrant box remove <name>` to
start with a clean slate. Provisioning logs are stored in the guest box at
`/tmp/provision-script.log`.
