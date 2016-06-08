# This file is used to abstract provider specific data in order
# to use the same references in other Terraform files

# Dynamic variable about the core node
resource "null_resource" "core" {
  triggers = {
    private_ip = "${element(concat(aws_instance.core.*.private_ip, aws_spot_instance_request.core.*.private_ip), 0)}"
  }
}

# Dynamic variables about the proxy
resource "null_resource" "proxy" {
 triggers = {
   http_proxy      = "${coalesce(lookup(var.proxy, "http_proxy"),      format("http://%s:%s" , element(concat(aws_instance.proxy.*.private_ip, aws_spot_instance_request.proxy.*.private_ip), 0), lookup(var.proxy, "http_proxy_port")))}"
   https_proxy     = "${coalesce(lookup(var.proxy, "https_proxy"),     format("https://%s:%s", element(concat(aws_instance.proxy.*.private_ip, aws_spot_instance_request.proxy.*.private_ip), 0), lookup(var.proxy, "https_proxy_port")))}"
   apt_http_proxy  = "${coalesce(lookup(var.proxy, "apt_http_proxy"),  format("http://%s:%s" , element(concat(aws_instance.proxy.*.private_ip, aws_spot_instance_request.proxy.*.private_ip), 0), lookup(var.proxy, "apt_http_proxy_port")))}"
   apt_https_proxy = "${coalesce(lookup(var.proxy, "apt_https_proxy"), format("https://%s:%s", element(concat(aws_instance.proxy.*.private_ip, aws_spot_instance_request.proxy.*.private_ip), 0), lookup(var.proxy, "apt_https_proxy_port")))}"
 }
}

# Dynamic variables about the provisioner repository
resource "null_resource" "provisioner_repo" {
  triggers = {
    public_ip  = "${element(concat(aws_instance.proxy.*.public_ip,  aws_spot_instance_request.proxy.*.public_ip),  0)}"
    private_ip = "${element(concat(aws_instance.proxy.*.private_ip, aws_spot_instance_request.proxy.*.private_ip), 0)}"
  }
}

# Dynamic variables about the network
resource "null_resource" "network" {
  triggers = {
    cidr_block = "${aws_vpc.main.cidr_block}"
  }
}
