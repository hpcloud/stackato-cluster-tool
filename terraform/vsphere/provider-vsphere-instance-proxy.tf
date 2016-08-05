#create a virtual machine within the folder
resource "vsphere_virtual_machine" "proxy" {
  name   = "${var.cluster_name}-proxy"
  folder = "${var.cluster_name}"
  vcpu   = "${lookup(var.vsphere_node_cpu, "proxy")}"
  memory = "${lookup(var.vsphere_node_memory, "proxy")}"

  network_interface {
    label = "${var.cluster_name}-proxy"
  }

  disk {
    template = "${lookup(var.vsphere_templates, var.vsphere_server)}"
    size = "${lookup(var.vsphere_node_disk, "proxy")}"
    datastore = "${var.datastore}"
  }

  cdrom {
    datastore = "${var.datastore}"
    path = "${vsphere_file.proxy_userdata.destination_file}/${var.cluster_name}-${var.userdata_iso_proxy_dir}.iso"
  }

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

