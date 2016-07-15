Summer Vagrant Base Box
===========================

These shell scripts produce a Vagrant base box provisioned with Python, Node.js, Ruby, MySQL, and
Linux Brew for use as a development environment good for any summer side project!

# 0.0 QUICK START

* Change language versions and the database password in `configure.sh`.
* Open a Bash terminal, and run `source build.sh` to create a base box.
* Include `dist/Vagrantfile` in the root of any other project directory to use this box.
* Run `vagrant up` in your project directory to create the development box.
* `http://localhost:3000` opens to your application.
* `http://localhost:3001` opens to a test email inbox that catches messages sent to port `1025`.

# 1.0 UNDERLYING OS

*Ubuntu Server 14.04 LTS (Trusty Tahr)* sourced from https://vagrantcloud.com/ubuntu/.

# 1.1 Managing languages within the provisioned box.

The provisioned box uses `pyenv` and `nodenv` to control language versions. Use these tools to
download and use different versions of Python and Node.js respectively.

# 2.0 TROUBLESHOOTING

* There are small differences between Unix Bash shell and the Mac OS X shell. You may need to
  adjust these build scripts if using a Mac.
* Run `vagrant destroy -f && vagrant box remove <name>` (where *<name>* is the name of the
  installed box) to destroy a bad installation attempt.
* Provisioning logs are stored in the provisioned box at `/home/vagrant/logs/`.
