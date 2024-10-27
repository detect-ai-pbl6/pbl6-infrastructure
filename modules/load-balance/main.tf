resource "random_string" "random" {
  length  = 8
  special = false
  upper   = false
}

resource "google_compute_managed_ssl_certificate" "default" {
  name    = "${local.lb_name_prefix}-cert"
  project = var.project_id

  managed {
    domains = [var.domain_name]
  }
}

module "gce-lb-http" {
  source         = "GoogleCloudPlatform/lb-http/google//modules/serverless_negs"
  version        = "~> 12.0"
  name           = "${local.lb_name_prefix}-lb"
  project        = var.project_id
  create_address = true
  ssl            = true
  https_redirect = true
  ssl_certificates = [
    google_compute_managed_ssl_certificate.default.id
  ]

  backends = {
    default = {
      description = null
      groups = [
        {
          group = var.neg_id
        }
      ]
      enable_cdn = false

      iap_config = {
        enable = false
      }
      log_config = {
        enable = false
      }
    }
  }

}

