# Have your Amazon AWS credentials setup first:
# * On Linux:
#     export TF_VAR_aws_access_key=<your AWS access key>
#     export TF_VAR_aws_secret_key=<your AWS secret key>
# * On Windows:
#     set TF_VAR_aws_access_key=<your AWS access key>
#     set TF_VAR_aws_secret_key=<your AWS secret key>
#
# Note: to get your access and secret keys, please check
# http://docs.aws.amazon.com/AWSSimpleQueueService/latest/SQSGettingStartedGuide/AWSCredentials.html
#
# For instance_type, see https://aws.amazon.com/ec2/instance-types/
# For region, see http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-regions-availability-zones.html

/*variable aws_access_key { default = "YOUR_ACCESS_KEY_HERE" }
variable aws_secret_key { default = "YOUR_SECRET_KEY_HERE" }*/

# Configuration of the first node type
variable region {
  description = "Region to deploy each node"
  default = "us-west-2"
}

variable ssh_key_name {
  description = "SSH key name used to connect to instances"
  default = "stefan-win-key"
}

variable aws_instance_type {
  description = "AWS EC2 instance type for each node type"
  default = {
    "core" = "t2.medium"
    "dea" = "t2.medium"
    "dataservices" = "t2.medium"
  }
}
