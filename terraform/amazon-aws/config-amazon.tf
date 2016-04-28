# Set your Amazon AWS credentials:
# * Using the variables aws_access_key and aws_secret_key bellow
#
# * Using environment variables:
#   * On Linux:
#       export TF_VAR_aws_access_key=<your AWS access key>
#       export TF_VAR_aws_secret_key=<your AWS secret key>
#   * On Windows:
#       set TF_VAR_aws_access_key=<your AWS access key>
#       set TF_VAR_aws_secret_key=<your AWS secret key>
#
# Note: to get your access and secret keys, please check
# http://docs.aws.amazon.com/AWSSimpleQueueService/latest/SQSGettingStartedGuide/AWSCredentials.html
#
/*variable aws_access_key { default = "YOUR_ACCESS_KEY_HERE" }
variable aws_secret_key { default = "YOUR_SECRET_KEY_HERE" }*/

variable ssh_key_name {
  description = "SSH key name used to connect to instances"
  default = "stefan-win-key"
}

variable ssh_key_path {
  description = "Path of the private key linked to ssh_key_name (used for uploading scripts)"
  default= "~/.ssh/id_rsa"
}

# Spot instances:
# *_count: Number of node to start as spot instances
# *_spot_price: Price you are willing to pay for the instances
# *_block_duration_minutes: Minutes (multiple of 60) to keep the instances up. Set it to 0 to disable.
# *_wait_for_fulfillment: Wait for the Spot Request to be fulfilled (true or false)
#
# Price history:
# http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-spot-instances-history.html
variable spot_instances {
  description = "Configuration of spot instances"
  default = {
    "proxy_count"                         = "0"
    "proxy_spot_price"                    = "0.3"
    "proxy_block_duration_minutes"        = "0"
    "proxy_wait_for_fulfillment"          = "true"

    "core_count"                          = "0"
    "core_spot_price"                     = "0.3"
    "core_block_duration_minutes"         = "0"
    "core_wait_for_fulfillment"           = "true"

    "dea_count"                           = "0"
    "dea_spot_price"                      = "0.3"
    "dea_block_duration_minutes"          = "0"
    "dea_wait_for_fulfillment"            = "false"

    "dataservices_count"                  = "0"
    "dataservices_spot_price"             = "0.3"
    "dataservices_block_duration_minutes" = "0"
    "dataservices_wait_for_fulfillment"   = "false"

    "controller_count"                    = "0"
    "controller_spot_price"               = "0.3"
    "controller_block_duration_minutes"   = "0"
    "controller_wait_for_fulfillment"     = "false"

    "router_count"                        = "0"
    "router_spot_price"                   = "0.3"
    "router_block_duration_minutes"       = "0"
    "router_wait_for_fulfillment"         = "true"
  }
}

# EC2 regions: http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-regions-availability-zones.html
variable region {
  description = "Region to deploy each node"
  default = "us-west-2"
}

# EC2 instance types:  https://aws.amazon.com/ec2/instance-types/
variable aws_instance_type {
  description = "AWS EC2 instance type for each node type"
  default = {
    "core"         = "m3.large"
    "dea"          = "m3.large"
    "dataservices" = "m3.large"
    "controller"   = "m3.large"
    "router"       = "m3.large"
    "proxy"        = "t2.micro"
  }
}
