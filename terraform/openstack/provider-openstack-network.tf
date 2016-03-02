# Create a virtual network to host the cluster
resource "openstack_networking_network_v2" "main" {
  name = "${var.cluster_name}-cluster"
  region = "${var.os_region_name}"
  admin_state_up = "true"
}

# Create a public subnet to host public facing nodes
resource "openstack_networking_subnet_v2" "public" {
  name = "${var.cluster_name}-subnet-public"
  region = "${var.os_region_name}"
  network_id = "${openstack_networking_network_v2.main.id}"
  cidr = "10.0.1.0/24"
  enable_dhcp = true
}

# Create a private subnet to host private hosts
/*resource "openstack_networking_subnet_v2" "private" {
  name = "${var.cluster_name}-subnet-private"
  region = "${var.os_region_name}"
  network_id = "${openstack_networking_network_v2.main.id}"
  cidr = "10.0.2.0/24"
  enable_dhcp = true
}*/

# Create a router to link internet and subnets
resource "openstack_networking_router_v2" "router" {
  name = "${var.cluster_name}-router"
  region = "${var.os_region_name}"
  external_gateway = "${var.external_gateway_uuid}"
  admin_state_up = true
}

# Connect the router to the public subnet
resource "openstack_networking_router_interface_v2" "router_interface_1" {
  region = "${var.os_region_name}"
  router_id = "${openstack_networking_router_v2.router.id}"
  subnet_id = "${openstack_networking_subnet_v2.public.id}"
}

# Create floating IPs for public facing nodes
resource "openstack_compute_floatingip_v2" "floatips" {
  #count = "${lookup(var.core, "count")}"
  region = "${var.os_region_name}"
  pool = "${var.floating_ip_pool_name}"
}

# Create floating IPs for Stackato Routers
resource "openstack_compute_floatingip_v2" "floatips_routers" {
  count = "${lookup(var.router, "count")}"
  region = "${var.os_region_name}"
  pool = "${var.floating_ip_pool_name}"
}
