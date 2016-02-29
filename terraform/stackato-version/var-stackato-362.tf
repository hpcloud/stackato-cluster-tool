variable "amazon_images" {
  description = "Amazon AMIs of Stackato 3.6.2 RC02"
  default = {
    us-east-1      = "" # Northern Virginia
    us-west-2      = "ami-18c82a78" # Oregon
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
  description = "OpenStack images of Stackato 3.6.2 RC02"
  default = {
    region1        = "e5e45cd2-d4df-460e-a2ea-37bddecf8976" # MPC
  }
}

