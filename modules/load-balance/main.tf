resource "random_string" "random" {
  length  = 8
  special = false
  upper   = false
}

module "gce-lb-http" {
  source         = "GoogleCloudPlatform/lb-http/google//modules/serverless_negs"
  version        = "~> 12.0"
  name           = "${local.lb_name_prefix}-lb"
  project        = var.project_id
  create_address = true
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

