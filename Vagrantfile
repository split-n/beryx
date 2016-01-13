# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|
  config.vm.box = "ubuntu/wily64"
  config.vm.provider "virtualbox" do |v|
    v.gui = true
    v.cpus = 2
    v.memory = 1024
  end

  config.vm.network "private_network", ip: "192.168.235.10"
  config.vm.synced_folder ".", "/vagrant", type: "nfs"
  config.vm.network "forwarded_port", guest:13000, host:13000

  config.ssh.forward_agent = true

  config.vm.provision "ansible" do |ansible|
    ansible.verbose = "vv"
    ansible.host_key_checking = false # disable known_hosts check
    ansible.playbook = "provisioning/main.yml"
  end

end
