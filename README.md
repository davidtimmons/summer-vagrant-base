Summer: Vagrant Base Box
===========================

This package produces a Vagrant base box provisioned with Ruby, Python, Node.js,
MySQL, and Linux Brew for use as a development environment.

# 1. UNDERLYING OS
*Ubuntu Server 14.04 LTS (Trusty Tahr)* generated with https://vagrantcloud.com/ubuntu/

# 2. BUILD FROM SOURCE

## 2.1. Change software versions & database password
Edit the `configure.sh` file to change language versions and the database password.

## 2.2. Run the shell script
    source build.sh

# 3. TROUBLESHOOTING
When in doubt, use `vagrant destroy -f` and `vagrant box remove <name>` to start with a clean slate. Provisioning logs are stored in the guest box at `/tmp/provision-script.log`.
