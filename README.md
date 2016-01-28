# stackato-cluster-tool
Terraform a Stackato cluster on Amazon AWS and OpenStack.

##### 1. Install Terraform
https://terraform.io/downloads.html

##### 2. Setup your Stackato cluster with make.sh

Checkout the latest release:
`git checkout v0.4.0`

Print the help of make.sh:
```
On Linux: ./make.sh --help
On Windows: bash -c "./make.sh --help"
```

###### For an Amazon cluster
Create the basic configuration:
```
make.sh -p amazon-aws
cd out
```
Then:
- Choose your cluster configuration in config.tf. The name of the cluster (key cluster_name) will be asked while launching Terraform
- Choose your Amazon configuration in config-amazon.tf, especially aws_access_key and aws_secret_key. Check the Amazon documentation http://docs.aws.amazon.com/AWSSimpleQueueService/latest/SQSGettingStartedGuide/AWSCredentials.html to get those two keys.
- Make sure you uploaded your public SSH key (see doc: http://docs.aws.amazon.com/gettingstarted/latest/wah/getting-started-prereq.html#create-a-key-pair) and update the variable `ssh_key_name` in config-amazon.tf

###### For an OpenStack cluster
Create the basic configuration:
```
make.sh -p openstack
cd out
```
Then:
- Choose your cluster configuration in config.tf. The name of the cluster (key cluster_name) will be asked while launching Terraform
- Choose your OpenStack configuration in config-openstack.tf
- Make sure you uploaded your public SSH key (see doc: http://docs.openstack.org/user-guide/configure_access_and_security_for_instances.html#import-a-key-pair) and update the variable `ssh_key_name` in config-amazon.tf

##### 3. Start the cluster
In a terminal, move to the root directory containing the Terraform files.

Check that the configuration from step 2 is valid by running `terraform plan`.

Start the cluster by running `terraform apply`.

##### 4. Modify a running cluster
You can update the configuration file config.tf then run `terraform plan` and `terraform apply` again.

**/!\ OpenStack: A bug in the Terraform security group plugin prevents Terraform 0.6.9 to update an existing cluster (Terraform delete and recreate an updated security group that is already attached to an instance). The fix of the bug is in progress: https://github.com/hashicorp/terraform/issues/4714**

##### 5. Destroy a cluster
Run the command `terraform destroy` and type 'yes'.
