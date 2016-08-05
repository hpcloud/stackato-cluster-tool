# for uploading cloud-int user data as an iso image 

resource "vsphere_file" "core_userdata" {
  datacenter             = "${var.datacenter}"
  datastore              = "${var.datastore}"
  source_file            = "${var.cluster_name}-${var.userdata_iso_core_dir}.iso}"
  destination_file       = "/cluster/${var.cluster_name}-cloudinit/"
}

#for uploading proxy user data as an iso image

resource "vsphere_file" "proxy_userdata" {
  datacenter             = "${var.datacenter}"
  datastore              = "${var.datastore}"
  source_file            = "${var.cluster_name}-${var.userdata_iso_proxy_dir}.iso}"
  destination_file       = "/cluster/${var.cluster_name}-cloudinit/"
}
