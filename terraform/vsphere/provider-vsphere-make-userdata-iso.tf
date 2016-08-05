
# Make the userdata for the core node 
variable "userdata_iso_core_dir" { default = "userdata-iso-core" }

resource "null_resource" "make_userdata_iso_core_dir" {
    provisioner "local-exec" {
    command = "mkdir ${var.userdata_iso_core_dir}"
  }
}

resource "template_file" "make_userdata_iso_core" {
  depends_on = [ "null_resource.make_userdata_iso_core_dir" ]
  gzip          = false
  base64_encode = false

  part {
    filename     = "${var.userdata_iso_core_dir}/user-data.txt"
    content_type = "text/part-handler"
    content      = "${template_file.core.rendered}"
  }
}

resource "null_resource" "make_userdata_iso_core" {
  depends_on = [ "null_resource.make_userdata_iso_core" ]
  provisioner "local-exec" {
    command = "bash -c 'genisoimage -o ${var.cluster_name}-${var.userdata_iso_core_dir}.iso -r ${var.userdata_iso_core_dir}'"
 }
}

#Make user data for the proxy node
variable "userdata_iso_proxy_dir" { default = "userdata-iso-proxy" }

resource "null_resource" "make_userdata_iso_proxy_dir" {
      provisoner "local-exec" {
      command = "mkdir ${var.userdata_iso_proxy_dir}"
      }
}

resource "template_file" "make_userdata_iso_proxy" {
      depend_on = ["null_resource.make_userdata_iso_proxy_dir"]
      gzip = false
      base64_encode = false
      
      part {
       filename     = "${var.userdata_iso_proxy_dir}/user_data_proxy.txt"
       content_type = "text/part-handler"
       content      = "{template_file.proxy.rendered}"
       }
}

resource "null_resource" "make_userdata_iso_proxy" {
  depends_on = [ "null_resource.make_userdata_iso_proxy" ]
  provisioner "local-exec" {
    command = "bash -c 'genisoimage -o ${var.cluster_name}-${var.userdata_iso_proxy_dir}.iso -r ${var.userdata_iso_proxy_dir}'"
    }
}



