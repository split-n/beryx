# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|
  config.vm.box = "ubuntu/trusty64"
  config.vm.provider "virtualbox" do |v|
    v.gui = true
    v.cpus = 2
    v.memory = 1024
  end

  config.ssh.forward_agent = true

  config.vm.provision "ansible" do |ansible|
    ansible.verbose = "vv"
    ansible.host_key_checking = false # disable known_hosts check
    ansible.playbook = "provisioning/main.yml"
  end
end
