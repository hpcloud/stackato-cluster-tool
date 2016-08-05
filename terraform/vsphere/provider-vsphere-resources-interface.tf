# This file is used to abstract provider specific data in order
# to use the same references in other Terraform files

resource "null_resource" "core" {
  triggers = {
    private_ip = "${element(vsphere_virtual_machine.core.*.network_interface.ipv4_address, 0)}"
  }
}

#resource "null_resource" "proxy" {
#  triggers = {
#    
#    http_pro = "${element(vsphere_virtual_machine.proxy.*.network_interface.ipv4_address, 0)}"
#    public_ip  = "${element(vsphere_virtual_machine.proxy.*.network_interface.ipv4_address, 0)}"
#    apt_proxy  = "${element(vsphere_virtual_machine.proxy.*.network_interface.ipv4_address, 0)}"
#  }
#}

# Dynamic variables about the proxy
resource "null_resource" "proxy" {
 triggers = {
   http_proxy      = "${coalesce(lookup(var.proxy, "http_proxy"),      format("http://%s:%s" , element(concat(vsphere_virtual_machine.proxy.*.network_interface.ipv4_address), 0), lookup(var.proxy, "http_proxy_port")))}"
   https_proxy     = "${coalesce(lookup(var.proxy, "https_proxy"),     format("https://%s:%s", element(concat(vsphere_virtual_machine.proxy.*.network_interface.ipv4_address), 0), lookup(var.proxy, "https_proxy_port")))}"
   apt_http_proxy  = "${coalesce(lookup(var.proxy, "apt_http_proxy"),  format("http://%s:%s" , element(concat(vsphere_virtual_machine.proxy.*.network_interface.ipv4_address), 0), lookup(var.proxy, "apt_http_proxy_port")))}"
   apt_https_proxy = "${coalesce(lookup(var.proxy, "apt_https_proxy"), format("https://%s:%s", element(concat(vsphere_virtual_machine.proxy.*.network_interface.ipv4_address), 0), lookup(var.proxy, "apt_https_proxy_port")))}"
 }
}
# Dynamic variables about the provisioner repository
resource "null_resource" "provisioner_repo" {
  triggers = {
    public_ip  = "${element(vsphere_virtual_machine.proxy.*.network_interface.ipv4_address, 0)}"
    private_ip = "${element(vsphere_virtual_machine.proxy.*.network_interface.ipv4_address, 0)}"
  }
}

#resource "null_resource" "network" {
#  triggers = {
#    cidr_block = "${aws_vpc.main.cidr_block}"
#  }
#}

