output "private_subnet_id" {
  value = google_compute_subnetwork.private_subnet.id
}

output "private_subnet_name" {
  value = google_compute_subnetwork.private_subnet.name
}
output "private_subnet_cidr" {
  value = google_compute_subnetwork.private_subnet.ip_cidr_range
}
output "public_subnet_id" {
  value = google_compute_subnetwork.public_subnet.id
}

output "public_subnet_name" {
  value = google_compute_subnetwork.public_subnet.name
}

output "network_id" {
  value = google_compute_network.vpc_network.id
}

output "self_link" {
  value = google_compute_network.vpc_network.self_link
}

output "network_name" {
  value = google_compute_network.vpc_network.name
}

output "private_network_self_link" {
  value = google_compute_subnetwork.private_subnet.self_link
}
