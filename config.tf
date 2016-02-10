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

variable wait_core_timeout {
  description = "Timeout in seconds used by nodes to wait for the core node"
  default = 600
}

variable core_password { # could use a random password when Terraform support it
  description = "Password of the core node"
  default = "stackato"
}

variable core {
  description = "Configuration of the Core node"
  default = {
    "count" = 1
    "roles" = "core,controller"
    "visibility" = "public"
  }
}

variable dea {
  description = "Configuration of the DEA nodes"
  default = {
    "count" = 1
    "roles" = "dea"
    "visibility" = "private"
  }
}

variable dataservices {
  description = "Configuration of the Dataservices nodes"
  default = {
    "count" = 0
    "roles" = "data-services"
    "visibility" = "private"
  }
}

variable controller {
  description = "Configuration of the Cloud Controller nodes"
  default = {
    "count" = 1
    "roles" = "controller"
    "visibility" = "private"
  }
}

# Ephemeral port range of Stackato for the Ingress traffic
# See file /proc/sys/net/ipv4/ip_local_port_range
# Using 65535 to support different version of Stackato based OS
variable ephemeral_port_from { default = 41000 }
variable ephemeral_port_to   { default = 65535 }

variable stackato_automation_path {
  description = "Location of the Stackato automation scripts on the core node"
  default = "/opt/stackato-automation"
}
