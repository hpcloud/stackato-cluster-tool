variable "amazon_images" {
  description = "Amazon AMIs of Stackato 3.6.2"
  default = {
    us-east-1      = "ami-cd6759a7" # Northern Virginia
    us-west-2      = "ami-7d5fb21d" # Oregon
    us-west-1      = "ami-ca98e8aa" # Northern California
    eu-west-1      = "ami-3cfa444f" # Ireland
    eu-central-1   = "ami-0637d269" # Frankfurt
    ap-southeast-1 = "ami-ad9e56ce" # Singapore
    ap-southeast-2 = "ami-3686a055" # Sydney
    ap-northeast-1 = "ami-aacbc6c4" # Tokyo
    ap-northeast-2 = "ami-445f912a" # Seoul
    sa-east-1      = "ami-2961e345" # Sao Paulo
  }
}

variable "openstack_images" {
  description = "OpenStack images of Stackato 3.6.2"
  default = {
    region1        = "e5e45cd2-d4df-460e-a2ea-37bddecf8976" # MPC
  }
}
