# Add a security group for the Stackato endpoints
resource "aws_security_group" "stackato_endpoints" {
  name = "stackato_endpoints"
  #description = "Allow SSH, HTTP(S) and ephemeral ports for Stackato endpoints"
  description = "Allow ALL"
  vpc_id = "${aws_vpc.main.id}"

  # Allow all ingress traffic
  ingress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all egress traffic
  egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
  }
}

# Add a security group for the Stackato backend
resource "aws_security_group" "stackato_backend" {
  name = "stackato_backend"
  description = "Allow ALL for the Stackato backend"
  vpc_id = "${aws_vpc.main.id}"

  # Allow all ingress traffic
  ingress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all egress traffic
  egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
  }
}

# Security group rules

/*# Allow SSH
resource "aws_security_group_rule" "ssh" {
    type = "ingress"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

    security_group_id = "${aws_security_group.stackato_endpoints.id}"
}

# Allow HTTP
resource "aws_security_group_rule" "http" {
    type = "ingress"
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

    security_group_id = "${aws_security_group.stackato_endpoints.id}"
}

# Allow HTTPS
resource "aws_security_group_rule" "https" {
    type = "ingress"
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

    security_group_id = "${aws_security_group.stackato_endpoints.id}"
}

# Allow return traffic
resource "aws_security_group_rule" "ephemeral_ports" {
    type = "ingress"
    from_port = 49152
    to_port = 65535
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

    security_group_id = "${aws_security_group.stackato_endpoints.id}"
}

# Allow ICMP echo request
resource "aws_security_group_rule" "icmp_echo_request" {
    type = "ingress"
    from_port = 0
    to_port = 0
    protocol = "icmp"
    cidr_blocks = ["0.0.0.0/0"]

    security_group_id = "${aws_security_group.stackato_endpoints.id}"
}*/
