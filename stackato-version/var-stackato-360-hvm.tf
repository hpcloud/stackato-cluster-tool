variable "amazon_images" {
  description = "Amazon AMIs of Stackato 3.6.1 HVM"
  default = {
    us-east-1      = "ami-d5926bbe" # Northern Virginia
    us-west-2      = "ami-35515505" # Oregon
    us-west-1      = "ami-b3d522f7" # Northern California
    eu-west-1      = "ami-44da9f33" # Ireland
    eu-central-1   = "ami-3a93ab27" # Frankfurt
    ap-southeast-1 = "ami-e8999dba" # Singapore
    ap-northeast-1 = "ami-6258ff62" # Tokyo
    ap-southeast-2 = "ami-23e09a19" # Sydney
    sa-east-1      = "ami-4b42c056" # Sao Paulo
  }
}

# Azure images
