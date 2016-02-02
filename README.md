[![Build Status](https://travis-ci.org/split-n/beryx.svg?branch=master)](https://travis-ci.org/split-n/beryx)

# beryx
Video streaming media server

# Dev provisioning
## Mac/Linux
`vagrant up`  
or  
`ansible-playbook  -u vagrant -i .vagrant/provisioners/ansible/inventory/vagrant_ansible_inventory provisioning/main.yml -vvv`

## Windows
execute provisioning manually.  
```
vagrant ssh
sudo apt-get install python-pip
sudo pip install ansible
ansible-playbook -c local -i localhost, /vagrant/provisioning/main.yml
```

# naming
media → medai → kinmedai → **beryx**

