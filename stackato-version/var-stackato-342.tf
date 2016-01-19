variable "amazon_images" {
  description = "Amazon images of Stackato 3.4.2"
  default = {
    us-east-1      = "ami-429dff2a" # Northern Virginia
    us-west-2      = "ami-9b7b2bab" # Oregon
    us-west-1      = "" # Northern California
    eu-west-1      = "ami-221ca555" # Ireland
    eu-central-1   = "ami-74dded69" # Frankfurt
    ap-southeast-1 = "ami-97ffd0c5" # Singapore
    ap-southeast-2 = "ami-d53e55ef" # Sydney
    ap-northeast-1 = "" # Tokyo
    sa-east-1      = "" # Sao Paulo
  }
}

variable "openstack_images" {
  description = "OpenStack images of Stackato 3.4.2"
  default = {
    region-a-geo-1 = "a3fde4e8-3f8e-4077-9f35-647c06ba2470" # US West
    region-b-geo-1 = "f2f83e48-6c52-4734-91ba-d515b77a4b98" # US East
  }
}
