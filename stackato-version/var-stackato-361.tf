variable "amazon_images" {
  description = "Amazon AMIs of Stackato 3.6.1"
  default = {
    us-east-1      = "ami-ab6e13c1" # Northern Virginia
    us-west-2      = "ami-1e16017f" # Oregon
    us-west-1      = "ami-571c7337" # Northern California
    eu-west-1      = "ami-1a2df369" # Ireland
    eu-central-1   = "ami-64081b08" # Frankfurt
    ap-southeast-1 = "ami-5429ee37" # Singapore
    ap-southeast-2 = "ami-85055be6" # Sydney
    ap-northeast-1 = "" # Tokyo
    sa-east-1      = "ami-388c3754" # Sao Paulo
  }
}

variable "openstack_images" {
  description = "OpenStack images of Stackato 3.6.1"
  default = {
    region-a.geo-1 = "acd5fc47-d44e-4d25-a4dd-5081dad6364d" # US West
    region-b.geo-1 = "5fa2f882-5d64-46ef-9dcd-91e33f3e7895" # US East
  }
}
