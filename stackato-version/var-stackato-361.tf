# Amazon AMIs of Stackato 3.6.1
variable "amazon_images" {
  default = {
    us-east-1      = "ami-ab6e13c1" # Northern Virginia
    us-west-2      = "ami-1e16017f" # Oregon
    us-west-1      = "ami-571c7337" # Northern California
    eu-west-1      = "ami-1a2df369" # Ireland
    eu-central-1   = "ami-64081b08" # Frankfurt
    ap-southeast-1 = "ami-5429ee37" # Singapore
    ap-southeast-2 = "ami-85055be6" # Sydney
    sa-east-1      = "ami-388c3754" # Sao Paulo
  }
}

# Azure images
