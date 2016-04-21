# Set a Cloud Init template for each node

# Cloudinit user data to set up the proxy
resource "template_file" "proxy" {
  template = "${file("template-file-cloudinit-proxy.tpl")}"

  vars {
      provisioner_repo_location = "${lookup(var.provisioner_repo, "location")}"
      provisioner_repo_user     = "${lookup(var.provisioner_repo, "user")}"
      provisioner_repo_password = "${lookup(var.provisioner_repo, "password")}"

      http_proxy_port           = "${lookup(var.proxy, "http_proxy_port")}"
      https_proxy_port          = "${lookup(var.proxy, "https_proxy_port")}"
      apt_http_proxy_port       = "${lookup(var.proxy, "apt_http_proxy_port")}"
      apt_https_proxy_port      = "${lookup(var.proxy, "apt_https_proxy_port")}"
      internal_network          = "${null_resource.network.triggers.cidr_block}"

      ephemeral_port_from       = "${var.ephemeral_port_from}"
      ephemeral_port_to         = "${var.ephemeral_port_to}"
  }
}

# Cloudinit user data to set up a Core node
resource "template_file" "core" {
  template = "${file("template-file-cloudinit-nodes.tpl")}"

  vars {
      provisioner_repo_ip       = "${null_resource.proxy.triggers.private_ip}"
      provisioner_repo_user     = "${lookup(var.provisioner_repo, "user")}"
      provisioner_repo_password = "${lookup(var.provisioner_repo, "password")}"
      provisioner_repo_path     = "${lookup(var.provisioner_repo, "location")}"

      use_proxy_opt        = "${replace(lookup(var.proxy, "use_proxy"), "true", "--use-proxy")}"
      http_proxy           = "${null_resource.proxy.triggers.private_ip}"
      http_proxy_port      = "${lookup(var.proxy, "http_proxy_port")}"
      https_proxy_port     = "${lookup(var.proxy, "https_proxy_port")}"
      apt_proxy            = "${null_resource.proxy.triggers.apt_proxy}"
      apt_http_proxy_port  = "${lookup(var.proxy, "apt_http_proxy_port")}"
      apt_https_proxy_port = "${lookup(var.proxy, "apt_https_proxy_port")}"

      core_ip          = "127.0.0.1"
      cluster_hostname = "${var.cluster_hostname}"
      core_password    = "${var.core_password}"
      roles            = "${lookup(var.core, "roles")}"
  }
}

# Cloudinit user data to set up DEA nodes
resource "template_file" "dea" {
  template = "${file("template-file-cloudinit-nodes.tpl")}"

  vars {
      provisioner_repo_ip       = "${null_resource.proxy.triggers.private_ip}"
      provisioner_repo_user     = "${lookup(var.provisioner_repo, "user")}"
      provisioner_repo_password = "${lookup(var.provisioner_repo, "password")}"
      provisioner_repo_path     = "${lookup(var.provisioner_repo, "location")}"

      use_proxy_opt        = "${replace(lookup(var.proxy, "use_proxy"), "true", "--use-proxy")}"
      http_proxy           = "${null_resource.proxy.triggers.private_ip}"
      http_proxy_port      = "${lookup(var.proxy, "http_proxy_port")}"
      https_proxy_port     = "${lookup(var.proxy, "https_proxy_port")}"
      apt_proxy            = "${null_resource.proxy.triggers.apt_proxy}"
      apt_http_proxy_port  = "${lookup(var.proxy, "apt_http_proxy_port")}"
      apt_https_proxy_port = "${lookup(var.proxy, "apt_https_proxy_port")}"

      core_ip          = "${null_resource.core.triggers.private_ip}"
      cluster_hostname = "${var.cluster_hostname}"
      core_password    = "${var.core_password}"
      roles            = "${lookup(var.dea, "roles")}"
  }
}

# Cloudinit user data to set up Dataservices nodes
resource "template_file" "dataservices" {
  template = "${file("template-file-cloudinit-nodes.tpl")}"

  vars {
      provisioner_repo_ip       = "${null_resource.proxy.triggers.private_ip}"
      provisioner_repo_user     = "${lookup(var.provisioner_repo, "user")}"
      provisioner_repo_password = "${lookup(var.provisioner_repo, "password")}"
      provisioner_repo_path     = "${lookup(var.provisioner_repo, "location")}"

      use_proxy_opt        = "${replace(lookup(var.proxy, "use_proxy"), "true", "--use-proxy")}"
      http_proxy           = "${null_resource.proxy.triggers.private_ip}"
      http_proxy_port      = "${lookup(var.proxy, "http_proxy_port")}"
      https_proxy_port     = "${lookup(var.proxy, "https_proxy_port")}"
      apt_proxy            = "${null_resource.proxy.triggers.apt_proxy}"
      apt_http_proxy_port  = "${lookup(var.proxy, "apt_http_proxy_port")}"
      apt_https_proxy_port = "${lookup(var.proxy, "apt_https_proxy_port")}"

      core_ip          = "${null_resource.core.triggers.private_ip}"
      cluster_hostname = "${var.cluster_hostname}"
      core_password    = "${var.core_password}"
      roles            = "${lookup(var.dataservices, "roles")}"
  }
}

# Cloudinit user data to set up Cloud Controller nodes
resource "template_file" "controller" {
  template = "${file("template-file-cloudinit-nodes.tpl")}"

  vars {
      provisioner_repo_ip       = "${null_resource.proxy.triggers.private_ip}"
      provisioner_repo_user     = "${lookup(var.provisioner_repo, "user")}"
      provisioner_repo_password = "${lookup(var.provisioner_repo, "password")}"
      provisioner_repo_path     = "${lookup(var.provisioner_repo, "location")}"

      use_proxy_opt        = "${replace(lookup(var.proxy, "use_proxy"), "true", "--use-proxy")}"
      http_proxy           = "${null_resource.proxy.triggers.private_ip}"
      http_proxy_port      = "${lookup(var.proxy, "http_proxy_port")}"
      https_proxy_port     = "${lookup(var.proxy, "https_proxy_port")}"
      apt_proxy            = "${null_resource.proxy.triggers.apt_proxy}"
      apt_http_proxy_port  = "${lookup(var.proxy, "apt_http_proxy_port")}"
      apt_https_proxy_port = "${lookup(var.proxy, "apt_https_proxy_port")}"

      core_ip          = "${null_resource.core.triggers.private_ip}"
      cluster_hostname = "${var.cluster_hostname}"
      core_password    = "${var.core_password}"
      roles            = "${lookup(var.controller, "roles")}"
  }
}

# Cloudinit user data to set up router nodes
resource "template_file" "router" {
  template = "${file("template-file-cloudinit-nodes.tpl")}"

  vars {
      provisioner_repo_ip       = "${null_resource.proxy.triggers.private_ip}"
      provisioner_repo_user     = "${lookup(var.provisioner_repo, "user")}"
      provisioner_repo_password = "${lookup(var.provisioner_repo, "password")}"
      provisioner_repo_path     = "${lookup(var.provisioner_repo, "location")}"

      use_proxy_opt        = "${replace(lookup(var.proxy, "use_proxy"), "true", "--use-proxy")}"
      http_proxy           = "${null_resource.proxy.triggers.private_ip}"
      http_proxy_port      = "${lookup(var.proxy, "http_proxy_port")}"
      https_proxy_port     = "${lookup(var.proxy, "https_proxy_port")}"
      apt_proxy            = "${null_resource.proxy.triggers.apt_proxy}"
      apt_http_proxy_port  = "${lookup(var.proxy, "apt_http_proxy_port")}"
      apt_https_proxy_port = "${lookup(var.proxy, "apt_https_proxy_port")}"

      core_ip          = "${null_resource.core.triggers.private_ip}"
      cluster_hostname = "${var.cluster_hostname}"
      core_password    = "${var.core_password}"
      roles            = "${lookup(var.router, "roles")}"
  }
}
