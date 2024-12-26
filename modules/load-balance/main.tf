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
  source         = "GoogleCloudPlatform/lb-http/google"
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
      description                     = "Default backend group"
      protocol                        = "HTTP"
      port                            = 80
      port_name                       = "http"
      timeout_sec                     = 60
      enable_cdn                      = false
      custom_request_headers          = []
      custom_response_headers         = []
      security_policy                 = null
      connection_draining_timeout_sec = 300
      session_affinity                = "CLIENT_IP"
      affinity_cookie_ttl_sec         = 0
      health_check = {
        check_interval_sec  = 45
        timeout_sec         = 10
        healthy_threshold   = 2
        unhealthy_threshold = 10
        request_path        = "/api/health"
        port                = 80
        logging             = true
      }
      log_config = {
        enable      = true
        sample_rate = 1.0
      }
      groups = [
        {
          group           = var.instance_group
          balancing_mode  = "UTILIZATION"
          capacity_scaler = 1.0
          description     = "Instance group for backend"
          max_utilization = 0.8
        },
      ]

      iap_config = {
        enable = false
      }
    }
  }

}

