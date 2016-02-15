variable "amazon_images" {
  description = "Amazon images of Stackato 3.4.1"
  default = {
    us-east-1      = "ami-dea376b6" # Northern Virginia
    us-west-2      = "ami-855922b5" # Oregon
    us-west-1      = "" # Northern California
    eu-west-1      = "ami-fb9b488c" # Ireland
    eu-central-1   = "ami-70eddb6d" # Frankfurt
    ap-southeast-1 = "ami-76bae224" # Singapore
    ap-southeast-2 = "ami-63610759" # Sydney
    ap-northeast-1 = "" # Tokyo
    sa-east-1      = "" # Sao Paulo    }
  }
}

variable "openstack_images" {
  description = "OpenStack images of Stackato 3.4.1"
  default = {
    region-a-geo-1 = "3a28c4f1-c7fc-4440-8d86-e5603a9c1c0f" # US West
    region-b-geo-1 = "49197785-9f34-460a-8b77-a22866d370e2" # US East
  }
}
