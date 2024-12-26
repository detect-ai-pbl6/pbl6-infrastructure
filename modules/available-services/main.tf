resource "google_project_service" "services" {
  for_each                   = toset(local.enabled_services)
  project                    = var.project_id
  service                    = each.key
  disable_dependent_services = true
  disable_on_destroy         = true
}
