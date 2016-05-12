# This file is used to abstract provider specific data in order
# to use the same references in other Terraform files

resource "null_resource" "core" {
  triggers = {
    private_ip = "${element(concat(openstack_compute_instance_v2.core.*.fixed_ip_v4), 0)}"
  }
}

resource "null_resource" "proxy" {
 triggers = {
   private_ip = "${element(concat(openstack_compute_instance_v2.proxy.*.fixed_ip_v4), 0)}"
   public_ip  = "${element(concat(openstack_compute_instance_v2.proxy.*.floating_ip), 0)}"
   apt_proxy  = "${element(concat(openstack_compute_instance_v2.proxy.*.fixed_ip_v4), 0)}"
 }
}

resource "null_resource" "network" {
  triggers = {
    cidr_block = "${openstack_networking_subnet_v2.public.cidr}"
  }
}
