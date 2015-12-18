# Cloudinit user data to set up a Core node
resource "template_file" "core" {
  #count = "${lookup(var.dea, "count")}"

  template = "${file("template-file-cloudinit-core.tpl")}"

  vars {
      cluster_hostname = "${var.cluster_hostname}"
  }
}

# Cloudinit user data to set up DEA nodes
resource "template_file" "dea" {
  depends_on = [ "aws_instance.core"]
  #count = "${lookup(var.dea, "count")}"

  template = "${file("template-file-cloudinit-nodes.tpl")}"

  vars {
      core_ip = "${aws_instance.core.private_ip}"
      roles = "${lookup(var.dea, "roles")}"
  }
}

# Cloudinit user data to set up Dataservice nodes
resource "template_file" "dataservice" {
  depends_on = [ "aws_instance.core"]
  #count = "${lookup(var.dataservice, "count")}"

  template = "${file("template-file-cloudinit-nodes.tpl")}"

  vars {
      core_ip = "${aws_instance.core.private_ip}"
      roles = "${lookup(var.dataservice, "roles")}"
  }
}
