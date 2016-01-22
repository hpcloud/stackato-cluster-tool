# Configure the OpenStack Provider
provider "openstack" {
    auth_url  = "${var.os_auth_url}"
    tenant_name = "${var.os_tenant_name}"
    user_name  = "${var.os_username}"
    password  = "${var.os_password}"
}
