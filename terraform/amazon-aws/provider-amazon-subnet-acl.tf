# Scenario model:
# http://docs.aws.amazon.com/AmazonVPC/latest/UserGuide/VPC_Appendix_NACLs.html

# Public subnet ACL for the proxy
resource "aws_network_acl" "public" {
    depends_on = [ "aws_vpc.main" ]
    vpc_id = "${aws_vpc.main.id}"
    subnet_ids = [ "${aws_subnet.public.id}" ]

    ####
    #### TRAFFIC WITH INTERNET
    ####
    # Allows inbound SSH, ephemeral ports and ping from anywhere
    ingress {
        protocol = "tcp"
        rule_no = 100
        action = "allow"
        cidr_block =  "0.0.0.0/0"
        from_port = 22
        to_port = 22
    }

    ingress {
        protocol = "tcp"
        rule_no = 101
        action = "allow"
        cidr_block =  "0.0.0.0/0"
        from_port = "${var.ephemeral_port_from}"
        to_port = "${var.ephemeral_port_to}"
    }

    ingress {
        protocol = "icmp"
        rule_no = 102
        action = "allow"
        cidr_block =  "0.0.0.0/0"
        from_port = 0
        to_port = 0
        icmp_type = 8
    }

    # Allow inbound traffic on the proxy port from the internal network
    ingress {
        protocol = "tcp"
        rule_no = 200
        action = "allow"
        cidr_block =  "${aws_subnet.private.cidr_block}"
        from_port = "${lookup(var.proxy, "http_proxy_port")}"
        to_port = "${lookup(var.proxy, "http_proxy_port")}"
    }

    ingress {
        protocol = "tcp"
        rule_no = 202
        action = "allow"
        cidr_block =  "${aws_subnet.private.cidr_block}"
        from_port = "${lookup(var.proxy, "apt_http_proxy_port")}"
        to_port = "${lookup(var.proxy, "apt_http_proxy_port")}"
    }


    # Allows HTTP/HTTPS outbound connections for apt-get
    egress {
        protocol = "tcp"
        rule_no = 100
        action = "allow"
        cidr_block =  "0.0.0.0/0"
        from_port = 80
        to_port = 80
    }

    egress {
        protocol = "tcp"
        rule_no = 101
        action = "allow"
        cidr_block =  "0.0.0.0/0"
        from_port = 443
        to_port = 443
    }

    # Allow all outbound ephemeral ports because
    # we don't control the ephemeral port range of the client
    egress {
        protocol = "tcp"
        rule_no = 102
        action = "allow"
        cidr_block =  "0.0.0.0/0"
        from_port = 1024
        to_port = 65535
    }

    # Allow ICMP echo reply traffic
    egress {
        protocol = "icmp"
        rule_no = 103
        action = "allow"
        cidr_block =  "0.0.0.0/0"
        from_port = 0
        to_port = 0
        icmp_type = 0
    }

    # Allow SSH connection to the private network
    egress {
        protocol = "tcp"
        rule_no = 200
        action = "allow"
        cidr_block =  "${aws_subnet.private.cidr_block}"
        from_port = 22
        to_port = 22
    }

    tags { Name = "cluster-${var.cluster_name}-acl-public" }
}

# Private subnet ACL
resource "aws_network_acl" "private" {
    depends_on = [ "aws_vpc.main" ]
    vpc_id = "${aws_vpc.main.id}"
    subnet_ids = [ "${aws_subnet.private.id}" ]

    # Allow inbound HTTP/HTTPS from anywhere
    ingress {
        protocol = "tcp"
        rule_no = 100
        action = "allow"
        cidr_block =  "0.0.0.0/0"
        from_port = 80
        to_port = 80
    }

    ingress {
        protocol = "tcp"
        rule_no = 101
        action = "allow"
        cidr_block =  "0.0.0.0/0"
        from_port = 443
        to_port = 443
    }

    # Allow all inbound from the subnet
    ingress {
        protocol = "-1"
        rule_no = 200
        action = "allow"
        cidr_block =  "${aws_subnet.private.cidr_block}"
        from_port = 0
        to_port = 0
    }

    # Allow inbound SSH, ephemeral ports and ping from the public subnet
    ingress {
        protocol = "tcp"
        rule_no = 300
        action = "allow"
        cidr_block =  "${aws_subnet.public.cidr_block}"
        from_port = "${var.ephemeral_port_from}"
        to_port = "${var.ephemeral_port_to}"
    }

    ingress {
        protocol = "tcp"
        rule_no = 301
        action = "allow"
        cidr_block =  "${aws_subnet.public.cidr_block}"
        from_port = 22
        to_port = 22
    }

    ingress {
        protocol = "icmp"
        rule_no = 302
        action = "allow"
        cidr_block =  "${aws_subnet.public.cidr_block}"
        from_port = 0
        to_port = 0
        icmp_type = 8
    }

    # Allow outbound ephemeral ports to anywhere
    egress {
        protocol = "tcp"
        rule_no = 100
        action = "allow"
        cidr_block =  "0.0.0.0/0"
        from_port = 1024
        to_port = 65535
    }

    ## Allow all traffic within the subnet
    egress {
        protocol = "-1"
        rule_no = 200
        action = "allow"
        cidr_block =  "${aws_subnet.private.cidr_block}"
        from_port = 0
        to_port = 0
    }

    # Allow outbound connection with the proxy and ping reply
    egress {
      protocol = "-1"
      rule_no = 300
      action = "allow"
      cidr_block = "${aws_subnet.public.cidr_block}"
      from_port = 0
      to_port = 0
    }

    egress {
        protocol = "icmp"
        rule_no = 301
        action = "allow"
        cidr_block =  "${aws_subnet.public.cidr_block}"
        from_port = 0
        to_port = 0
        icmp_type = 0
    }

    tags { Name = "cluster-${var.cluster_name}-acl-private" }
}
