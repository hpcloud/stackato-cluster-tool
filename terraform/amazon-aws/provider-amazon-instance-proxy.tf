resource "aws_instance" "proxy" {
  # Launch the instance after the internet gateway is up
  depends_on = [ "aws_internet_gateway.gw", "aws_vpc.main", "aws_subnet.public" ]
  count = "${lookup(var.proxy, "count")}"
  # Launch the instance
  ami = "${lookup(var.amazon_ubuntu_images, var.region)}"
  instance_type = "${lookup(var.aws_instance_type, "proxy")}"
  key_name = "${var.ssh_key_name}"
  # Give a name to the node
  tags { Name = "${var.cluster_name}-proxy-${format("%03d", count.index + 1)}" }
  # The VPC Subnet ID to launch in and security group
  subnet_id = "${aws_subnet.public.id}"
  vpc_security_group_ids = [ "${aws_security_group.stackato_endpoints.id}" ]
  # Provision the node
  user_data = "${template_file.proxy.rendered}"

  # Setup the provisioner connection with the Core node
  connection {
      user = "${lookup(var.provisioner_repo, "admin_user")}"
      private_key = "${file(var.ssh_key_path)}"
  }

  provisioner "file" {
    source = "stackato-automation"
    destination = "/tmp"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo chown -R ${lookup(var.provisioner_repo, "user")}:${lookup(var.provisioner_repo, "user")} /tmp/stackato-automation",
      "sudo mv /tmp/stackato-automation ${lookup(var.provisioner_repo, "location")}"
    ]
  }
}
