output "ssh_core_ip" {
    value = "ssh stackato@${aws_instance.core.public_ip}"
}
