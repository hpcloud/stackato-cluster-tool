# This file is a copy of provider-amazon-instances.tf
# with the support for spot instances

resource "aws_spot_instance_request" "core" {
  depends_on = [ "aws_internet_gateway.gw", "aws_vpc.main" ]
  # Amount of nodes
  count = "${lookup(var.spot_instances, "core_count")}"
  # Launch the instance
  ami = "${lookup(var.amazon_images, var.region)}"
  instance_type = "${lookup(var.aws_instance_type, "core")}"
  key_name = "${var.ssh_key_name}"
  # Give a name to the node
  tags { Name = "${var.cluster_name}-spot-core-${format("%03d", count.index + 1)}" }
  # The VPC Subnet ID to launch in
  subnet_id = "${aws_subnet.private.id}"
  vpc_security_group_ids = [ "${aws_security_group.stackato_backend.id}" ]
  # Provision the node
  user_data = "${template_file.core.rendered}"

  spot_price = "${lookup(var.spot_instances, "core_spot_price")}"
  block_duration_minutes = "${lookup(var.spot_instances, "core_block_duration_minutes")}"
  wait_for_fulfillment = "${lookup(var.spot_instances, "core_wait_for_fulfillment")}"
}

resource "aws_spot_instance_request" "dea" {
  # Launch the instance after the VPC and the Core node
  depends_on = [ "aws_internet_gateway.gw", "aws_vpc.main" ]
  # Amount of nodes
  count = "${lookup(var.spot_instances, "dea_count")}"
  # Launch the instance
  ami = "${lookup(var.amazon_images, var.region)}"
  instance_type = "${lookup(var.aws_instance_type, "dea")}"
  key_name = "${var.ssh_key_name}"
  # Give a name to the node
  tags { Name = "${var.cluster_name}-spot-dea-${format("%03d", count.index + 1)}" }
  # The VPC Subnet ID to launch in
  subnet_id = "${aws_subnet.private.id}"
  vpc_security_group_ids = [ "${aws_security_group.stackato_backend.id}" ]
  # Provision the node
  user_data = "${template_file.dea.rendered}"

  spot_price = "${lookup(var.spot_instances, "dea_spot_price")}"
  block_duration_minutes = "${lookup(var.spot_instances, "dea_block_duration_minutes")}"
  wait_for_fulfillment = "${lookup(var.spot_instances, "dea_wait_for_fulfillment")}"
}

resource "aws_spot_instance_request" "dataservices" {
  # Launch the instance after the VPC and the Core node
  depends_on = [ "aws_internet_gateway.gw", "aws_vpc.main" ]
  # Amount of nodes
  count = "${lookup(var.spot_instances, "dataservices_count")}"
  # Launch the instance
  ami = "${lookup(var.amazon_images, var.region)}"
  instance_type = "${lookup(var.aws_instance_type, "dataservices")}"
  key_name = "${var.ssh_key_name}"
  # Give a name to the node
  tags { Name = "${var.cluster_name}-spot-dataservices-${format("%03d", count.index + 1)}" }
  # The VPC Subnet ID to launch in
  subnet_id = "${aws_subnet.private.id}"
  vpc_security_group_ids = [ "${aws_security_group.stackato_backend.id}" ]
  # Provision the node
  user_data = "${template_file.dataservices.rendered}"

  spot_price = "${lookup(var.spot_instances, "dataservices_spot_price")}"
  block_duration_minutes = "${lookup(var.spot_instances, "dataservices_block_duration_minutes")}"
  wait_for_fulfillment = "${lookup(var.spot_instances, "dataservices_wait_for_fulfillment")}"
}

resource "aws_spot_instance_request" "controller" {
  # Launch the instance after the VPC and the Core node
  depends_on = [ "aws_internet_gateway.gw", "aws_vpc.main" ]
  # Amount of nodes
  count = "${lookup(var.spot_instances, "controller_count")}"
  # Launch the instance
  ami = "${lookup(var.amazon_images, var.region)}"
  instance_type = "${lookup(var.aws_instance_type, "controller")}"
  key_name = "${var.ssh_key_name}"
  # Give a name to the node
  tags { Name = "${var.cluster_name}-spot-controller-${format("%03d", count.index + 1)}" }
  # The VPC Subnet ID to launch in
  subnet_id = "${aws_subnet.private.id}"
  vpc_security_group_ids = [ "${aws_security_group.stackato_backend.id}" ]
  # Provision the node
  user_data = "${template_file.controller.rendered}"

  spot_price = "${lookup(var.spot_instances, "controller_spot_price")}"
  block_duration_minutes = "${lookup(var.spot_instances, "controller_block_duration_minutes")}"
  wait_for_fulfillment = "${lookup(var.spot_instances, "controller_wait_for_fulfillment")}"
}

resource "aws_spot_instance_request" "router" {
  # Launch the instance after the VPC and the Core node
  depends_on = [ "aws_internet_gateway.gw", "aws_vpc.main" ]
  # Amount of nodes
  count = "${lookup(var.spot_instances, "router_count")}"
  # Launch the instance
  ami = "${lookup(var.amazon_images, var.region)}"
  instance_type = "${lookup(var.aws_instance_type, "router")}"
  key_name = "${var.ssh_key_name}"
  # Give a name to the node
  tags { Name = "${var.cluster_name}-spot-router-${format("%03d", count.index + 1)}" }
  # The VPC Subnet ID to launch in
  subnet_id = "${aws_subnet.private.id}"
  vpc_security_group_ids = [ "${aws_security_group.stackato_endpoints.id}" ]
  # Provision the node
  user_data = "${template_file.router.rendered}"

  spot_price = "${lookup(var.spot_instances, "router_spot_price")}"
  block_duration_minutes = "${lookup(var.spot_instances, "router_block_duration_minutes")}"
  wait_for_fulfillment = "${lookup(var.spot_instances, "router_wait_for_fulfillment")}"
}
