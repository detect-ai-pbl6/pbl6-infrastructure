output "instance_group" {
  description = "The instance group resource when multiple instances are created"
  value       = var.instance_creation_mode == "managed_group" || var.instance_creation_mode == "mixed" ? try(google_compute_instance_group_manager.group[0].instance_group, null) : null
}

output "instance_ip" {
  description = "Network IP of the single instance or 'localhost' when multiple instances are created"
  value       = (var.instance_count == 1 && var.instance_creation_mode == "single") ? google_compute_instance.single_instance[0].network_interface[0].network_ip : "localhost"
}
