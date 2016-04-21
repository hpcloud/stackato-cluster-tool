output "web_console_address" {
    value = "http://api.${var.cluster_hostname}"
}

output "ssh_core_ip" {
    value = "${null_resource.core.triggers.private_ip}"
}

output "ssh_core_access" {
  value = "ssh -o ProxyCommand='ssh -W %h:%p ${lookup(var.proxy, "admin_user")}@${null_resource.proxy.triggers.public_ip}' stackato@${null_resource.core.triggers.private_ip}"
}
