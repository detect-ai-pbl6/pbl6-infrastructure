output "instance_group" {
  value = var.number_instances > 1 ? google_compute_instance_group_manager.group[0].instance_group : ""
}

output "instance_ip" {
  value = var.number_instances == 1 ? google_compute_instance.single_instance[0].network_interface.0.network_ip : "localhost"
}
