# It will generate cloudinit user data for each instance type
# and upload the user data iso file to vSphere datastore 
# location: cluster/${var.cluster_name}-cloudinit

# Configure the VMware vSphere Provider

variable "vsphere_server" {
   description =  "vSphere server to target"
   default     =  "vcenter.stackato.com"
}


provider "vsphere" {
  user           = "stefanb"
  password       = ""
  vsphere_server = "vcenter.yourdomain.com"
}

variable ssh_key_path {
  description = "Path of the private key linked to ssh_key_name (used for uploading scripts)"
  default= "~/.ssh/id_rsa"
}

variable "datacenter" {
   description = "VSphere datacenter to target"
   default = "AS DataCenter"
}

variable "datastore" {
   description = "VSphere datastore to target"
   default = "datastore1 (2)"
}

variable vsphere_node_memory {
  description = "Memory for each node type (in MB)"
  default = {
    core = "4096"
    dea = "8192"
    dataservices = "4096"
    controller = "4096"
    router = "4096"
    proxy = "4096"
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
    proxy = "2"
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
    proxy = "20"
  }
}
