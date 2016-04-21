# This file is used to abstract provider specific data in order
# to use the same references in other Terraform files

resource "null_resource" "core" {
  triggers = {
    private_ip = "${element(aws_instance.core.*.private_ip, 0)}"
  }
}

resource "null_resource" "proxy" {
  triggers = {
    private_ip = "${element(aws_instance.proxy.*.private_ip, 0)}"
    public_ip  = "${element(aws_instance.proxy.*.public_ip, 0)}"
    apt_proxy  = "${element(aws_instance.proxy.*.private_ip, 0)}"
  }
}

resource "null_resource" "network" {
  triggers = {
    cidr_block = "${aws_vpc.main.cidr_block}"
  }
}
