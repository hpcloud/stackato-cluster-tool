resource "openstack_compute_instance_v2" "core" {
  depends_on = [ "openstack_networking_subnet_v2.public" ]
  region = "${var.os_region_name}"
  # Amount of nodes
  # count = "${lookup(var.core, "count")}"
  # Launch the instance
  # name = "${var.cluster_name}-core-${format("%03d", count.index + 1)}"
  name = "${var.cluster_name}-core"
  image_id = "${lookup(var.openstack_images, var.os_region_name)}"
  flavor_name = "${lookup(var.openstack_flavor_name, "core")}"
  key_pair = "${var.ssh_key_name}"
  security_groups = ["${openstack_compute_secgroup_v2.public.id}"]
  network {
    uuid="${openstack_networking_network_v2.main.id}"
    name="${openstack_networking_network_v2.main.name}"
  }
  # floating_ip = "${element(openstack_compute_floatingip_v2.floatips.*.address, count.index)}"
  floating_ip = "${openstack_compute_floatingip_v2.floatips.address}"
  scheduler_hints { build_near_host_ip="${openstack_networking_subnet_v2.public.cidr}" }
  user_data = "${template_file.core.rendered}"

  # Setup the provisioner connection with the Core node
  connection {
      user = "stackato"
      password = "${var.core_password}"
  }

  # Copies the myapp.conf file to /etc/myapp.conf
  provisioner "file" {
    source = "stackato-automation"
    destination = "/opt/"
  }
}

resource "openstack_compute_instance_v2" "dea" {
  depends_on = [ "openstack_networking_subnet_v2.public" ]
  region = "${var.os_region_name}"
  # Amount of nodes
  count = "${lookup(var.dea, "count")}"
  # Launch the instance
  name = "${var.cluster_name}-dea-${format("%03d", count.index + 1)}"
  image_id = "${lookup(var.openstack_images, var.os_region_name)}"
  flavor_name = "${lookup(var.openstack_flavor_name, "dea")}"
  key_pair = "${var.ssh_key_name}"
  security_groups = ["${openstack_compute_secgroup_v2.private.id}"]
  network {
    uuid="${openstack_networking_network_v2.main.id}"
    name="${openstack_networking_network_v2.main.name}"
  }
  # scheduler_hints { build_near_host_ip="${openstack_networking_subnet_v2.private.cidr}" }
  scheduler_hints { build_near_host_ip="${openstack_networking_subnet_v2.public.cidr}" }
  user_data = "${template_file.dea.rendered}"
}

resource "openstack_compute_instance_v2" "dataservices" {
  depends_on = [ "openstack_networking_subnet_v2.public" ]
  region = "${var.os_region_name}"
  # Amount of nodes
  count = "${lookup(var.dataservices, "count")}"
  # Launch the instance
  name = "${var.cluster_name}-dataservices-${format("%03d", count.index + 1)}"
  image_id = "${lookup(var.openstack_images, var.os_region_name)}"
  flavor_name = "${lookup(var.openstack_flavor_name, "dataservices")}"
  key_pair = "${var.ssh_key_name}"
  security_groups = ["${openstack_compute_secgroup_v2.private.id}"]
  network {
    uuid="${openstack_networking_network_v2.main.id}"
    name="${openstack_networking_network_v2.main.name}"
  }
  # scheduler_hints { build_near_host_ip="${openstack_networking_subnet_v2.private.cidr}" }
  scheduler_hints { build_near_host_ip="${openstack_networking_subnet_v2.public.cidr}" }
  user_data = "${template_file.dataservices.rendered}"
}
