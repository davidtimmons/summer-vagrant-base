# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|

  # Configure the Vagrant box. For a complete reference, see the online
  # documentation at https://docs.vagrantup.com.
  config.vm.box = "ubuntu/trusty64"
  config.ssh.insert_key = false
  config.vm.box_check_update = true
  config.vm.provider "virtualbox" do |vb|
    vb.gui = false # Display the VirtualBox GUI when booting the machine.
    vb.memory = "2048" # Customize the amount of memory on the VM.
  end

  # Provision information about this box; display it with the "guestvm" command.
  # Source: https://github.com/pro-vagrant/vagrant-box-factory-apache
  config.vm.provision "file", source: "box-info/box-name.txt", destination: "/home/vagrant/box-info/box-name.txt"
  config.vm.provision "file", source: "box-info/box-version.txt", destination: "/home/vagrant/box-info/box-version.txt"
  config.vm.provision "file", source: "box-info/box-date.txt", destination: "/home/vagrant/box-info/box-date.txt"
  config.vm.provision "file", source: "box-info/guestvm", destination: "/home/vagrant/box-info/guestvm"
  config.vm.provision "shell", inline: "mv /home/vagrant/box-info/guestvm /usr/bin && chmod 755 /usr/bin/guestvm"

  # Enable provisioning with a shell script.
  config.vm.provision "shell", path: "configure.sh", args: ENV['MYSQL_ROOT_PASSWORD']
end
