resource "random_id" "instance_suffix" {
  byte_length = 4
  keepers = {
    zone                 = var.zone
    address              = var.address
    startup_script       = local.startup_script
    startup_script_parts = sha256(jsonencode(local.instance_metadata))
    machine_type         = var.machine_type
    disk_size            = var.disk_size
    disk_type            = var.disk_type
  }
}

resource "random_id" "address_suffix" {
  byte_length = 4
  keepers = {
    region = local.region
  }
}

resource "google_compute_address" "address" {
  name         = "nat-instance-${local.region}-${random_id.address_suffix.hex}"
  address_type = "INTERNAL"
  region       = random_id.address_suffix.keepers.region
  # network = var.network
  # subnetwork = var.subnet
  lifecycle {
    create_before_destroy = true
  }
}

resource "google_compute_instance" "instance" {
  name                    = local.instance_name
  zone                    = random_id.instance_suffix.keepers.zone
  can_ip_forward          = true
  machine_type            = random_id.instance_suffix.keepers.machine_type
  metadata_startup_script = random_id.instance_suffix.keepers.startup_script
  metadata                = local.instance_metadata
  tags                    = [local.instance_name, "public-access"]

  boot_disk {
    initialize_params {
      size  = random_id.instance_suffix.keepers.disk_size
      type  = random_id.instance_suffix.keepers.disk_type
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    network    = var.network
    subnetwork = var.subnet
    # network_ip = google_compute_address.address.address
    access_config {
      nat_ip = random_id.instance_suffix.keepers.address
    }
  }
  allow_stopping_for_update = true
}

resource "null_resource" "delay_between_instance_and_route" {
  provisioner "local-exec" {
    command = "sleep ${var.wait_duration}"
  }

  triggers = {
    after = google_compute_instance.instance.id
  }
}

resource "google_compute_route" "route" {
  name                   = google_compute_instance.instance.name
  network                = var.network
  dest_range             = "0.0.0.0/0"
  tags                   = local.network_tags
  priority               = var.route_priority
  next_hop_instance      = google_compute_instance.instance.self_link
  next_hop_instance_zone = google_compute_instance.instance.zone
  depends_on             = [null_resource.delay_between_instance_and_route]
}
