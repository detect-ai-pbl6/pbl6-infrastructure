resource "random_string" "random" {
  count   = var.instance_creation_mode == "single" ? 1 : var.min_instances
  length  = 4
  special = false
  upper   = false
  keepers = {
    first              = var.force_recreate ? "${timestamp()}" : null
    startup_script     = var.startup_script
    replace_trigger_by = md5(jsonencode(var.replace_trigger_by))
    machine_type       = var.machine_type
  }
}

resource "google_service_account" "default" {
  account_id   = replace("${var.instance_name}_sa", "_", "-")
  display_name = "Service Account for Instance ${var.instance_name}"
  project      = var.project_id
}

# Custom role resource remains the same
resource "google_project_iam_custom_role" "default" {
  role_id     = "${replace(var.instance_name, "-", "_")}_role"
  title       = "Custom Role For ${var.instance_name}"
  description = "Custom Role For ${var.instance_name} With Necessary Permissions"
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
    "storage.objects.create",
    "storage.folders.create",
    "storage.managedFolders.create",
    "storage.multipartUploads.create",
    "storage.multipartUploads.abort",
    "storage.multipartUploads.listParts",
    "storage.buckets.get",
    "secretmanager.secrets.list",
    "secretmanager.versions.access",
    "logging.logEntries.create",
    "logging.logEntries.route",
    "iam.serviceAccounts.getAccessToken",
    "iam.serviceAccounts.getOpenIdToken",
    "iam.serviceAccounts.signJwt",
    "iam.serviceAccounts.signBlob"
  ]
  project = var.project_id
}

resource "google_project_iam_member" "default" {
  project = var.project_id
  role    = google_project_iam_custom_role.default.id
  member  = "serviceAccount:${google_service_account.default.email}"
}

# Managed Instance Group Template
resource "google_compute_instance_template" "template" {
  count = contains(["managed_group", "mixed"], var.instance_creation_mode) ? 1 : 0

  name         = "${var.instance_name}-template-${random_string.random[0].result}"
  machine_type = var.machine_type

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
    email  = google_service_account.default.email
    scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }

  labels = {
    environment         = terraform.workspace
    managed_by          = "terraform"
    startup_script_hash = md5(var.startup_script)
  }

  lifecycle {
    create_before_destroy = false
  }
}

resource "google_compute_http_health_check" "default" {
  count               = contains(["managed_group", "mixed"], var.instance_creation_mode) ? 1 : 0
  name                = "${var.instance_name}-health-check-${random_string.random[0].result}"
  timeout_sec         = 10
  check_interval_sec  = 30
  healthy_threshold   = 3
  unhealthy_threshold = 10
  port                = 80
  request_path        = var.health_check_request_path
}

# Managed Instance Group
resource "google_compute_instance_group_manager" "group" {
  count = contains(["managed_group", "mixed"], var.instance_creation_mode) ? 1 : 0

  name               = "${var.instance_name}-group-${random_string.random[0].result}"
  base_instance_name = "${var.instance_name}-${random_string.random[0].result}"
  zone               = var.zone

  version {
    instance_template = google_compute_instance_template.template[0].id
    name              = "${var.instance_name}-group-primary"
  }

  target_size = var.min_instances

  named_port {
    name = "http"
    port = 80
  }

  auto_healing_policies {
    health_check      = google_compute_http_health_check.default[0].id
    initial_delay_sec = 60
  }

  lifecycle {
    create_before_destroy = false
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
  machine_type              = var.machine_type
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
    instance_termination_action = var.is_spot ? "DELETE" : null
  }

  metadata                = var.metadata
  metadata_startup_script = var.startup_script
  tags                    = var.tags

  service_account {
    email  = google_service_account.default.email
    scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }

  labels = {
    environment         = terraform.workspace
    managed_by          = "terraform"
    startup_script_hash = md5(var.startup_script)
  }
  lifecycle {
    create_before_destroy = false
  }
}
