resource "random_string" "random" {
  count   = var.number_instances
  length  = 8
  special = false
  upper   = false
}
resource "google_compute_instance" "this" {
  #   name         = "${var.project_name}-${terraform.workspace}-backend-spot"
  name         = "${var.instance_name}-${random_string.random[count.index].result}"
  machine_type = "e2-micro"
  zone         = var.zone
  count        = var.number_instances
  # Spot instance configuration
  scheduling {
    preemptible                 = var.is_spot
    automatic_restart           = var.is_spot ? false : true
    provisioning_model          = var.is_spot ? "SPOT" : "STANDARD"
    instance_termination_action = var.is_spot ? "STOP" : null # Use "DELETE" for spot instances if needed
  }

  # Boot disk configuration
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
      type  = "pd-standard"
    }
  }
  network_interface {
    network    = var.network
    subnetwork = var.sub_network
  }

  labels = {
    environment = terraform.workspace
    managed_by  = "terraform"
  }
  tags                    = var.tags
  metadata                = var.metadata
  metadata_startup_script = var.startup_script

  lifecycle {
    create_before_destroy = false
  }
}
