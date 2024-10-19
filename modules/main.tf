module "media_storage" {
  source       = "./media-storage"
  bucket_name  = var.bucket_name
  region       = var.region
  project_name = var.project_name
}

module "artifact_registry" {
  source  = "GoogleCloudPlatform/artifact-registry/google"
  version = "~> 0.3"

  project_id    = var.project_id
  location      = var.region
  format        = "DOCKER"
  repository_id = "${var.project_name}-${terraform.workspace}-backend-image-registry"
}

module "vpc" {
  source       = "./vpc"
  bucket_name  = var.bucket_name
  region       = var.region
  project_name = var.project_name
  project_id   = var.project_id
}

resource "google_compute_firewall" "allow_ssh" {
  name    = "${var.project_name}-${terraform.workspace}-allow-ssh"
  network = module.vpc.network_name
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["35.235.240.0/20"]
  target_tags   = ["allow-ssh"]
}

resource "google_compute_firewall" "nat_firewall" {
  name    = "allow-nat"
  network = module.vpc.network_name

  allow {
    protocol = "tcp"
    ports    = ["22"] # Allow SSH
  }

  allow {
    protocol = "udp"
    ports    = ["53"] # Allow DNS
  }

  allow {
    protocol = "tcp"
    ports    = ["80", "443"] # Allow HTTP/HTTPS
  }

  source_ranges = ["0.0.0.0/0"] # Modify for security as needed
}
resource "google_compute_firewall" "allow_tcp_udp_icmp_public_to_private" {
  name    = "${var.project_name}-${terraform.workspace}-allow-tcp-udp-icmp-public-to-private"
  network = module.vpc.network_name

  allow {
    protocol = "tcp"
    ports    = ["0-65535"] # Allow all TCP ports
  }

  allow {
    protocol = "udp"
    ports    = ["0-65535"] # Allow all UDP ports
  }

  allow {
    protocol = "icmp" # Allow ICMP
  }

  source_ranges = ["10.0.1.0/24"]    # Public subnet CIDR range
  target_tags   = ["private-access"] # Apply this to instances in the private subnet

  depends_on = [module.vpc.network_name]
}

# Firewall rule to allow TCP, UDP, and ICMP from private subnet to public subnet
resource "google_compute_firewall" "allow_tcp_udp_icmp_private_to_public" {
  name    = "${var.project_name}-${terraform.workspace}-allow-tcp-udp-icmp-private-to-public"
  network = module.vpc.network_name

  allow {
    protocol = "tcp"
    ports    = ["0-65535"] # Allow all TCP ports
  }

  allow {
    protocol = "udp"
    ports    = ["0-65535"] # Allow all UDP ports
  }

  allow {
    protocol = "icmp" # Allow ICMP
  }

  source_ranges = ["10.0.2.0/24"]   # Private subnet CIDR range
  target_tags   = ["public-access"] # Apply this to instances in the public subnet

  depends_on = [module.vpc.network_name]
}
module "backend_instances" {
  source           = "./vm"
  number_instances = 1
  instance_name    = "${var.project_name}-${terraform.workspace}-backend"
  is_spot          = true
  zone             = var.zone
  network          = module.vpc.network_name
  sub_network      = module.vpc.private_subnet_name
  tags             = ["allow-ssh", "private-subnet", "private-access", "public-access"]
  region           = var.region
}

module "database" {
  source           = "./vm"
  number_instances = 1
  instance_name    = "${var.project_name}-${terraform.workspace}-db"
  is_spot          = true
  zone             = var.zone
  network          = module.vpc.network_name
  sub_network      = module.vpc.private_subnet_name
  tags             = ["allow-ssh", "private-subnet", "private-access", "public-access"]
  region           = var.region
  metadata = {
    DB_USER     = "minhngoc"
    DB_PASSWORD = "minhngoc"
    DB_NAME     = "minhngoc"
  }
  startup_script = templatefile("${path.module}/./cloud-init/install_postgres.sh", {
    pg_hba_file = templatefile("${path.module}/./cloud-init/pg_hba.conf", { allowed_ip = "0.0.0.0/0" }),
  })
}

resource "google_compute_address" "nat_instance" {
  name   = "nat-instance"
  region = var.region
}

module "nat_instance" {
  source         = "./nat-instance"
  network        = module.vpc.network_name
  subnet         = module.vpc.public_subnet_name
  address        = google_compute_address.nat_instance.address // Required
  zone           = var.zone                                    // Required
  disk_type      = "pd-standard"                               // Optional
  machine_type   = "e2-micro"                                  // Optional
  route_priority = 900                                         // Optional
}

resource "google_compute_route" "private_to_nat" {
  name        = "${var.project_name}-${terraform.workspace}-private-to-nat"
  network     = module.vpc.network_name
  dest_range  = "0.0.0.0/0"
  priority    = 800
  tags        = ["private-subnet"]
  next_hop_ip = module.nat_instance.address

  depends_on = [
    module.vpc.private_subnet_name,
    module.vpc.public_subnet_name
  ]
}
