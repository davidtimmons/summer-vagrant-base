#!/usr/bin/env bash

#
# Adjust software provisioned with this base box here. When adjusting the installation script,
# do not use the <$HOME> shell variable as Vagrant runs this script as root. Since many of these
# tools require local installation, that will break this script. The local user is "vagrant".
#

# Software Configuration
NODE_VERSION="6.1.0" # <nodenv install -l> prints all available versions.
PYTHON_VERSION="3.5.1"
MYSQL_VERSION="5.7"
MYSQL_ROOT_PASSWORD="12345" # Replace with desired root password!
BASH_PROFILE="/home/vagrant/.bash_profile"
LOG_PATH="/home/vagrant/logs/"
LOG_FILE="${LOG_PATH}/provision-script.log"

# Installation Log
mkdir $LOG_PATH
printf "Provisioning Log\n" >> $LOG_FILE 2>&1
chmod 775 $LOG_PATH $LOG_FILE
chown vagrant $LOG_PATH $LOG_FILE

# Linux Tools
printf "\n::: LINUX TOOLS :::\n\n" >> $LOG_FILE
echo "Installing: Linux tools..."
apt-get update -y >> $LOG_FILE 2>&1
apt-get install -y git tree expect daemon build-essential curl python-setuptools ruby-dev \
                   make cmake scons autoconf automake autoconf-archive gettext libtool flex \
                   bison m4 texinfo python-gpgme zlib1g-dev libbz2-dev libcurl4-openssl-dev \
                   libexpat-dev libncurses-dev libpq-dev libsqlite3-dev libreadline-dev \
                   >> $LOG_FILE 2>&1

# Linux Brew
printf "\n::: LINUXBREW :::\n\n" >> $LOG_FILE
echo "Installing: Linuxbrew..."
su -c 'ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Linuxbrew/install/master/install)"' vagrant >> $LOG_FILE 2>&1
echo -e "\n# Linuxbrew:\n" >> $BASH_PROFILE
echo 'export PATH="/home/vagrant/.linuxbrew/bin:$PATH"' >> $BASH_PROFILE
echo 'export MANPATH="/home/vagrant/.linuxbrew/share/man:$MANPATH"' >> $BASH_PROFILE
echo 'export INFOPATH="/home/vagrant/.linuxbrew/share/info:$INFOPATH"' >> $BASH_PROFILE
chmod 664 $BASH_PROFILE # Change permissions to include user "vagrant".
source $BASH_PROFILE

# Node.js
printf "\n::: NODE.JS :::\n\n" >> $LOG_FILE
echo "Installing: Node.js..."
su -c "source $BASH_PROFILE && \
       brew install nodenv >> $LOG_FILE 2>&1 && \
       nodenv install $NODE_VERSION >> $LOG_FILE 2>&1 && \
       nodenv global $NODE_VERSION >> $LOG_FILE 2>&1" \
       vagrant >> $LOG_FILE 2>&1
echo -e "\n# nodenv (Node.js Environment):\n" >> $BASH_PROFILE
echo 'export PATH="/home/vagrant/.nodenv/bin:$PATH"' >> $BASH_PROFILE
echo 'eval "$(nodenv init -)"' >> $BASH_PROFILE

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
       brew install pyenv >> $LOG_FILE 2>&1 && \
       pyenv install $PYTHON_VERSION >> $LOG_FILE 2>&1 && \
       pyenv global $PYTHON_VERSION >> $LOG_FILE 2>&1" \
       vagrant >> $LOG_FILE 2>&1
echo -e "\n# pyenv (Python Environment):\n" >> $BASH_PROFILE
echo 'export PYENV_ROOT="/home/vagrant/.pyenv"' >> $BASH_PROFILE
echo 'export PATH="$PYENV_ROOT/bin:$PATH"' >> $BASH_PROFILE

# Since the provisioned development environment is already a sandbox, it should be safe to
# install Python packages globally if desired.
printf 'export PYTHONPATH=$PYTHONPATH:/home/vagrant/.pyenv/versions/' >> $BASH_PROFILE
echo "$PYTHON_VERSION/lib/python${PYTHON_VERSION:0:3}/site-packages/" >> $BASH_PROFILE
echo 'eval "$(pyenv init -)"' >> $BASH_PROFILE

# Mailhog (https://github.com/mailhog/MailHog)
# Note: Tests emails sent by your application.
printf "\n::: MAILHOG :::\n\n" >> $LOG_FILE 2>&1
echo "Installing: MailHog..."
su -c "source $BASH_PROFILE && \
       brew install mailhog >> $LOG_FILE 2>&1" \
       vagrant >> $LOG_FILE 2>&1

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
    send \"$MYSQL_ROOT_PASSWORD\r\"
  }
  expect \"Re-enter root password:\" {
    send \"$MYSQL_ROOT_PASSWORD\r\"
  }
  expect eof
" >> $LOG_FILE 2>&1
service mysql stop >> $LOG_FILE 2>&1
service mysql start >> $LOG_FILE 2>&1 # Restart MySQL server.
