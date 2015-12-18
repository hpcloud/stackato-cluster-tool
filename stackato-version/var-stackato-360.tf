variable "amazon_images" {
  description = "Amazon AMIs of Stackato 3.6.0"
  default = {
    us-east-1      = "ami-23628648" # Northern Virginia
    us-west-2      = "ami-a3edd193" # Oregon
    us-west-1      = "ami-fdd43cb9" # Northern California
    eu-west-1      = "ami-dded9caa" # Ireland
    eu-central-1   = "ami-a291afbf" # Frankfurt
    ap-southeast-1 = "ami-0e576f5c" # Singapore
    ap-southeast-2 = "ami-7540394f" # Sydney
    ap-northeast-1 = "ami-227bad22" # Tokyo
    sa-east-1      = "ami-53fe7f4e" # Sao Paulo
  }
}

# Azure images
