# This file setup a Virtual Private Cloud (VPC) for the cluster and expose the
# cluster endpoint to internet

# Create the VPC
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  tags { Name = "vpc-${var.cluster_name}" }
}

# Attach an internet gateway to the VPC
resource "aws_internet_gateway" "gw" {
  depends_on = ["aws_vpc.main"]
  vpc_id = "${aws_vpc.main.id}"
  tags { Name = "gw-cluster-${var.cluster_name}" }
}

# Add a routing table entry to the internet gateway
resource "aws_route" "internet_gw" {
    depends_on = ["aws_vpc.main"]
    route_table_id = "${aws_vpc.main.main_route_table_id}"
    destination_cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.gw.id}"
}

# Add a public subnet into the VPC
resource "aws_subnet" "public" {
    vpc_id = "${aws_vpc.main.id}"
    cidr_block = "10.0.1.0/24"
    map_public_ip_on_launch = true
    tags { Name = "subnet-cluster-${var.cluster_name}-public" }
}

# Add a private subnet into the VPC
resource "aws_subnet" "private" {
    vpc_id = "${aws_vpc.main.id}"
    cidr_block = "10.0.2.0/24"
    tags { Name = "subnet-cluster-${var.cluster_name}-private" }
}
