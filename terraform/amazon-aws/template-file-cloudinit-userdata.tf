# Cloudinit user data to set up a Core node
resource "template_file" "core" {
  template = "${file("template-file-cloudinit-core.tpl")}"

  vars {
      cluster_hostname = "${var.cluster_hostname}"
      core_password = "${var.core_password}"
      roles = "${lookup(var.core, "roles")}"
      stackato_automation_path = "${var.stackato_automation_path}"
  }
}

# Cloudinit user data to set up DEA nodes
resource "template_file" "dea" {
  depends_on = [ "aws_instance.core"]
  template = "${file("template-file-cloudinit-nodes.tpl")}"

  vars {
      core_ip = "${aws_instance.core.private_ip}"
      core_password = "${var.core_password}"
      roles = "${lookup(var.dea, "roles")}"
      wait_core_timeout = "${var.wait_core_timeout}"
      cluster_hostname = "${var.cluster_hostname}"
      stackato_automation_path = "${var.stackato_automation_path}"
  }
}

# Cloudinit user data to set up Dataservices nodes
resource "template_file" "dataservices" {
  depends_on = [ "aws_instance.core"]
  template = "${file("template-file-cloudinit-nodes.tpl")}"

  vars {
      core_ip = "${aws_instance.core.private_ip}"
      core_password = "${var.core_password}"
      roles = "${lookup(var.dataservices, "roles")}"
      wait_core_timeout = "${var.wait_core_timeout}"
      cluster_hostname = "${var.cluster_hostname}"
      stackato_automation_path = "${var.stackato_automation_path}"
  }
}

# Cloudinit user data to set up Cloud Controller nodes
resource "template_file" "controller" {
  depends_on = [ "aws_instance.core"]
  template = "${file("template-file-cloudinit-nodes.tpl")}"

  vars {
      core_ip = "${aws_instance.core.private_ip}"
      core_password = "${var.core_password}"
      roles = "${lookup(var.controller, "roles")}"
      wait_core_timeout = "${var.wait_core_timeout}"
      cluster_hostname = "${var.cluster_hostname}"
      stackato_automation_path = "${var.stackato_automation_path}"
  }
}

# Cloudinit user data to set up router nodes
resource "template_file" "router" {
  depends_on = [ "aws_instance.core"]
  template = "${file("template-file-cloudinit-nodes.tpl")}"

  vars {
      core_ip = "${aws_instance.core.private_ip}"
      core_password = "${var.core_password}"
      roles = "${lookup(var.router, "roles")}"
      wait_core_timeout = "${var.wait_core_timeout}"
      cluster_hostname = "${var.cluster_hostname}"
      stackato_automation_path = "${var.stackato_automation_path}"
  }
}
