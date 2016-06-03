resource "openstack_compute_instance_v2" "proxy" {
  # Launch the instance after the subnet is up
  depends_on = [ "openstack_networking_subnet_v2.main" ]
  region = "${var.os_region_name}"
  count = "${lookup(var.proxy, "count")}"

  name = "${var.cluster_name}-proxy"
  image_id = "${lookup(var.openstack_ubuntu_images, var.os_region_name)}"
  flavor_name = "${lookup(var.openstack_flavor_name, "proxy")}"
  key_pair = "${var.ssh_key_name}"
  security_groups = ["${openstack_compute_secgroup_v2.public.id}"]
  network {
    uuid="${openstack_networking_network_v2.main.id}"
    name="${openstack_networking_network_v2.main.name}"
  }
  # floating_ip = "${element(openstack_compute_floatingip_v2.floatips.*.address, count.index)}"
  floating_ip = "${openstack_compute_floatingip_v2.floatips.address}"
  scheduler_hints { build_near_host_ip="${openstack_networking_subnet_v2.main.cidr}" }
  user_data = "${template_file.proxy.rendered}"

  # Setup the provisioner connection with the Core node
  connection {
      user = "${lookup(var.provisioner_repo, "admin_user")}"
      private_key = "${file(var.ssh_key_path)}"
  }

  provisioner "file" {
    source = "stackato-automation"
    destination = "/tmp"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo chown -R ${lookup(var.provisioner_repo, "user")}:${lookup(var.provisioner_repo, "user")} /tmp/stackato-automation",
      "sudo mv /tmp/stackato-automation ${lookup(var.provisioner_repo, "location")}"
    ]
  }
}
