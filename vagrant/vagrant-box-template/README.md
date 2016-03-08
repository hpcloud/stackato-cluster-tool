# Make the Stackato Vagrant box:

#### 1. Import the Stackato image in VirtualBox
#### 2. Take note of the MAC address of the imported VM and write it in the Vagrantfile
#### 3. Create the box:

```
vagrant package --base NAME_OF_THE_VM --output NAME_OF_THE_VM.box --vagrantfile Vagrantfile
```
