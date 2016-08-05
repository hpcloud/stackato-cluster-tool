# Create a virtual machine within the folder
resource "vsphere_virtual_machine" "core" {
  name   = "${var.cluster_name}-core"
  folder = "${var.cluster_name}"
  vcpu   = "${lookup(var.vsphere_core_config, "core")}"
  memory = "${lookup(var.vsphere_node_memory, "core")}"

  network_interface {
    label = "${var.cluster_name}-core"
  }

  disk {
    template = "${lookup(var.vsphere_templates, var.vsphere.vsphere_server)}"
    size = "${lookup(var.vsphere_node_disk, "core")}"
    datastore = "${var.datastore}"
  }

  cdrom {
    datastore = "${var.datastore}"
    path = "${vsphere_file.core_userdata.destination_file}/${var.cluster_name}-${var.userdata_iso_core_dir}.iso"
  }
}


  
