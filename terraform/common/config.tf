# This file configure the cluster at the  Stackato level.
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
  default = "stefan"
}

variable cluster_hostname {
  description = "Cluster hostname (endpoint)"
  default = "stefan.com"
}

variable core_password { # could use a random password when Terraform support it
  description = "Password of the core node"
  default = "stackato"
}

variable core {
  description = "Configuration of the Core node"
  default = {
    count = 1
    roles = "core,controller"
    visibility = "public"
  }
}

variable dea {
  description = "Configuration of the DEA nodes"
  default = {
    count = 3
    roles = "dea"
    visibility = "private"
  }
}

variable dataservices {
  description = "Configuration of the Dataservices nodes"
  default = {
    count = 1
    roles = "data-services"
    visibility = "private"
  }
}

variable controller {
  description = "Configuration of the additional Cloud Controller nodes"
  default = {
    count = 1
    roles = "controller"
    visibility = "private"
  }
}

variable router {
  description = "Configuration of the additional Router nodes"
  default = {
    count = 1
    roles = "router"
    visibility = "public"
  }
}

variable load_balancer {
  description = "Configuration of the load balancer"
  default = {
    certificate_path = "stackato-crt.pem"
    private_key_path = "stackato-key.pem"
  }
}

variable proxy {
  description = "Configuration of the proxy"
  default = {
    admin_user           = "ubuntu"
    count                = 1      # Start a proxy node. Set to 0 to disable
    use_proxy            = "true" # Configure the proxy on Stackato nodes
    http_proxy_port      = "8123"
    https_proxy_port     = "8123"
    apt_http_proxy_port  = "3142"
    apt_https_proxy_port = "8123" # APT Cacher does not support HTTPS
  }
}

variable provisioner_repo {
  description = "Configuration of the provisioner repository"
  default = {
    admin_user = "ubuntu"
    user       = "provisioner"
    password   = "repoaccessibleonlyfromtheinternalnetwork"
    location   = "/opt/stackato-automation"
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
