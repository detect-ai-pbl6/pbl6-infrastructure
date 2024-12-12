
locals {
  name_prefix = "${var.project_name}-${terraform.workspace}"
}
resource "google_compute_subnetwork" "vpc_subnet" {
  name          = "${local.name_prefix}-vpc-cnnt-subnet"
  ip_cidr_range = "10.0.5.0/28"
  network       = var.network_id
  region        = var.region

  private_ip_google_access = true

  lifecycle {
    create_before_destroy = false
  }
}
# VPC Connector
resource "google_vpc_access_connector" "vpc_connector" {
  name = "${local.name_prefix}-vpc-cnnt"
  subnet {
    name = google_compute_subnetwork.vpc_subnet.name
  }
  region = var.region
}


resource "google_service_account" "cloudrun_sa" {
  account_id   = "${local.name_prefix}-cloudrun-sa"
  display_name = "Cloudrun Service Account"
}


# Grant storage roles
resource "google_project_iam_member" "cloudrun_roles" {
  for_each = toset([
    "roles/storage.admin",
    "roles/artifactregistry.reader",
    "roles/artifactregistry.writer",
    "roles/secretmanager.secretAccessor",
    "roles/iam.serviceAccountTokenCreator"
  ])

  project = var.project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.cloudrun_sa.email}"
}


resource "google_cloud_run_v2_service" "service" {
  provider             = google-beta
  name                 = "${local.name_prefix}-cloudrun-backend"
  location             = var.region
  default_uri_disabled = true
  template {

    containers {
      image = "asia-southeast1-docker.pkg.dev/pbl6-439109/pbl6-dev-backend-image-registry/dev-backend-image:latest"
      ports {
        container_port = 80
      }
      dynamic "env" {
        for_each = var.envs_data
        content {
          name = upper(replace(env.key, "-", "_"))
          value_source {
            secret_key_ref {
              secret  = env.value.secret_id
              version = env.value.version
            }
          }
        }
      }
      resources {
        limits = {
          cpu    = "1000m"
          memory = "512Mi"
        }
      }
    }
    service_account = google_service_account.cloudrun_sa.email
    vpc_access {
      connector = google_vpc_access_connector.vpc_connector.id
      egress    = "PRIVATE_RANGES_ONLY"
    }
  }
  ingress      = "INGRESS_TRAFFIC_INTERNAL_LOAD_BALANCER"
  launch_stage = "BETA"

}


data "google_iam_policy" "noauth" {
  binding {
    role = "roles/run.invoker"
    members = [
      "allUsers",
    ]
  }
}

resource "google_cloud_run_service_iam_policy" "noauth" {
  location = google_cloud_run_v2_service.service.location
  project  = google_cloud_run_v2_service.service.project
  service  = google_cloud_run_v2_service.service.name

  policy_data = data.google_iam_policy.noauth.policy_data
}

resource "google_compute_region_network_endpoint_group" "serverless_neg" {
  name                  = "${local.name_prefix}-neg"
  network_endpoint_type = "SERVERLESS"
  region                = var.region

  cloud_run {
    service = google_cloud_run_v2_service.service.name
  }
}

