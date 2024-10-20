resource "random_string" "random" {
  length  = 8
  special = false
  upper   = false
}
module "gce-lb-http" {
  source         = "terraform-google-modules/lb-http/google"
  version        = "11.0.0"
  name           = "${local.lb_name_prefix}-lb"
  project        = var.project_id
  create_address = true
  backends = {
    default = {
      description             = "Default backend group"
      protocol                = "HTTP"
      port                    = 80
      port_name               = "http"
      timeout_sec             = 10
      enable_cdn              = false
      custom_request_headers  = []
      custom_response_headers = []
      security_policy         = null

      connection_draining_timeout_sec = 300
      session_affinity                = "NONE"
      affinity_cookie_ttl_sec         = 0

      health_check = {
        check_interval_sec  = 5
        timeout_sec         = 5
        healthy_threshold   = 2
        unhealthy_threshold = 2
        request_path        = "/"
        port                = 80
        host                = null
        logging             = false
      }

      log_config = {
        enable      = false
        sample_rate = 1.0
      }

      groups = [
        {
          group                        = var.instance_group
          balancing_mode               = "UTILIZATION"
          capacity_scaler              = 1.0
          description                  = "Instance group for backend"
          max_connections              = null
          max_connections_per_instance = null
          max_connections_per_endpoint = null
          max_rate                     = null
          max_rate_per_instance        = null
          max_rate_per_endpoint        = null
          max_utilization              = 0.8
        },
      ]

      iap_config = {
        enable               = false
        oauth2_client_id     = ""
        oauth2_client_secret = ""
      }
    }
  }
}

