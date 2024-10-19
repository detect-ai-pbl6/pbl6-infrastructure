# Create a Google Compute Engine instance
resource "google_compute_instance" "e2_micro_instance" {
  name         = "${var.project_name}-${terraform.workspace}-backend-spot"
  machine_type = "e2-micro"
  zone         = var.zone

  # Spot instance configuration
  scheduling {
    preemptible                 = true
    automatic_restart           = false
    provisioning_model          = "SPOT"
    instance_termination_action = "STOP" # or "DELETE" based on your needs
  }

  # Boot disk configuration
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
      type  = "pd-standard" # Use standard persistent disk for cost savings
    }
  }
  network_interface {
    network = "default"

  }

  labels = {
    environment = terraform.workspace
    managed_by  = "terraform"
    type        = "spot"
  }
}

# Firewall rule to allow SSH access
resource "google_compute_firewall" "allow_ssh" {
  name    = "${var.project_name}-${terraform.workspace}-allow-ssh"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"] # Consider restricting this to specific IP ranges
  target_tags   = ["allow-ssh"]
}


module "artifact_registry" {
  source  = "GoogleCloudPlatform/artifact-registry/google"
  version = "~> 0.3"

  project_id    = var.project_id
  location      = var.region
  format        = "DOCKER"
  repository_id = "${var.project_name}-${terraform.workspace}-backend-image-registry"
}

resource "google_compute_network" "vpc_network" {
  project                 = var.project_id
  name                    = "${var.project_name}-${terraform.workspace}-vpc"
  auto_create_subnetworks = true
}

resource "google_storage_bucket" "media_storage" {
  name                     = "${var.project_name}-${terraform.workspace}-${var.bucket_name}"
  force_destroy            = true
  location                 = var.region
  storage_class            = "STANDARD"
  public_access_prevention = "inherited"
  versioning {
    enabled = true
  }
}

resource "google_storage_bucket_iam_member" "member" {
  provider = google
  bucket   = google_storage_bucket.media_storage.name
  role     = "roles/storage.objectViewer"
  member   = "allUsers"
}
