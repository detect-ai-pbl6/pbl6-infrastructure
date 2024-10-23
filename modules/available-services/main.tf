resource "google_project_service" "cloud_functions" {
  project                    = var.project_id
  service                    = "cloudfunctions.googleapis.com"
  disable_dependent_services = true
  disable_on_destroy         = true

}

resource "google_project_service" "pubsub" {
  project                    = var.project_id
  service                    = "pubsub.googleapis.com"
  disable_dependent_services = true
  disable_on_destroy         = true
}

resource "google_project_service" "cloud_scheduler" {
  project                    = var.project_id
  service                    = "cloudscheduler.googleapis.com"
  disable_dependent_services = true
  disable_on_destroy         = true


}

resource "google_project_service" "billing" {
  project                    = var.project_id
  service                    = "cloudbilling.googleapis.com"
  disable_dependent_services = true
  disable_on_destroy         = true


}

resource "google_project_service" "container_registry" {
  project                    = var.project_id
  service                    = "containerregistry.googleapis.com"
  disable_dependent_services = true
  disable_on_destroy         = true

}

resource "google_project_service" "cloud_dns" {
  project                    = var.project_id
  service                    = "dns.googleapis.com"
  disable_dependent_services = true
  disable_on_destroy         = true
}
