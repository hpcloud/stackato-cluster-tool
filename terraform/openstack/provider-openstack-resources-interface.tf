# This file is used to abstract provider specific data in order
# to use the same references in other Terraform files

# Dynamic variable about the core node
resource "null_resource" "core" {
  triggers = {
    private_ip = "${openstack_compute_instance_v2.core.network.0.fixed_ip_v4}"
  }
}

# Dynamic variables about the proxy
resource "null_resource" "proxy" {
 triggers = {
   http_proxy      = "${coalesce(lookup(var.proxy, "http_proxy"),      format("http://%s:%s" , openstack_compute_instance_v2.proxy.network.0.fixed_ip_v4, lookup(var.proxy, "http_proxy_port")))}"
   https_proxy     = "${coalesce(lookup(var.proxy, "https_proxy"),     format("https://%s:%s", openstack_compute_instance_v2.proxy.network.0.fixed_ip_v4, lookup(var.proxy, "https_proxy_port")))}"
   apt_http_proxy  = "${coalesce(lookup(var.proxy, "apt_http_proxy"),  format("http://%s:%s" , openstack_compute_instance_v2.proxy.network.0.fixed_ip_v4, lookup(var.proxy, "apt_http_proxy_port")))}"
   apt_https_proxy = "${coalesce(lookup(var.proxy, "apt_https_proxy"), format("https://%s:%s", openstack_compute_instance_v2.proxy.network.0.fixed_ip_v4, lookup(var.proxy, "apt_https_proxy_port")))}"
 }
}

# Dynamic variables about the provisioner repository
resource "null_resource" "provisioner_repo" {
  triggers = {
    public_ip  = "${openstack_compute_instance_v2.proxy.access_ip_v4}"
    private_ip = "${openstack_compute_instance_v2.proxy.network.0.fixed_ip_v4}"
  }
}

# Dynamic variables about the network
resource "null_resource" "network" {
  triggers = {
    cidr_block = "${openstack_networking_subnet_v2.main.cidr}"
  }
}
