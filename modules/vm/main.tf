resource "random_string" "random" {
  count   = var.instance_creation_mode == "single" ? 1 : var.min_instances
  length  = 4
  special = false
  upper   = false
  keepers = {
    first = var.force_recreate ? "${timestamp()}" : null
  }
}

resource "google_service_account" "artifact_reader" {
  account_id   = replace("instance_${var.instance_name}_sa", "_", "-")
  display_name = "Service Account for Instance Custom Role"
  project      = var.project_id
}

# Custom role resource remains the same
resource "google_project_iam_custom_role" "artifact_reader_role" {
  role_id     = "instance_${replace(var.instance_name, "-", "_")}_role"
  title       = "Custom Role For VM Instance"
  description = "Custom Role For VM Instance With Necessary Permissions"
  permissions = [
    "artifactregistry.repositories.get",
    "artifactregistry.repositories.list",
    "artifactregistry.repositories.downloadArtifacts",
    "artifactregistry.files.get",
    "artifactregistry.files.list",
    "iap.tunnelInstances.accessViaIAP",
    "iap.tunnelDestGroups.accessViaIAP",
    "storage.folders.get",
    "storage.folders.list",
    "storage.managedFolders.get",
    "storage.managedFolders.list",
    "storage.objects.get",
    "storage.objects.list",
    "secretmanager.secrets.list",
    "secretmanager.versions.access",
    "storage.objects.create",
    "storage.folders.create",
    "storage.managedFolders.create",
    "storage.multipartUploads.create",
    "storage.multipartUploads.abort",
    "storage.multipartUploads.listParts",
    "storage.buckets.get",
    "logging.logEntries.create",
    "logging.logEntries.route"
  ]
  project = var.project_id
}

resource "google_project_iam_member" "artifact_reader_binding" {
  project = var.project_id
  role    = google_project_iam_custom_role.artifact_reader_role.id
  member  = "serviceAccount:${google_service_account.artifact_reader.email}"

}

# Managed Instance Group Template
resource "google_compute_instance_template" "template" {
  count = contains(["managed_group", "mixed"], var.instance_creation_mode) ? 1 : 0

  name         = "${var.instance_name}-template-${random_string.random[0].result}"
  machine_type = "e2-micro"

  disk {
    auto_delete  = true
    boot         = true
    source_image = "debian-cloud/debian-11"
  }

  network_interface {
    network    = var.network
    subnetwork = var.sub_network
  }

  scheduling {
    preemptible                 = var.is_spot
    automatic_restart           = var.is_spot ? false : true
    provisioning_model          = var.is_spot ? "SPOT" : "STANDARD"
    instance_termination_action = var.is_spot ? "STOP" : null
  }

  metadata                = var.metadata
  metadata_startup_script = var.startup_script

  tags = var.tags

  service_account {
    email  = google_service_account.artifact_reader.email
    scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }

  labels = {
    environment = terraform.workspace
    managed_by  = "terraform"
  }

  lifecycle {
    create_before_destroy = false
  }
}

# Managed Instance Group
resource "google_compute_instance_group_manager" "group" {
  count = contains(["managed_group", "mixed"], var.instance_creation_mode) ? 1 : 0

  name               = "${var.instance_name}-group-${random_string.random[0].result}"
  base_instance_name = "${var.instance_name}-${random_string.random[0].result}"
  zone               = var.zone

  version {
    instance_template = google_compute_instance_template.template[0].id
  }

  target_size = var.min_instances

  named_port {
    name = "http"
    port = 80
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Autoscaler
resource "google_compute_autoscaler" "default" {
  count = contains(["managed_group", "mixed"], var.instance_creation_mode) ? 1 : 0

  name   = "${var.instance_name}-autoscaler-${random_string.random[0].result}"
  zone   = var.zone
  target = google_compute_instance_group_manager.group[0].id

  autoscaling_policy {
    max_replicas    = var.min_instances
    min_replicas    = var.min_instances
    cooldown_period = 60
  }
}

# Single Instance
resource "google_compute_instance" "single_instance" {
  count = contains(["single", "mixed"], var.instance_creation_mode) ? 1 : 0

  name                      = "${var.instance_name}-${random_string.random[0].result}"
  machine_type              = "e2-micro"
  zone                      = var.zone
  allow_stopping_for_update = true

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    network    = var.network
    subnetwork = var.sub_network
  }

  scheduling {
    preemptible                 = var.is_spot
    automatic_restart           = var.is_spot ? false : true
    provisioning_model          = var.is_spot ? "SPOT" : "STANDARD"
    instance_termination_action = var.is_spot ? "STOP" : null
  }

  metadata                = var.metadata
  metadata_startup_script = var.startup_script
  tags                    = var.tags

  service_account {
    email  = google_service_account.artifact_reader.email
    scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }

  labels = {
    environment = terraform.workspace
    managed_by  = "terraform"
  }

}
