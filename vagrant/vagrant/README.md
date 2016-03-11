# Stackato with Vagrant

## Configure your cluster

See file `config.yaml`

## Start your cluster

**Note**: Stackato doesn't work with Vagrant because nodes are attached to the core node using their Vagrant NAT NIC which is the same IP between all Vagrant VMs. 

```
vagrant up
```

**Note**: if you want to enable parallel deployment mode in Vagrant for Virtualbox, edit the file `/opt/vagrant/embedded/gems/gems/vagrant-1.8.1/plugins/providers/virtualbox/plugin.rb` by changing `provider(:virtualbox, priority: 6) do` into `provider(:virtualbox, priority: 6, parallel: true) do`

## Additional actions

See `vagrant list-commands`

Interesting actions:
* `vagrant snapshot`: manages snapshots: saving, restoring, etc.
* `vagrant suspend`: suspends the machine
* `vagrant resume`: resume a suspended vagrant machine
* `vagrant halt`: stops the vagrant machine

## Destroy your cluster

```
vagrant destroy
```
