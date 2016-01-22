# Cloudinit user data to set up a Core node
resource "template_file" "core" {
  template = "${file("template-file-cloudinit-core.tpl")}"

  vars {
      cluster_hostname = "${var.cluster_hostname}"
      core_password = "${var.core_password}"
  }
}

# Cloudinit user data to set up DEA nodes
resource "template_file" "dea" {
  template = "${file("template-file-cloudinit-nodes.tpl")}"

  vars {
      core_ip = "${openstack_compute_instance_v2.core.network.0.fixed_ip_v4}"
      core_password = "${var.core_password}"
      roles = "${lookup(var.dea, "roles")}"
      wait_core_timeout = "${var.wait_core_timeout}"
      cluster_hostname = "${var.cluster_hostname}"
  }
}

# Cloudinit user data to set up Dataservices nodes
resource "template_file" "dataservices" {
  template = "${file("template-file-cloudinit-nodes.tpl")}"

  vars {
      core_ip = "${openstack_compute_instance_v2.core.network.0.fixed_ip_v4}"
      core_password = "${var.core_password}"
      roles = "${lookup(var.dataservices, "roles")}"
      wait_core_timeout = "${var.wait_core_timeout}"
      cluster_hostname = "${var.cluster_hostname}"
  }
}
