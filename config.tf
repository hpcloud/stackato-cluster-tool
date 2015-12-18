# This file configure the cluster at the Stackato level.
# The configuration at the providers level are in files "provider-*-config.tf".
#
# cluster_hostname: you can give the domain you want then setup a wildcard
# dns server *.yourdomain.com or add in your host file the following lines
#   ip_of_the_endpoint yourdomain.com
#   ip_of_the_endpoint api.yourdomain.com
#   ip_of_the_endpoint aok.yourdomain.com
#   ip_of_the_endpoint logs.yourdomain.com
#   ip_of_the_endpoint yourappname.yourdomain.com
#
# Keys for node types core, dea and dataservice
#   "count": amount of the node type to deploy
#   "roles": comma-separated list of Stackato roles to assign to the node type
#            (e.g. "dea,data-services")
#   "visibility": "public" to be accessible from internet, or "private"
#   "ssh_key_name": the ssh key name already imported on Amazon AWS
#   "passwordlesssudo": enable sudo without password

variable cluster_name {
  description = "Name of the cluster"
}

variable cluster_hostname {
  description = "Cluster hostname (endpoint)"
  default = "stefan.com"
}

variable provisioner_bin_url {
  description = "URL to download the provisioner"
  default = "https://www.dropbox.com/s/eu29x762ao7o43x/stackato-provisioner"
}

variable core {
  description = "Configuration of the Core node"
  default = {
    "count" = 1
    "roles" = "core"
    "visibility" = "public"
    "ssh_key_name" = "stefan-win-key"
    "passwordlesssudo" = "true"
  }
}

variable dea {
  description = "Configuration of the DEA nodes"
  default = {
    "count" = 2
    "roles" = "dea"
    "visibility" = "private"
    "ssh_key_name" = "stefan-win-key"
    "passwordlesssudo" = "true"
  }
}
