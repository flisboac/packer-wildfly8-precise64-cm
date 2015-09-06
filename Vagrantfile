#!/usr/bin/env ruby
# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|
  config.vm.box = "hashicorp/precise64" # "puppetlabs/ubuntu-12.04-64-puppet"
  
  config.vm.provision "shell", path: "scripts/provision.sh"
end
