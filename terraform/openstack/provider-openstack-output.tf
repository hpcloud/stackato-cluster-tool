output "ssh_core_ip" {
    value = "ssh stackato@${openstack_compute_instance_v2.core.0.floating_ip}"
}
