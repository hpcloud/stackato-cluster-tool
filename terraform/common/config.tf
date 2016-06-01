# This file configure the cluster at the  Stackato level.
# The configuration at the providers level is in the file "config-PROVIDER.tf".
#
# cluster_hostname: you can give the domain you want then setup a wildcard
# dns server *.yourdomain.com or add in your host file the following lines:
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

# Note: For Stackato developer, the name has to start with "developer-" in order
# to have the right to upload the Amazon load balancer certificate
variable cluster_name {
  description = "Name of the cluster"
  default = "developer-stefan"
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
  }
}

variable dea {
  description = "Configuration of the DEA nodes"
  default = {
    count = 2
    roles = "dea"
  }
}

variable dataservices {
  description = "Configuration of the Dataservices nodes"
  default = {
    count = 1
    roles = "data-services"
  }
}

variable controller {
  description = "Configuration of the additional Cloud Controller nodes"
  default = {
    count = 1
    roles = "controller"
  }
}

variable router {
  description = "Configuration of the additional Router nodes"
  default = {
    count = 1
    roles = "router"
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
    http_proxy_port      = "8123" # HTTP proxy port to setup on the proxy node
    https_proxy_port     = "8123" # HTTPS proxy port to setup on the proxy node
    apt_http_proxy_port  = "3142" # APT HTTP port to setup on the apt cacher server on the proxy node
    apt_https_proxy_port = "8123" # APT HTTPS port to use. (APT Cacher does not support HTTPS so using the HTTPS proxy one)

    http_upstream_proxy  = "" # If different than empty, the proxy node will connect to it for HTTP/HTTPS requests
    apt_upstream_proxy   = "" # If different than empty, the proxy node will connect to it for APT requests
    http_proxy           = "" # If different than empty, nodes will connect to it for HTTP requests
    https_proxy          = "" # If different than empty, nodes will connect to it for HTTPS requests
    apt_http_proxy       = "" # If different than empty, nodes will connect to it for APT HTTP requests
    apt_https_proxy      = "" # If different than empty, nodes will connect to it for APT HTTPS requests
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
