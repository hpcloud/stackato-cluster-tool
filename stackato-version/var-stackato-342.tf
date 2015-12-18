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

# Azure:
