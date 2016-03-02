resource "aws_iam_server_certificate" "cert" {
  name = "${var.cluster_name}_cert"
  certificate_body = "${file(var.load_balancer.certificate_path)}"
  private_key = "${file(var.load_balancer.private_key_path)}"
}
