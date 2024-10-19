resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Create a local file for the private key
resource "local_sensitive_file" "private_key" {
  content         = tls_private_key.ssh_key.private_key_pem
  filename        = "${path.module}/id_rsa"
  file_permission = "0600"
}

# Create a local file for the public key
resource "local_sensitive_file" "public_key" {
  content         = tls_private_key.ssh_key.public_key_openssh
  filename        = "${path.module}/id_rsa.pub"
  file_permission = "0644"
}

# Create a Google Compute Engine instance
resource "google_compute_instance" "e2_micro_instance" {
  name         = "e2-micro-instance"
  machine_type = "e2-micro"
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    network = "default"

  }

  metadata = {
    ssh-keys = "minhngoc:${tls_private_key.ssh_key.public_key_openssh}"
  }

  tags = ["allow-ssh"]
}

# Firewall rule to allow SSH access
resource "google_compute_firewall" "allow_ssh" {
  name    = "allow-ssh"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["allow-ssh"]
}


module "artifact_registry" {
  source  = "GoogleCloudPlatform/artifact-registry/google"
  version = "~> 0.3"

  project_id    = var.project_id
  location      = var.region
  format        = "DOCKER"
  repository_id = "${terraform.workspace}-backend-image-registry"
}

module "cloud_run" {
  source  = "GoogleCloudPlatform/cloud-run/google"
  version = "~> 0.10.0"

  # Required variables
  service_name = "${terraform.workspace}-backend-service"
  project_id   = var.project_id
  location     = var.region
  image        = "gcr.io/cloudrun/hello"
}

resource "google_compute_network" "vpc_network" {
  project                 = var.project_id
  name                    = "${terraform.workspace}-pbl6-vpc"
  auto_create_subnetworks = true
}

resource "google_storage_bucket" "media_storage" {
  name                     = var.bucket_name
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
