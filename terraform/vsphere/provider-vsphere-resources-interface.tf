# This file is used to abstract provider specific data in order
# to use the same references in other Terraform files

resource "null_resource" "core" {
  triggers = {
    private_ip = "${element(vsphere_virtual_machine.core.*.network_interface.ipv4_address, 0)}"
  }
}

resource "null_resource" "proxy" {
  triggers = {
    private_ip = "${element(vsphere_virtual_machine.proxy.*.network_interface.ipv4_address, 0)}"
    public_ip  = "${element(vsphere_virtual_machine.proxy.*.network_interface.ipv4_address, 0)}"
    apt_proxy  = "${element(vsphere_virtual_machine.proxy.*.network_interface.ipv4_address, 0)}"
  }
}

resource "null_resource" "network" {
  triggers = {
    cidr_block = "${aws_vpc.main.cidr_block}"
  }
}
