# Configure the AWS Provider
provider "aws" {
    access_key = "${var.aws_access_key}"
    secret_key = "${var.aws_secret_key}"
    region = "${var.region}"
}

resource "aws_instance" "core" {
  # Launch the instance after the internet gateway is up
  depends_on = [ "aws_internet_gateway.gw", "aws_vpc.main", "aws_subnet.public" ]
  # Amount of nodes
  count = "${lookup(var.core, "count")}"
  # Launch the instance
  ami = "${lookup(var.amazon_images, var.region)}"
  instance_type = "${lookup(var.aws_instance_type, "core")}"
  key_name = "${var.ssh_key_name}"
  # Give a name to the node
  tags { Name = "${var.cluster_name}-core-${format("%03d", count.index + 1)}" }
  # The VPC Subnet ID to launch in and security group
  subnet_id = "${aws_subnet.public.id}"
  vpc_security_group_ids = [ "${aws_security_group.stackato_endpoints.id}" ]
  # Provision the node
  # user_data = "PROVISIONER_BIN_URL=${var.provisioner_bin_url}; ROLES=${lookup(var.core, "roles")}; HOSTNAME=${var.cluster_hostname}; PASSWORDLESSSUDO=${lookup(var.core, "passwordlesssudo")}; ${file("provisioner-cloudinit")}"
  user_data = "${template_file.core.rendered}"
}

resource "aws_instance" "dea" {
  # Launch the instance after the VPC and the Core node
  depends_on = [ "aws_internet_gateway.gw", "aws_vpc.main", "aws_subnet.private",
    "aws_instance.core" ]
  # Amount of nodes
  count = "${lookup(var.dea, "count")}"
  # Launch the instance
  ami = "${lookup(var.amazon_images, var.region)}"
  instance_type = "${lookup(var.aws_instance_type, "dea")}"
  key_name = "${var.ssh_key_name}"
  # Give a name to the node
  tags { Name = "${var.cluster_name}-dea-${format("%03d", count.index + 1)}" }
  # The VPC Subnet ID to launch in
  subnet_id = "${aws_subnet.private.id}"
  vpc_security_group_ids = [ "${aws_security_group.stackato_backend.id}" ]
  # Provision the node
  user_data = "${template_file.dea.rendered}"
}

resource "aws_instance" "dataservices" {
  # Launch the instance after the VPC and the Core node
  depends_on = [ "aws_internet_gateway.gw", "aws_vpc.main", "aws_subnet.private",
    "aws_instance.core" ]
  # Amount of nodes
  count = "${lookup(var.dataservices, "count")}"
  # Launch the instance
  ami = "${lookup(var.amazon_images, var.region)}"
  instance_type = "${lookup(var.aws_instance_type, "dataservices")}"
  key_name = "${var.ssh_key_name}"
  # Give a name to the node
  tags { Name = "${var.cluster_name}-dataservices-${format("%03d", count.index + 1)}" }
  # The VPC Subnet ID to launch in
  subnet_id = "${aws_subnet.private.id}"
  vpc_security_group_ids = [ "${aws_security_group.stackato_backend.id}" ]
  # Provision the node
  user_data = "${template_file.dataservices.rendered}"
}
