# Configure the VMware vSphere Provider
provider "vsphere" {
  user           = "stefanb"
  password       = "yourpassword"
  vsphere_server = "vcenter.stackato.com"
}

variable vsphere_node_memory {
  description = "Memory for each node type (in MB)"
  default = {
    core = "4096"
    dea = "8192"
    dataservices = "4096"
    controller = "4096"
    router = "4096"
  }
}

variable vsphere_node_cpu {
  description = "Number of CPU for each node type"
  default = {
    core = "2"
    dea = "2"
    dataservices = "2"
    controller = "2"
    router = "2"
  }
}

variable vsphere_node_disk {
  description = "Size of the disk of each node type (in GB)"
  default = {
    core = "30"
    dea = "40"
    dataservices = "40"
    controller = "20"
    router = "20"
  }
}
