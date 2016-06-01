# This file is used to abstract provider specific data in order
# to use the same references in other Terraform files

# Dynamic variable about the core node
resource "null_resource" "core" {
  triggers = {
    private_ip = "${openstack_compute_instance_v2.core.access_ip_v4}"
  }
}

# Dynamic variables about the proxy
resource "null_resource" "proxy" {
 triggers = {
   http_proxy      = "${coalesce(lookup(var.proxy, "http_proxy"),      openstack_compute_instance_v2.proxy.network.0.fixed_ip_v4)}"
   https_proxy     = "${coalesce(lookup(var.proxy, "https_proxy"),     openstack_compute_instance_v2.proxy.network.0.fixed_ip_v4)}"
   apt_http_proxy  = "${coalesce(lookup(var.proxy, "apt_http_proxy"),  openstack_compute_instance_v2.proxy.network.0.fixed_ip_v4)}"
   apt_https_proxy = "${coalesce(lookup(var.proxy, "apt_https_proxy"), openstack_compute_instance_v2.proxy.network.0.fixed_ip_v4)}"
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
    cidr_block = "${openstack_networking_subnet_v2.public.cidr}"
  }
}
