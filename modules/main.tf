resource "google_service_account" "storage_account" {
  account_id   = "${var.project_name}-${terraform.workspace}-sa-id"
  display_name = "${var.project_name}-${terraform.workspace}-sa"
  description  = "Service Account with full storage access"
}

# Grant storage roles
resource "google_project_iam_member" "storage_roles" {
  for_each = toset([
    "roles/storage.admin",
    "roles/artifactregistry.reader",
    "roles/artifactregistry.writer"
  ])

  project = var.project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.storage_account.email}"
}


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

resource "google_compute_firewall" "allow_all_from_public_subnet_to_private_subnet" {
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

  lifecycle {
    create_before_destroy = false
  }
}

# Firewall rule to allow TCP, UDP, and ICMP from private subnet to public subnet
resource "google_compute_firewall" "allow_all_private_subnet_to_public_subnet" {
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

  lifecycle {
    create_before_destroy = false
  }
}

### NAT INSTANCE #####

# resource "google_compute_firewall" "nat_firewall" {
#   name    = "allow-nat"
#   network = module.vpc.network_name

#   allow {
#     protocol = "tcp"
#     ports    = ["22"] # Allow SSH
#   }

#   allow {
#     protocol = "udp"
#     ports    = ["53"] # Allow DNS
#   }

#   allow {
#     protocol = "tcp"
#     ports    = ["80", "443"] # Allow HTTP/HTTPS
#   }

#   source_ranges = ["0.0.0.0/0"] # Modify for security as needed
# }
# module "backend_instances" {
#   source           = "./vm"
#   number_instances = 1
#   instance_name    = "${var.project_name}-${terraform.workspace}-backend"
#   is_spot          = true
#   zone             = var.zone
#   network          = module.vpc.network_name
#   sub_network      = module.vpc.private_subnet_name
#   tags             = ["allow-ssh", "private-subnet", "private-access", "public-access", "backend-service"]
#   region           = var.region
#   network_id       = module.vpc.network_id
#   project_id       = var.project_id
# }

# resource "google_compute_address" "nat_instance" {
#   name   = "nat-instance"
#   region = var.region
# }

# module "nat_instance" {
#   source         = "./nat-instance"
#   network        = module.vpc.network_name
#   subnet         = module.vpc.public_subnet_name
#   project_name   = var.project_name
#   address        = google_compute_address.nat_instance.address // Required
#   zone           = var.zone                                    // Required
#   disk_type      = "pd-standard"                               // Optional
#   machine_type   = "e2-micro"                                  // Optional
#   route_priority = 900                                         // Optional
# }

# resource "google_compute_route" "private_to_nat" {
#   name        = "${var.project_name}-${terraform.workspace}-private-to-nat"
#   network     = module.vpc.network_name
#   dest_range  = "0.0.0.0/0"
#   priority    = 800
#   tags        = ["private-subnet"]
#   next_hop_ip = module.nat_instance.address

#   depends_on = [
#     module.vpc.private_subnet_name,
#     module.vpc.public_subnet_name
#   ]
# }

resource "google_compute_global_address" "private_ip_address" {
  name          = "private-ip"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = module.vpc.network_name
  project       = var.project_id
}

resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = module.vpc.network_name
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_address.name]
}

module "pg" {
  source  = "terraform-google-modules/sql-db/google//modules/postgresql"
  version = "~> 22.1"

  name                 = "${var.project_name}-${terraform.workspace}-db"
  random_instance_name = true
  project_id           = var.project_id
  database_version     = "POSTGRES_16"
  region               = var.region

  tier                            = var.db_tier
  zone                            = var.zone
  availability_type               = "ZONAL"
  maintenance_window_day          = 7
  maintenance_window_hour         = 12
  maintenance_window_update_track = "stable"

  deletion_protection = false

  database_flags = [{ name = "autovacuum", value = "off" }]

  ip_configuration = {
    ipv4_enabled    = true
    require_ssl     = true
    private_network = "projects/${var.project_id}/global/networks/${module.vpc.network_name}"

    allocated_ip_range = null
  }

  backup_configuration = {
    enabled                        = false
    start_time                     = "20:55"
    location                       = null
    point_in_time_recovery_enabled = false
    transaction_log_retention_days = null
    retained_backups               = 365
    retention_unit                 = "COUNT"
  }


  db_name      = var.db_name
  db_charset   = "UTF8"
  db_collation = "en_US.UTF8"


  user_name     = var.db_user
  user_password = var.db_password

}

module "secrets" {
  source       = "./secret"
  project_name = var.project_name

  database_host     = module.pg.private_ip_address
  database_user     = var.db_user
  database_name     = var.db_name
  database_password = var.db_password

  secret_key = var.secret_key

  bucket_name = module.media_storage.bucket_name
  depends_on  = [module.pg]
}



module "cloudrun_backend" {
  source       = "./cloudrun"
  envs_data    = module.secrets.secrets_data
  project_id   = var.project_id
  project_name = var.project_name
  network_id   = module.vpc.network_id
  region       = var.region

  depends_on = [module.secrets]
}

module "load_balance" {
  source       = "./load-balance"
  project_id   = var.project_id
  project_name = var.project_name
  neg_id       = module.cloudrun_backend.neg_id
  depends_on   = [module.cloudrun_backend]
}

resource "google_service_account" "github_actions" {
  account_id   = "github-actions-sa"
  display_name = "GitHub Actions Service Account"
  description  = "Service Account for GitHub Actions Workload Identity"
  project      = var.project_id
}

# Create Workload Identity Pool
resource "google_iam_workload_identity_pool" "github_pool" {
  workload_identity_pool_id = "github-pool"
  display_name              = "GitHub Actions Pool"
  description               = "Identity pool for GitHub Actions"
}

# Create Workload Identity Pool Provider
resource "google_iam_workload_identity_pool_provider" "github_provider" {
  workload_identity_pool_id          = google_iam_workload_identity_pool.github_pool.workload_identity_pool_id
  workload_identity_pool_provider_id = "github-provider"
  display_name                       = "GitHub Actions Provider"
  description                        = "OIDC identity pool provider for GitHub Actions"

  attribute_mapping = {
    "google.subject"  = "assertion.sub"
    "attribute.actor" = "assertion.actor"
    "attribute.aud"   = "assertion.aud"
    # "attribute.repository" = "assertion.repository"
  }

  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com"
    # allowed_audiences = ["https://github.com/${var.github_repo}"]
  }

  attribute_condition = "assertion.repository_owner=='detect-ai-pbl6'"
}

# IAM binding to allow GitHub to impersonate service account
resource "google_service_account_iam_binding" "workload_identity_binding" {
  service_account_id = google_service_account.github_actions.name
  role               = "roles/iam.workloadIdentityUser"

  members = [
    "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.github_pool.name}/attribute.repository/${var.github_repo}"
  ]
}

# Add IAM roles to the service account
resource "google_project_iam_member" "service_account_roles" {
  for_each = toset(var.service_account_roles)

  project = var.project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.github_actions.email}"
}
