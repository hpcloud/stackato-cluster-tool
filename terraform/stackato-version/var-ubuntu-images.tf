variable "amazon_ubuntu_images" {
  description = "Amazon AMIs of Ubuntu 14.04 LTS"
  default = {
    us-east-1	      = "ami-af5a4cc5" # Northern Virginia
    us-west-2	      = "ami-50946030" # Oregon
    us-west-1	      = "ami-8a5529ea" # Northern California
    eu-west-1	      = "ami-6077f713" # Ireland
    eu-central-1	  = "ami-961dfcf9" # Frankfurt
    ap-southeast-1	= "ami-99c114fa" # Singapore
    ap-southeast-2	= "ami-29684a4a" # Sydney
    ap-northeast-1	=	"ami-8ebaaae0" # Tokyo
    sa-east-1	      = "ami-990887f5" # Sao Paulo
  }
}

variable "openstack_ubuntu_images" {
  description = "OpenStack images of Ubuntu 14.04 LTS"
  default = {
    region1        = "3233ef28-deb8-468a-a193-c848d4011d9d"
  }
}
