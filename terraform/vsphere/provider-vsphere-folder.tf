# Create a folder to contain all the VMs of the cluster
resource "vsphere_folder" "cluster" {
  path   = "${var.cluster_name}"
}
