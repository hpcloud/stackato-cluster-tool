#### 1. Have all your Vagrant boxes in the folder `boxes/`
#### 2. Update the manifest `manifest.json` with the location of the boxes
#### 3. Start the Vagrant repository

```
vagrant up
```

#### 4. Get the IP address of your vagrant repository

```
vagrant ssh -c "ip -4 address"
```

#### 5. Add a DNS entry for vagrant.stackato.com in your hosts file or DNS server
