resource "aws_elb" "load_balance" {
  name = "${var.cluster_name}"

  listener {
    instance_port = 80
    instance_protocol = "http"
    lb_port = 80
    lb_protocol = "http"
  }

  listener {
    instance_port = 80
    instance_protocol = "http"
    lb_port = 443
    lb_protocol = "https"
    ssl_certificate_id = "${aws_iam_server_certificate.cert.arn}"
  }

  listener {
    instance_port = 22
    instance_protocol = "TCP"
    lb_port = 22
    lb_protocol = "TCP"
  }

  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 2
    timeout = 3
    target = "SSL:443"
    interval = 30
  }

  subnets = [ "${aws_subnet.private.id}" ]
  security_groups = [ "${aws_security_group.stackato_endpoints.id}" ]
  instances = ["${aws_instance.core.*.id}", "${aws_instance.router.*.id}"]
  cross_zone_load_balancing = true
  idle_timeout = 400
  connection_draining = true
  connection_draining_timeout = 400

  tags {
    Name = "${var.cluster_name}-elb"
  }
}

output "aws_load_balancer_dns_name" {
  value = "${aws_elb.load_balance.dns_name}"
}
