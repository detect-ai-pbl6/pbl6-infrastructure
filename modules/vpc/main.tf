resource "google_compute_network" "vpc_network" {
  project                 = var.project_id
  name                    = "${var.project_name}-${terraform.workspace}-vpc"
  auto_create_subnetworks = false

  lifecycle {
    create_before_destroy = false
  }
}

resource "google_compute_subnetwork" "public_subnet" {
  name          = "${var.project_name}-${terraform.workspace}-vpc-public-subnet"
  network       = google_compute_network.vpc_network.name
  ip_cidr_range = "10.0.1.0/24" # Public subnet CIDR range
  region        = var.region
  depends_on    = [google_compute_network.vpc_network]
}

resource "google_compute_subnetwork" "private_subnet" {
  name                     = "${var.project_name}-${terraform.workspace}-vpc-private-subnet"
  network                  = google_compute_network.vpc_network.name
  ip_cidr_range            = "10.0.2.0/24" # Private subnet CIDR range
  region                   = var.region
  private_ip_google_access = true # Allow private access to GCP services
  depends_on               = [google_compute_network.vpc_network]
}

