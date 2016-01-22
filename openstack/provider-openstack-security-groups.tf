resource "openstack_compute_secgroup_v2" "public" {
  name = "${var.cluster_name}-public"
  region = "${var.os_region_name}"
  description = "Stackato endpoints"
  rule {
    from_port = 80
    to_port = 80
    ip_protocol = "tcp"
    cidr = "0.0.0.0/0"
  }
  rule {
    from_port = 443
    to_port = 443
    ip_protocol = "tcp"
    cidr = "0.0.0.0/0"
  }
  rule {
    from_port = 22
    to_port = 22
    ip_protocol = "tcp"
    cidr = "0.0.0.0/0"
  }
  rule {
    from_port = "${var.ephemeral_port_from}"
    to_port = "${var.ephemeral_port_to}"
    ip_protocol = "tcp"
    cidr = "0.0.0.0/0"
  }

  # Intranet
  rule {
    from_port = 1
    to_port = 65535
    ip_protocol = "tcp"
    cidr = "${openstack_networking_subnet_v2.public.cidr}"
  }
  rule {
    from_port = 1
    to_port = 65535
    ip_protocol = "udp"
    cidr = "${openstack_networking_subnet_v2.public.cidr}"
  }
}

resource "openstack_compute_secgroup_v2" "private" {
  name = "${var.cluster_name}-private"
  region = "${var.os_region_name}"
  description = "Stackao backend"
  # Internet
  rule {
    from_port = "${var.ephemeral_port_from}"
    to_port = "${var.ephemeral_port_to}"
    ip_protocol = "tcp"
    cidr = "0.0.0.0/0"
  }
  rule {
    from_port = 80
    to_port = 80
    ip_protocol = "tcp"
    cidr = "0.0.0.0/0"
  }
  rule {
    from_port = 443
    to_port = 443
    ip_protocol = "tcp"
    cidr = "0.0.0.0/0"
  }
  rule {
    from_port = 22
    to_port = 22
    ip_protocol = "tcp"
    cidr = "0.0.0.0/0"
  }

  # Intranet
  rule {
    from_port = 1
    to_port = 65535
    ip_protocol = "tcp"
    cidr = "${openstack_networking_subnet_v2.public.cidr}"
  }
  rule {
    from_port = 1
    to_port = 65535
    ip_protocol = "udp"
    cidr = "${openstack_networking_subnet_v2.public.cidr}"
  }
  rule {
    from_port = -1
    to_port = -1
    ip_protocol = "icmp"
    cidr = "${openstack_networking_subnet_v2.public.cidr}"
  }
}
