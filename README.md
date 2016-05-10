# stackato-cluster-tool
Terraform a Stackato cluster on Amazon AWS and OpenStack.

Note: For Vagrant, see the folder `vagrant/`.

##### 1. Install Terraform
https://terraform.io/downloads.html

##### 2. Setup your Stackato cluster with make.sh

Checkout the latest release:
`git checkout v0.8.0`

Print the help of make.sh:
```
On Linux: ./make.sh --help
On Windows: bash -c "./make.sh --help"
```

###### For an Amazon cluster
Create the basic configuration:
```
make.sh -p amazon-aws -lb
cd out
```

Then:

Note: For Stackato developer, prefix the name of your cluster with "developer-" in order to be able to upload a server certificate for the ELB.

- Choose your cluster configuration in config.tf. The name of the cluster (key cluster_name) will be asked while launching Terraform
- Choose your Amazon configuration in config-amazon.tf, especially aws_access_key and aws_secret_key. Check the Amazon documentation http://docs.aws.amazon.com/AWSSimpleQueueService/latest/SQSGettingStartedGuide/AWSCredentials.html to get those two keys.
- Make sure you uploaded your public SSH key (see doc: http://docs.aws.amazon.com/gettingstarted/latest/wah/getting-started-prereq.html#create-a-key-pair) and update the variable `ssh_key_name` in config-amazon.tf
- If using the load balancer option, your ssl certificate and key should be in the `out` folder and the keys `certificate_path` and `private_key_path` must be updated in `config.tf`.

###### For an OpenStack cluster
Create the basic configuration:
```
make.sh -p openstack
cd out
```
Then:
- Choose your cluster configuration in config.tf. The name of the cluster (key cluster_name) will be asked while launching Terraform
- Choose your OpenStack configuration in config-openstack.tf
- Make sure you uploaded your public SSH key (see doc: http://docs.openstack.org/user-guide/configure_access_and_security_for_instances.html#import-a-key-pair) and update the variable `ssh_key_name` in config-openstack.tf

##### 3. Start the cluster
In a terminal, move to the root directory containing the Terraform files.

Check that the configuration from step 2 is valid by running `terraform plan`.

Start the cluster by running `terraform apply`.

Tips: you can follow the provisioning progress on each node from the file `/var/log/cloud-init-output.log`.

##### 4. Modify a running cluster
You can update the configuration file config.tf then run `terraform plan` and `terraform apply` again.

**/!\ OpenStack: A bug in the Terraform security group plugin prevents Terraform 0.6.9 to update an existing cluster (Terraform delete and recreate an updated security group that is already attached to an instance). The fix of the bug is in progress: https://github.com/hashicorp/terraform/issues/4714**

##### 5. Destroy a cluster
Run the command `terraform destroy` and type 'yes'.

# AWS secure cluster

The cluster tool will be able to create a cluster on AWS which isolates Stackato from the Internet by placing it in a private subnet. This Stackato cluster will access the internet through a proxy in a public subnet, and external cluster access will have to go through an ELB instance also in the public subnet.

In order to provide a production-like environment, the cluster tool with also configure the following:

1. an upstream proxy which must be traversed for Internet access. This will be managed by placing all Stackato nodes in a private subnet which will be accessible from a public load balancer.
2. role-based security groups to restrict internal node communication to the ports described on [our port configuration documentation page](http://docs.stackato.com/admin/cluster/index.html#port-configuration) (with some corrections made*).

\* *Any 'reason' with a `?` means that I'm either unsure of the reason for the rule, or skeptical that it's necessary*
#### `all-stackato`
*Security group for all stackato nodes. This should only be applied to the load balancer when using the Stackato load balancer*
##### inbound

|   protocol | port          |   source                      |  *reason*       |
|------------|---------------|-------------------------------|-----------------|
|     TCP    |  22           | [all-stackato](#all-stackato) |  SSH            |
|     TCP    |  7000-7099    | [all-stackato](#all-stackato) |  kato log tail  |
|     TCP    |  9001         | [all-stackato](#all-stackato) |  supervisord    |

\* *For 3.4.2, inbound access must also be allowed on port 4568 from the core node in order for Sentinel to communicate with sentineld of each other node during an upgrade*

##### outbound
|   protocol | port          |   destination                  |  *reason*       |
|------------|---------------|--------------------------------|-----------------|
|    TCP     |  22           | [all-stackato](#all-stackato)  | SSH             |
|    TCP     |  80           | all hosts                      | HTTP            |
|    TCP     |  443          | all hosts                      | HTTPS           |
|    TCP     |  4222         | [primary](#primary)            | NATS            |
|    TCP     |  5454         | [data-service](#data-service)  | redis-services? |
|    TCP     |  6379         | [primary](#primary)            | ephemeral redis |
|    TCP     |  6464         | [primary](#primary)            | applog redis    |
|    TCP     |  7000-7099    | [all-stackato](#all-stackato)  | kato log tail   |
|    TCP     |  7474         | [primary](#primary)            | config-redis    |
|    TCP     |  9001         | [all-stackato](#all-stackato)  | supervisord     |

\* *For proxied environments, customers will instead have outbound rules on ports 80 and 443 to [all-stackato](#all-stackato) and [upstream-proxy](#upstream-proxy)*

---
#### `primary`
*Group for only core/primary node*
##### inbound
|   protocol | port    |   source                            |  *reason*       |
|------------|---------|-------------------------------------|-----------------|
|    TCP     |  80     | [router](#router)                   | HTTP            |
|    TCP     |  443    | [router](#router)                   | HTTPS           |
|    TCP     |  4222   | [all-stackato](#all-stackato)       | NATS            |
|    TCP*    |  4567   | [router](#router)                   | NATS or AOK ?   |
|    TCP     |  6379   | [router](#router) and/or [dea](#dea)| ephemeral redis |
|    TCP     |  6464   | [all-stackato](#all-stackato)       | applog redis    |
|    TCP     |  7474   | [all-stackato](#all-stackato)       | config-redis    |  
\* *cannot stackato login without this*

---
#### `data-service`
*Group for all nodes which have any data service role (rabbit, mysql, postgres, mongodb, redis, or filesystem)*
##### inbound
|   protocol | port         |   source                      |  *reason*              |
|------------|--------------|-------------------------------|------------------------|
|    TCP     |  5454        | [all-stackato](#all-stackato) | redis-services?        |
|    TCP     |  41000-61000 | [DEA](#dea)                   | data service gateways? |
|    UDP     |  41000-61000 | [DEA](#dea)                   | data service gateways? |
|    TCP     |  41000-61000 | [controller](#controller)     | data service gateways? |
|    UDP     |  41000-61000 | [controller](#controller)     | data service gateways? |
---
#### `controller`
*Group for all nodes with controller role*
##### inbound
|   protocol | port    |   source          |  *reason*             |
|------------|---------|-------------------|-----------------------|
|    TCP     |  8181   | [DEA](#dea)       | droplet upload server |
|    TCP*    |  8181   | [router](#router) | droplet upload server |
|    TCP     |  9022   | [DEA](#dea)       | droplets?             |
|    TCP     |  9025   | [router](#router) | stackato-rest?        |
|    TCP     |  9026   | [router](#router) | stackato-rest?        |
\* *if disallowed, proxied API requests from router do not work*
##### outbound
|   protocol | port    |   destination             |  *reason*      |
|------------|---------|---------------------------|----------------|
|    TCP     |  3306   | [mysql](#mysql)           | mysql node     |
|    TCP     |  5432   | [postgreSQL](#postgresql) | postgreSQL     |
|    TCP     |  9022   | [DEA](#dea)               | droplets?      |
|    TCP     |  9025   | [controller](#controller) | stackato-rest? |
---
#### `router`
*Group for all nodes with router role*
##### inbound
|   protocol | port          |   source                        |  *reason*   |
|------------|---------------|---------------------------------|-------------|
|    TCP     |  22           | [load-balancer](#load-balancer) | SSH         |
|    TCP     |  80           | [load-balancer](#load-balancer) | HTTP        |
|    TCP     |  443          | [load-balancer](#load-balancer) | HTTPS       |
|    TCP*    |  41000-61000  | [load-balancer](#load-balancer) | harbor      |
|    UDP*    |  41000-61000  | [load-balancer](#load-balancer) | harbor      |
\* *If using Harbor only*
##### outbound
|   protocol | port         |   destination             |  *reason*             |
|------------|--------------|---------------------------|-----------------------|
|    TCP     |  4567        | [primary](#primary)       | NATS or AOK ?         |
|    TCP*    |  8181        | [controller](#controller) | droplet upload server |
|    TCP     |  9001        | [controller](#controller) | droplet upload server |
|    TCP     |  9025        | [controller](#controller) | stackato-rest?        |
|    TCP     |  9026        | [controller](#controller) | stackato-rest?        |
|    TCP     |  41000-61000 | [controller](#controller) | health manager        |
|    UDP**   |  41000-61000 | [controller](#controller) | harbor                |
\* *If disallowed, proxied API requests from router do not work. Don't ask me why*  
\*\* *If using Harbor only*
#### `load-balancer`
*Group for the load balancer. If using the Stackato load balancer, this should group should be applied along with the '[all-stackato](#all-stackato)' group*
##### inbound
|   protocol | port          |   source                        |  *reason*             |
|------------|---------------|---------------------------------|-----------------------|
|    TCP     |  22           | all hosts                       | Stackato SSH          |
|    TCP     |  80           | [load-balancer](#load-balancer) | HTTP                  |
|    TCP     |  443          | [load-balancer](#load-balancer) | HTTPS                 |
|    TCP*    |  41000-61000  | [load-balancer](#load-balancer) | harbor                |
|    UDP*    |  41000-61000  | [load-balancer](#load-balancer) | harbor                |
\* *If using Harbor only*
##### outbound
|   protocol | port         |   destination             |  *reason*             |
|------------|--------------|---------------------------|-----------------------|
|    TCP     |  8181        | [controller](#controller) | droplet upload server |
|    TCP     |  9001        | [controller](#controller) | droplet upload server |
|    TCP     |  9026        | [controller](#controller) | stackato-rest         |
|    TCP*    |  41000-61000 | [controller](#controller) | health manager        |
|    UDP*    |  41000-61000 | [controller](#controller) | harbor                |
\* *If using Harbor only*

---
#### `DEA`
*Group for all Linux DEAs*
##### inbound
|   protocol | port         |   source                  |  *reason*             |
|------------|--------------|---------------------------|-----------------------|
|    TCP     |  9022        | [controller](#controller) | droplets?             |
|    TCP     |  41000-61000 | [router](#router)         | router app access     |
|    UDP*    |  41000-61000 | [router](#router)         | harbor?               |
\* *Possibly just if using harbor*
##### outbound
|   protocol | port    |   destination             |  *reason*             |
|------------|---------|---------------------------|-----------------------|
|    TCP     |  3306   | [mysql](#mysql)           | mysql                 |
|    TCP     |  5432   | [postgreSQL](#postgresql) | postgreSQL            |
|    TCP     |  8181   | [controller](#controller) | droplet upload server |
|    TCP     |  9022   | [controller](#controller) | droplets?             |
---
#### `harbor`
##### inbound
`<NONE>`
##### outbound
`<NONE>`

---
#### `mySQL`
##### inbound
|   protocol | port    |   source                  |  *reason*             |
|------------|---------|---------------------------|-----------------------|
|    TCP     |  3306   | [DEA](#dea)               | droplet?              |
|    TCP     |  3306   | [controller](#controller) | droplet               |
##### outbound
`<NONE>`

---
#### `postgreSQL`
##### inbound
|   protocol | port    |   source                  |  *reason*             |
|------------|---------|---------------------------|-----------------------|
|    TCP     |  5432   | [controller](#controller) | postgreSQL            |
|    TCP     |  5432   | [DEA](#dea)               | postgreSQL            |
##### outbound
`<NONE>`

---
#### `rabbitMQ`
##### inbound
`<NONE>`
##### outbound
`<NONE>`

---
