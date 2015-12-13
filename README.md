# beryx
Video streaming media server

# Dev provisioning
## Mac/Linux
done by `vagrant up`  
or  
`ansible-playbook  -u vagrant -i .vagrant/provisioners/ansible/inventory/vagrant_ansible_inventory provisioning/main.yml -vvv`
### notice
before `vagrant up`/`vagrant provision`
```
ssh-add
ssh-agent
```

## Windows
Shoud execute provisioning manually.  
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

