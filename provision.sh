#!/usr/bin/env bash

#
# Automated build script that provisions a Vagrant "ubuntu/trusty64" box loaded with Ruby,
# Python, Node.js, and MySQL for use as a development environment for the summer.
# The MySQL root password is passed as an argument into this script.
# Note that Vagrant runs this script as a root user. The local user is "vagrant".
#

# Software Configuration
NODE_VERSION="6.1.0" # <nodenv install -l> prints all available versions.
PYTHON_VERSION="3.5.1"
MYSQL_VERSION="5.7"
BASH_PROFILE="/home/vagrant/.bash_profile"
LOG_FILE="/tmp/provision-script.log"

# Precondition
if [ -z $1 ]; then # Check if the first script argument is null.
   echo "Please run <build.sh> and supply a MySQL password!"
   exit 1
fi

# Installation Log
printf "Provisioning Log\n" >> $LOG_FILE 2>&1

# Linux Tools
printf "\n::: LINUX TOOLS :::\n\n" >> $LOG_FILE
echo "Installing: Linux tools..."
apt-get update -y >> $LOG_FILE 2>&1
apt-get install -y git tree expect daemon build-essential curl \
                   python-setuptools ruby-dev nodejs zlib1g-dev >> $LOG_FILE 2>&1

# Linux Brew
printf "\n::: LINUXBREW :::\n\n" >> $LOG_FILE
echo "Installing: Linuxbrew..."
su -c 'ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Linuxbrew/install/master/install)"' vagrant >> $LOG_FILE
echo -e "\n# Linuxbrew:\n" >> $BASH_PROFILE
echo 'export PATH="$HOME/.linuxbrew/bin:$PATH"' >> $BASH_PROFILE
echo 'export MANPATH="$HOME/.linuxbrew/share/man:$MANPATH"' >> $BASH_PROFILE
echo 'export INFOPATH="$HOME/.linuxbrew/share/info:$INFOPATH"' >> $BASH_PROFILE
chmod 664 $BASH_PROFILE # Change permissions to include user.
source $BASH_PROFILE

# Node.js
printf "\n::: NODE.JS :::\n\n" >> $LOG_FILE
echo "Installing: Node.js..."
su -c "source $BASH_PROFILE && \
       brew install nodenv && \
       nodenv install $NODE_VERSION && \
       nodenv global $NODE_VERSION" \
       vagrant >> $LOG_FILE
echo -e "\n# nodenv (Node.js Environment):\n" >> $BASH_PROFILE
echo 'export PATH="$HOME/.nodenv/bin:$PATH"' >> $BASH_PROFILE
echo 'eval "$(nodenv init -)"' >> $BASH_PROFILE
source $BASH_PROFILE

# NPM Packages (Global)
# Note: The <david> tool checks local package dependencies for available updates.
printf "\n::: NPM PACKAGES (GLOBAL) :::\n\n" >> $LOG_FILE 2>&1
echo "Installing: NPM Packages..."
su -c "source $BASH_PROFILE && \
       npm install -g david >> $LOG_FILE 2>&1" \
       vagrant >> $LOG_FILE 2>&1

# Python
# Note: Configure pyenv to use a specific Python version locally by adding a <.python-version> file
# to a directory. pyenv will use the first <.python-version> file it finds in the directory tree.
printf "\n::: PYTHON :::\n\n" >> $LOG_FILE
echo "Installing: Python..."
su -c "source $BASH_PROFILE && \
       brew install pyenv && \
       pyenv install $PYTHON_VERSION && \
       pyenv global $PYTHON_VERSION" \
       vagrant >> $LOG_FILE
echo -e "\n# pyenv (Python Environment):\n" >> $BASH_PROFILE
echo 'export PYENV_ROOT="$HOME/.pyenv"' >> $BASH_PROFILE
echo 'export PATH="$PYENV_ROOT/bin:$PATH"' >> $BASH_PROFILE
echo 'eval "$(pyenv init -)"' >> $BASH_PROFILE
source $BASH_PROFILE

# Mailhog (https://github.com/mailhog/MailHog)
# Note: Tests emails sent by your application.
printf "\n::: MAILHOG :::\n\n" >> $LOG_FILE 2>&1
echo "Installing: MailHog..."
su -c "source $BASH_PROFILE && \
       brew install mailhog >> $LOG_FILE 2>&1" \
       vagrant >> $LOG_FILE 2>&

# MySQL
# Note: The client software is bundled with the server package.Configuration options include...
# deb http://repo.mysql.com/apt/{debian|ubuntu}/ {jessie|wheezy|precise|trusty|utopic|vivid}
#     {mysql-5.6|mysql-5.7|workbench-6.2|utilities-1.4|connector-python-2.0}
printf "\n::: MYSQL :::\n\n" >> $LOG_FILE
echo "Installing: MySQL..."
gpg --keyserver hkp://pgp.mit.edu --recv-keys 5072E1F5 >> $LOG_FILE 2>&1
gpg --armor --export 5072E1F5 | apt-key add - >> $LOG_FILE 2>&1
echo "deb http://repo.mysql.com/apt/ubuntu/ trusty mysql-${MYSQL_VERSION}" >> /etc/apt/sources.list.d/mysql.list
apt-get update -y >> $LOG_FILE 2>&1
apt-get install libmysqlclient-dev -y >> $LOG_FILE 2>&1 # Client installed with server package.
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
" >> $LOG_FILE 2>&1
service mysql stop >> $LOG_FILE 2>&1
service mysql start >> $LOG_FILE 2>&1 # Restart MySQL server.
