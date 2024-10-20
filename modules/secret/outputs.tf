output "secrets_data" {
  description = "Map of secret details with their names and versions"
  value = {
    for key, secret in google_secret_manager_secret.secrets : key => {
      id         = secret.id
      name       = secret.name
      secret_id  = secret.secret_id
      version    = google_secret_manager_secret_version.secrets_version[key].version
      version_id = google_secret_manager_secret_version.secrets_version[key].id
    }
  }
  sensitive = true
}
