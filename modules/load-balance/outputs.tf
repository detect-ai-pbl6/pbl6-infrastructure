output "external_ip" {
  value       = module.gce-lb-http.external_ip
  description = "external ip"
}

