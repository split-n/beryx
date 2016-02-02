[![Build Status](https://travis-ci.org/split-n/beryx.svg?branch=master)](https://travis-ci.org/split-n/beryx)

# beryx
Video streaming media server

# Dev provisioning
## Mac/Linux
```
ssh-add
ssh-agent
```
and
`vagrant up`  
or  
`ansible-playbook  -u vagrant -i .vagrant/provisioners/ansible/inventory/vagrant_ansible_inventory provisioning/main.yml -vvv`

## Windows
execute provisioning manually.  
```
cp /path/to/id_rsa /path/to/here
vagrant ssh
sudo apt-get install python-pip
sudo pip install ansible
cp /vagrant/id_rsa ~/.ssh/id_rsa
chmod 600 ~/.ssh/id_rsa
ansible-playbook -c local -i localhost, /vagrant/provisioning/main.yml
```

# naming
media → medai → kinmedai → **beryx**

