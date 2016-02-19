variable "amazon_images" {
  description = "Amazon AMIs of Stackato 3.6.2 RC01"
  default = {
    us-east-1      = "" # Northern Virginia
    us-west-2      = "ami-75779415" # Oregon
    us-west-1      = "" # Northern California
    eu-west-1      = "" # Ireland
    eu-central-1   = "" # Frankfurt
    ap-southeast-1 = "" # Singapore
    ap-southeast-2 = "" # Sydney
    ap-northeast-1 = "" # Tokyo
    sa-east-1      = "" # Sao Paulo
  }
}

variable "openstack_images" {
  description = "OpenStack images of Stackato 3.6.2 RC01"
  default = {
    region1        = "c1d79124-4805-404f-adf3-7fd3bb95b4b5" # MPC
  }
}

