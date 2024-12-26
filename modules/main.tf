resource "random_string" "random" {
  length  = 4
  special = false
  upper   = false
}

### Service account for Github Actions ###
resource "google_service_account" "github_action_sa" {
  account_id   = "github-actions-sa"
  display_name = "Service Account for Github Action"
  project      = var.project_id
}

resource "google_project_iam_member" "github_action_sa_role" {
  for_each = toset([
    "roles/artifactregistry.reader",
    "roles/artifactregistry.writer",
    "roles/iam.serviceAccountUser",
    "roles/iam.serviceAccountTokenCreator",
    "roles/compute.instanceAdmin.v1",
    "roles/iap.tunnelResourceAccessor",
    "roles/secretmanager.viewer"
  ])

  project = var.project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.github_action_sa.email}"
}

resource "google_service_account" "github_actions_tf_sa" {
  account_id   = "github-actions-tf-sa"
  display_name = "Service Account for Github Action"
  project      = var.project_id
}

resource "google_project_iam_member" "github_actions_tf_sa_role" {
  for_each = toset([
    "roles/editor",
    "roles/secretmanager.secretAccessor"
  ])

  project = var.project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.github_actions_tf_sa.email}"
}

module "available-services" {
  source     = "./available-services"
  project_id = var.project_id
}

module "images_storage" {
  source               = "./storage"
  bucket_name          = "images-bucket"
  region               = var.region
  project_name         = var.project_name
  allowed_cors_origins = ["*"]

  depends_on = [module.available-services]
}

module "ai_model_storage" {
  source       = "./storage"
  bucket_name  = "ai-model-bucket"
  region       = var.region
  project_name = var.project_name
  versioning   = true

  depends_on = [module.available-services]
}

module "backend_server_image_registry" {
  source  = "GoogleCloudPlatform/artifact-registry/google"
  version = "~> 0.3"

  project_id    = var.project_id
  location      = var.region
  format        = "DOCKER"
  repository_id = "${var.project_name}-${terraform.workspace}-backend-image-registry"

  depends_on = [module.available-services]

}

module "ai_server_image_registry" {
  source  = "GoogleCloudPlatform/artifact-registry/google"
  version = "~> 0.3"

  project_id    = var.project_id
  location      = var.region
  format        = "DOCKER"
  repository_id = "${var.project_name}-${terraform.workspace}-ai-server-image-registry"

  depends_on = [module.available-services]

}

module "vpc" {
  source       = "./vpc"
  region       = var.region
  project_name = var.project_name
  project_id   = var.project_id

  depends_on = [module.available-services]
}

# Allow IAP conenct to resource
resource "google_compute_firewall" "allow_ssh" {
  name        = "${var.project_name}-${terraform.workspace}-allow-ssh"
  network     = module.vpc.network_name
  project     = var.project_id
  description = "Allows TCP connections from IAP to any instance on the network"
  allow {
    protocol = "tcp"
  }

  priority      = 100
  source_ranges = ["35.235.240.0/20"]
}

resource "google_compute_firewall" "allow_health_check" {
  name          = "allow-health-check"
  network       = module.vpc.network_name
  project       = var.project_id
  source_ranges = ["130.211.0.0/22", "35.191.0.0/16"]
  allow {
    protocol = "tcp"
    ports    = [80]
  }
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


### RABBITMQ ####

module "rabbitmq_instance" {
  source        = "./vm"
  instance_name = "${var.project_name}-${terraform.workspace}-rabbitmq"
  machine_type  = "e2-custom-small-1536"
  is_spot       = false
  zone          = var.zone
  network       = module.vpc.network_name
  sub_network   = module.vpc.private_subnet_name
  tags          = ["allow-ssh", "private-subnet", "private-access", "public-access", "backend-service"]
  region        = var.region
  network_id    = module.vpc.network_id
  project_id    = var.project_id
  startup_script = templatefile("${path.module}/scripts/rabbitmq/startup.sh.tpl", {
    RABBITMQ_USERNAME = var.rabbitmq_username,
    RABBITMQ_PASSWORD = var.rabbitmq_password,
    RABBITMQ_VHOST    = var.rabbitmq_vhost
  })

  depends_on = [google_compute_route.private_to_nat, module.available-services]

}

### AI SERVER INSTANCE ###
module "ai_server_instance" {
  source                 = "./vm"
  instance_creation_mode = "managed_group"
  instance_name          = "${var.project_name}-${terraform.workspace}-ai-server"
  is_spot                = false
  machine_type           = "e2-custom-small-2048"
  zone                   = var.zone
  network                = module.vpc.network_name
  sub_network            = module.vpc.private_subnet_name
  tags                   = ["allow-ssh", "private-subnet", "private-access", "public-access", "backend-service"]
  region                 = var.region
  network_id             = module.vpc.network_id
  project_id             = var.project_id
  startup_script = templatefile("${path.module}/scripts/ai-server/startup.sh.tpl", {
    REGION                 = var.region
    NGINX_CONTENT          = base64decode(local.ai_server.nginx_conf_content)
    DOCKER_COMPOSE_CONTENT = local.ai_server.docker_compose_conf_content
    PROJECT_NAME           = var.project_name
    ENVIROMENT             = terraform.workspace
    BUCKET_NAME            = module.ai_model_storage.bucket_name
  })

  depends_on                = [google_compute_route.private_to_nat, module.secrets]
  replace_trigger_by        = module.secrets.secrets_data
  health_check_request_path = "/health"
}


### API SERVER INSTANCE ###

module "backend_instances" {
  source                 = "./vm"
  instance_creation_mode = "managed_group"
  instance_name          = "${var.project_name}-${terraform.workspace}-backend"
  is_spot                = false
  machine_type           = "e2-custom-small-1280"
  zone                   = var.zone
  network                = module.vpc.network_name
  sub_network            = module.vpc.private_subnet_name
  tags                   = ["allow-ssh", "private-subnet", "private-access", "public-access", "backend-service"]
  region                 = var.region
  network_id             = module.vpc.network_id
  project_id             = var.project_id
  startup_script = templatefile("${path.module}/scripts/api-server/startup.sh.tpl", {
    REGION                 = var.region
    DOCKER_COMPOSE_CONTENT = local.api_server.docker_compose_conf_content
    PROJECT_NAME           = var.project_name
    ENVIROMENT             = terraform.workspace
    NGINX_CONTENT          = base64decode(local.api_server.nginx_conf_content)
  })
  replace_trigger_by = module.secrets.secrets_data
  depends_on         = [module.secrets]
}

##### NAT INSTANCE #####
resource "google_compute_address" "nat_instance" {
  name   = "nat-instance"
  region = var.region

  depends_on = [module.available-services]

}

module "nat_instance" {
  source         = "./nat-instance"
  network        = module.vpc.network_name
  subnet         = module.vpc.public_subnet_name
  project_name   = var.project_name
  address        = google_compute_address.nat_instance.address
  zone           = var.zone
  disk_type      = "pd-standard"
  machine_type   = "e2-micro"
  route_priority = 900

  depends_on = [module.available-services]
}

resource "google_compute_route" "private_to_nat" {
  name        = "${var.project_name}-${terraform.workspace}-private-to-nat-${random_string.random.result}"
  network     = module.vpc.network_name
  dest_range  = "0.0.0.0/0"
  priority    = 800
  tags        = ["private-subnet"]
  next_hop_ip = module.nat_instance.address

  depends_on = [
    module.vpc.private_subnet_name,
    module.vpc.public_subnet_name
  ]
  lifecycle {
    create_before_destroy = false
  }
}

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
  deletion_policy         = "ABANDON"

  depends_on = [module.available-services]
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
  edition                         = "ENTERPRISE"

  deletion_protection = false

  database_flags = [{ name = "autovacuum", value = "off" }]

  ip_configuration = {
    ipv4_enabled    = false
    require_ssl     = true
    private_network = "projects/${var.project_id}/global/networks/${module.vpc.network_name}"

    allocated_ip_range = null
  }

  insights_config = {
    query_plans_per_minute = 5
    query_string_length    = 1024
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


module "load_balance" {
  source         = "./load-balance"
  project_id     = var.project_id
  project_name   = var.project_name
  instance_group = module.backend_instances.instance_group
  domain_name    = var.domain_name
  depends_on     = [module.backend_instances]
}



module "dns_public_zone" {
  source  = "terraform-google-modules/cloud-dns/google"
  version = "~> 5.0"

  project_id = var.project_id
  type       = "public"
  name       = "${var.project_name}-${terraform.workspace}-public-dns-zone"
  domain     = "${var.domain_name}."

  enable_logging = true

  recordsets = [
    {
      name    = ""
      type    = "A"
      ttl     = 300
      records = [module.load_balance.external_ip]
    },
    {
      name    = "www"
      type    = "CNAME"
      ttl     = 300
      records = ["www.${var.domain_name}."]
    },
  ]
}

module "secrets" {
  source       = "./secret"
  project_name = var.project_name

  database_host     = module.pg.private_ip_address
  database_user     = var.db_user
  database_name     = var.db_name
  database_password = var.db_password

  secret_key           = var.secret_key
  cors_allowed_origins = var.cors_allowed_origins
  csrf_trusted_origins = var.csrf_trusted_origins
  host                 = "https://${var.domain_name}/"
  private_key          = var.private_key
  public_key           = var.public_key

  gcp_client_id = var.gcp_client_id
  gcp_secret    = var.gcp_secret

  superuser_email    = var.superuser_email
  superuser_password = var.superuser_password

  admin_origin = var.admin_origin
  bucket_name  = module.images_storage.bucket_name

  rabbitmq_host     = module.rabbitmq_instance.instance_ip
  rabbitmq_username = var.rabbitmq_username
  rabbitmq_password = var.rabbitmq_password
  rabbitmq_vhost    = var.rabbitmq_vhost

  github_client_id = var.github_client_id
  github_secret    = var.github_secret

  depends_on = [module.pg, module.available-services]
}
