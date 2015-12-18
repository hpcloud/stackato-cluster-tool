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

# Azure:
