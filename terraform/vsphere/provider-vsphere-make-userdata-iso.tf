# Make the userdata for the proxy node 
variable "userdata_iso_proxy_dir" { default = "userdata-iso-proxy" }

resource "null_resource" "make_userdata_iso_proxy_dir" {
  provisioner "local-exec" {
    command = "mkdir ${var.userdata_iso_proxy_dir}"
  }
}

resource "template_file" "make_userdata_iso_proxy" {
  depends_on = [ "null_resource.userdata_iso_proxy_dir" ]
  gzip          = false
  base64_encode = false

  part {
    filename     = "${var.userdata_iso_proxy_dir}/user-data.txt"
    content_type = "text/part-handler"
    content      = "${template_file.script.rendered}"
  }
}

resource "null_resource" "make_userdata_iso_proxy" {
  depends_on = [ "null_resource.make_userdata_iso_proxy" ]
  provisioner "local-exec" {
    command = "bash -c 'genisoimage -o ${var.cluster_name}-${var.userdata_iso_proxy_dir}.iso -r ${var.userdata_iso_proxy_dir}'"}
}

# resource "null_resource" "make_userdata_iso_core_dir" {
#   provisioner "local-exec" {
#     command = "mkdir userdata-iso-core"
#   }
# }
# 
# resource "null_resource" "make_userdata_iso_dea_dir" {
#   provisioner "local-exec" {
#     command = "mkdir userdata-iso-dea"
#   }
# }
# 
# resource "null_resource" "make_userdata_iso_dataservices_dir" {
#   provisioner "local-exec" {
#     command = "mkdir userdata-iso-dataservices"
#   }
# }
# 
# resource "null_resource" "make_userdata_iso_controller_dir" {
#   provisioner "local-exec" {
#     command = "mkdir userdata-iso-controller"
#   }
# }
# 
# resource "null_resource" "make_userdata_iso_router_3dir" {
#   provisioner "local-exec" {
#     command = "mkdir userdata-iso-router"
#   }
# }

