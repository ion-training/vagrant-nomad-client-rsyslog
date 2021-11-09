# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "hashicorp/bionic64"


  config.vm.define "syslog" do |syslog|
    syslog.vm.hostname = "syslog"
    syslog.vm.provision "shell", path: "scripts/syslog.sh"
    syslog.vm.network "private_network", ip: "192.168.56.70"
  end

  config.vm.define "server" do |server|
    server.vm.hostname = "server"
    server.vm.provision "shell", path: "scripts/server.sh"
    server.vm.network "private_network", ip: "192.168.56.71"
  end

  config.vm.define "client" do |client|

    client.vm.hostname = "client"
    client.vm.provision "shell", path: "scripts/client.sh"
    client.vm.network "private_network", ip: "192.168.56.72"

    client.vm.provider "virtualbox" do |v|
      v.memory = 1024*2
      v.cpus = 2
    end

  end

end
