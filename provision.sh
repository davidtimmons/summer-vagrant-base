#!/usr/bin/env bash

#
# Automated build script that provisions a Vagrant ubuntu/trusty64 box
# loaded with Ruby, Python, Node.js, and MySQL for use as a development
# environment for the summer. The MySQL root password is
# passed as an argument into this script.
#

# Software Configuration
NODE_VERSION="6.1.0"
PYTHON_VERSION="3.5.1"
MYSQL_VERSION="5.7"

# Precondition
if [ -z $1 ]; then # Check if the first script argument is null.
   echo "Please run <build.sh> and supply a MySQL password!"
   exit 1
fi

# Installation Log
printf "Provisioning Log\n" >> /tmp/provision-script.log 2>&1

# Linux Tools
printf "\n::: LINUX TOOLS :::\n\n" >> /tmp/provision-script.log
echo "Installing: Linux tools..."
apt-get update -y >> /tmp/provision-script.log 2>&1
apt-get install -y tree vim git expect curl build-essential make cmake scons \
                   ruby autoconf automake autoconf-archive gettext libtool \
                   flex bison m4 texinfo python-gpgme libbz2-dev zlib1g-dev \
                   libcurl4-openssl-dev libexpat-dev libncurses-dev libpq-dev \
                   libsqlite3-dev libreadline-dev >> /tmp/provision-script.log 2>&1

# Linux Brew
printf "\n::: LINUXBREW :::\n\n" >> /tmp/provision-script.log
echo "Installing: Linuxbrew..."
su -c 'ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Linuxbrew/install/master/install)"' vagrant >> /tmp/provision-script.log
echo -e "\n# Linuxbrew:\n" >> /home/vagrant/.bash_profile
echo 'export PATH="/home/vagrant/.linuxbrew/bin:$PATH"' >> /home/vagrant/.bash_profile
echo 'export MANPATH="/home/vagrant/.linuxbrew/share/man:$MANPATH"' >> /home/vagrant/.bash_profile
echo 'export INFOPATH="/home/vagrant/.linuxbrew/share/info:$INFOPATH"' >> /home/vagrant/.bash_profile
chmod 664 /home/vagrant/.bash_profile # Change permissions to include user.
source /home/vagrant/.bash_profile

# Node.js
printf "\n::: NODE.JS :::\n\n" >> /tmp/provision-script.log
echo "Installing: Node.js..."
su -c "source /home/vagrant/.bash_profile && \
       brew install nodenv && \
       nodenv install $NODE_VERSION && \
       nodenv global $NODE_VERSION" \
       vagrant >> /tmp/provision-script.log
echo -e "\n# nodenv (Node.js Environment):\n" >> /home/vagrant/.bash_profile
echo 'export PATH="$HOME/.nodenv/bin:$PATH"' >> /home/vagrant/.bash_profile
echo 'eval "$(nodenv init -)"' >> /home/vagrant/.bash_profile
source /home/vagrant/.bash_profile

# Python
printf "\n::: PYTHON :::\n\n" >> /tmp/provision-script.log
echo "Installing: Python..."
su -c "source /home/vagrant/.bash_profile && \
       brew install pyenv && \
       pyenv install $PYTHON_VERSION && \
       pyenv global $PYTHON_VERSION" \
       vagrant >> /tmp/provision-script.log
echo -e "\n# pyenv (Python Environment):\n" >> /home/vagrant/.bash_profile
echo 'export PYENV_ROOT="$HOME/.pyenv"' >> /home/vagrant/.bash_profile
echo 'export PATH="$PYENV_ROOT/bin:$PATH"' >> /home/vagrant/.bash_profile
echo 'eval "$(pyenv init -)"' >> /home/vagrant/.bash_profile
source /home/vagrant/.bash_profile

# MySQL
# Note: The client software is bundled with the server package.
# Configuration options include...
# deb http://repo.mysql.com/apt/{debian|ubuntu}/ {jessie|wheezy|precise|trusty|utopic|vivid} {mysql-5.6|mysql-5.7|workbench-6.2|utilities-1.4|connector-python-2.0}
printf "\n::: MYSQL :::\n\n" >> /tmp/provision-script.log
echo "Installing: MySQL..."
gpg --keyserver hkp://pgp.mit.edu --recv-keys 5072E1F5 >> /tmp/provision-script.log 2>&1
gpg --armor --export 5072E1F5 | apt-key add - >> /tmp/provision-script.log 2>&1
echo "deb http://repo.mysql.com/apt/ubuntu/ trusty mysql-${MYSQL_VERSION}" >> /etc/apt/sources.list.d/mysql.list
apt-get update -y >> /tmp/provision-script.log 2>&1
apt-get install libmysqlclient-dev -y >> /tmp/provision-script.log 2>&1 # Client installed with server package.
expect -c "
  set timeout 1800
  spawn apt-get install mysql-server -y
  expect \"Enter root password:\" {
    send \"$1\r\"
  }
  expect \"Re-enter root password:\" {
    send \"$1\r\"
  }
  expect eof
" >> /tmp/provision-script.log 2>&1
service mysql stop >> /tmp/provision-script.log 2>&1
service mysql start >> /tmp/provision-script.log 2>&1 # Restart MySQL server.
