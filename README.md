## stackato-cluster-tool
*Assists in the rapid provisioning of Stackato clusters on Amazon AWS, OpenStack or Vagrant*.*

---

**\*Note:** *Vagrant support is currently rudimentary. Please see vagrant/README for more information.*

---

**Requirements:**

1. Terraform
2. Valid Account and keys for your cloud provider

##### 1. Install Terraform
https://terraform.io/downloads.html

##### 2. Configuring your Stackato cluster
_Check out the latest stable release:_

```
git checkout v0.9.0
```



###### 2.1. Amazon AWS
Create the initial configuration:
```
./make.sh -p amazon-aws -lb
cd out
```

- Edit config.tf to configure and name your cluster.
- Edit config-amazon.tf to configure your Amazon AWS particulars such as your access and ssh keys, spot or on-demand instances, as well as regions.
- If using the load balancer option, your ssl certificate and key should be in the `out` folder and the keys `certificate_path` and `private_key_path` must be updated in `config.tf`.

###### 2.2. OpenStack
**Note:** If your OpenStack cluster is using domains (Identity API v3), you can download our custom Terraform plugin for OpenStack from https://github.com/hpcloud/stackato-cluster-tool/releases until the PR https://github.com/hashicorp/terraform/pull/7041 is merged.

Create the initial configuration:
```
./make.sh -p openstack
cd out
```

- Edit config.tf to configure and name your cluster.
- Edit config-openstack.tf to configure your Openstack particulars.
- If you need to setup static DNS servers, comment out and setup the line "dns_nameservers" in the file provider-openstack-network.tf

##### 3. Start your cluster

Confirm that your cluster creation plan is valid before actually building it
```
terraform plan
```
If the plan is successful then start your cluster.
```
terraform apply
```

*Tip: you can follow the provisioning progress on each node from `/var/log/cloud-init-output.log`.*

##### 4. Modify a running cluster
Changes made to the cluster configuration file `config.tf` can be tested and then deployed by running the commands listed in step 3.

##### 5. Destroy a cluster
To destroy your cluster, run
```
terraform destroy
```
and enter`yes` when prompted.
