# Cloudinit user data to set up a Core node
resource "template_file" "core" {
  #count = "${lookup(var.dea, "count")}"

  template = "${file("template-file-cloudinit-core.tpl")}"

  vars {
      cluster_hostname = "${var.cluster_hostname}"
      core_password = "${var.core_password}"
  }
}

# Cloudinit user data to set up DEA nodes
resource "template_file" "dea" {
  depends_on = [ "aws_instance.core"]
  #count = "${lookup(var.dea, "count")}"

  template = "${file("template-file-cloudinit-nodes.tpl")}"

  vars {
      core_ip = "${aws_instance.core.private_ip}"
      core_password = "${var.core_password}"
      roles = "${lookup(var.dea, "roles")}"
      wait_core_timeout = "${var.wait_core_timeout}"
      cluster_hostname = "${var.cluster_hostname}"
  }
}

# Cloudinit user data to set up Dataservices nodes
resource "template_file" "dataservices" {
  depends_on = [ "aws_instance.core"]
  #count = "${lookup(var.dea, "count")}"

  template = "${file("template-file-cloudinit-nodes.tpl")}"

  vars {
      core_ip = "${aws_instance.core.private_ip}"
      core_password = "${var.core_password}"
      roles = "${lookup(var.dataservices, "roles")}"
      wait_core_timeout = "${var.wait_core_timeout}"
      cluster_hostname = "${var.cluster_hostname}"
  }
}
