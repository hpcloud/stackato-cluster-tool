# Scenario model:
# http://docs.aws.amazon.com/AmazonVPC/latest/UserGuide/VPC_Appendix_NACLs.html

# Public subnet ACL
resource "aws_network_acl" "public" {
    vpc_id = "${aws_vpc.main.id}"
    subnet_ids = [ "${aws_subnet.public.id}" ]

    ####
    #### TRAFFIC WITH INTERNET
    ####
    # Allows inbound HTTP traffic from anywhere
    ingress {
        protocol = "tcp"
        rule_no = 100
        action = "allow"
        cidr_block =  "0.0.0.0/0"
        from_port = 80
        to_port = 80
    }

    # Allows inbound HTTPS traffic from anywhere
    ingress {
        protocol = "tcp"
        rule_no = 101
        action = "allow"
        cidr_block =  "0.0.0.0/0"
        from_port = 443
        to_port = 443
    }

    # Allows inbound SSH traffic (TODO from your home network)
    # (over the Internet gateway)
    ingress {
        protocol = "tcp"
        rule_no = 102
        action = "allow"
        cidr_block =  "0.0.0.0/0"
        from_port = 22
        to_port = 22
    }

    # Allows inbound return traffic from requests originating in the subnet
    # mostly from apt-get
    ingress {
        protocol = "tcp"
        rule_no = 120
        action = "allow"
        cidr_block =  "0.0.0.0/0"
        from_port = "${var.ephemeral_port_from}"
        to_port = "${var.ephemeral_port_to}"
    }

    # Allow ICMP echo request traffic
    ingress {
        protocol = "icmp"
        rule_no = 130
        action = "allow"
        cidr_block =  "0.0.0.0/0"
        from_port = 0
        to_port = 0
        icmp_type = 8
    }

    # Allows HTTP/HTTPS outbound connections
    # For apt-get update
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

    # Allow SSH connection to the private network
    egress {
        protocol = "tcp"
        rule_no = 102
        action = "allow"
        cidr_block =  "${aws_subnet.private.cidr_block}"
        from_port = 22
        to_port = 22
    }

    # Allow all outbound ephemeral ports because
    # we don't control the ephemeral port range of the client
    egress {
        protocol = "tcp"
        rule_no = 120
        action = "allow"
        cidr_block =  "0.0.0.0/0"
        from_port = 1024
        to_port = 65535
    }

    # Allow ICMP echo reply traffic
    egress {
        protocol = "icmp"
        rule_no = 130
        action = "allow"
        cidr_block =  "0.0.0.0/0"
        from_port = 0
        to_port = 0
        icmp_type = 0
    }

    ####
    #### TRAFFIC WITH PRIVATE SUBNET
    ####
    ## Allow ICMP echo reply traffic from the private subnet
    ingress {
        protocol = -1
        rule_no = 140
        action = "allow"
        cidr_block =  "${aws_subnet.private.cidr_block}"
        from_port = 0
        to_port = 0
    }

    ## Allow ICMP echo request traffic to the private subnet
    egress {
        protocol = -1
        rule_no = 140
        action = "allow"
        cidr_block =  "${aws_subnet.private.cidr_block}"
        from_port = 0
        to_port = 0
    }

    tags { Name = "cluster-${var.cluster_name}-acl-public" }
}

# Private subnet ACL
resource "aws_network_acl" "private" {
    vpc_id = "${aws_vpc.main.id}"
    subnet_ids = [ "${aws_subnet.private.id}" ]

    ####
    #### TRAFFIC WITH INTERNET
    ####
    ## Allows inbound return traffic from NAT instance in
    ## the public subnet for requests originating in the private subnet
    ingress {
        protocol = "tcp"
        rule_no = 100
        action = "allow"
        cidr_block =  "0.0.0.0/0"
        from_port = "${var.ephemeral_port_from}"
        to_port = "${var.ephemeral_port_to}"
    }

    # Allows outbound HTTP traffic from the subnet to the Internet
    egress {
        protocol = "tcp"
        rule_no = 100
        action = "allow"
        cidr_block =  "0.0.0.0/0"
        from_port = 80
        to_port = 80
    }

    # Allows outbound HTTPS traffic from the subnet to the Internet
    egress {
        protocol = "tcp"
        rule_no = 101
        action = "allow"
        cidr_block =  "0.0.0.0/0"
        from_port = 443
        to_port = 443
    }

    # Traffic with the public subnet
    ## Allows inbound SSH traffic from the SSH bastion in the public subnet
    ingress {
        protocol = "tcp"
        rule_no = 150
        action = "allow"
        cidr_block =  "${aws_subnet.public.cidr_block}"
        from_port = 22
        to_port = 22
    }

    ## Allow ALL inbound traffic in the public subnet
    ## TODO: Allow only Stackato opened ports
    ingress {
        protocol = -1
        rule_no = 151
        action = "allow"
        cidr_block =  "${aws_subnet.public.cidr_block}"
        from_port = 0
        to_port = 0
    }

    ## Allow ICMP echo request traffic
    ingress {
        protocol = "icmp"
        rule_no = 152
        action = "allow"
        cidr_block =  "${aws_subnet.public.cidr_block}"
        from_port = 0
        to_port = 0
        icmp_type = 8
    }

    ## Allows outbound responses to the public subnet (for example,
    ## responses to web servers in the public subnet that are communicating
    ## with DB Servers in the private subnet)
    egress {
        protocol = "tcp"
        rule_no = 150
        action = "allow"
        cidr_block =  "${aws_subnet.public.cidr_block}"
        from_port = "${var.ephemeral_port_from}"
        to_port = "${var.ephemeral_port_to}"
    }

    ## Allow ICMP echo reply traffic
    egress {
        protocol = "icmp"
        rule_no = 151
        action = "allow"
        cidr_block =  "${aws_subnet.public.cidr_block}"
        from_port = 0
        to_port = 0
        icmp_type = 0
    }

    ####
    #### TRAFFIC WITH PRIVATE SUBNET
    ####
    ingress {
        protocol = -1
        rule_no = 140
        action = "allow"
        cidr_block =  "${aws_subnet.public.cidr_block}"
        from_port = 0
        to_port = 0
    }

    ## Allow ICMP echo request traffic to the private subnet
    egress {
        protocol = -1
        rule_no = 140
        action = "allow"
        cidr_block =  "${aws_subnet.public.cidr_block}"
        from_port = 0
        to_port = 0
    }

    tags { Name = "cluster-${var.cluster_name}-acl-private" }
}
