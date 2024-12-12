<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | n/a |
| <a name="provider_random"></a> [random](#provider\_random) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_ai_model_storage"></a> [ai\_model\_storage](#module\_ai\_model\_storage) | ./storage | n/a |
| <a name="module_ai_server_image_registry"></a> [ai\_server\_image\_registry](#module\_ai\_server\_image\_registry) | GoogleCloudPlatform/artifact-registry/google | ~> 0.3 |
| <a name="module_ai_server_instance"></a> [ai\_server\_instance](#module\_ai\_server\_instance) | ./vm | n/a |
| <a name="module_available-services"></a> [available-services](#module\_available-services) | ./available-services | n/a |
| <a name="module_backend_instances"></a> [backend\_instances](#module\_backend\_instances) | ./vm | n/a |
| <a name="module_backend_server_image_registry"></a> [backend\_server\_image\_registry](#module\_backend\_server\_image\_registry) | GoogleCloudPlatform/artifact-registry/google | ~> 0.3 |
| <a name="module_dns_public_zone"></a> [dns\_public\_zone](#module\_dns\_public\_zone) | terraform-google-modules/cloud-dns/google | ~> 5.0 |
| <a name="module_load_balance"></a> [load\_balance](#module\_load\_balance) | ./load-balance | n/a |
| <a name="module_media_storage"></a> [media\_storage](#module\_media\_storage) | ./storage | n/a |
| <a name="module_nat_instance"></a> [nat\_instance](#module\_nat\_instance) | ./nat-instance | n/a |
| <a name="module_pg"></a> [pg](#module\_pg) | terraform-google-modules/sql-db/google//modules/postgresql | ~> 22.1 |
| <a name="module_rabbitmq_instance"></a> [rabbitmq\_instance](#module\_rabbitmq\_instance) | ./vm | n/a |
| <a name="module_secrets"></a> [secrets](#module\_secrets) | ./secret | n/a |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | ./vpc | n/a |

## Resources

| Name | Type |
|------|------|
| [google_compute_address.nat_instance](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_address) | resource |
| [google_compute_firewall.allow_all_from_public_subnet_to_private_subnet](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) | resource |
| [google_compute_firewall.allow_all_private_subnet_to_public_subnet](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) | resource |
| [google_compute_firewall.allow_health_check](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) | resource |
| [google_compute_firewall.allow_ssh](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) | resource |
| [google_compute_global_address.private_ip_address](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_global_address) | resource |
| [google_compute_route.private_to_nat](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_route) | resource |
| [google_project_iam_member.storage_roles](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_service_account.storage_account](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account) | resource |
| [google_service_networking_connection.private_vpc_connection](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_networking_connection) | resource |
| [random_string.random](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_admin_origin"></a> [admin\_origin](#input\_admin\_origin) | The origin URL for the admin interface. | `string` | n/a | yes |
| <a name="input_cors_allowed_origins"></a> [cors\_allowed\_origins](#input\_cors\_allowed\_origins) | Comma-separated list of origins allowed for Cross-Origin Resource Sharing (CORS). | `string` | n/a | yes |
| <a name="input_csrf_trusted_origins"></a> [csrf\_trusted\_origins](#input\_csrf\_trusted\_origins) | Comma-separated list of origins trusted to bypass CSRF protection. | `string` | n/a | yes |
| <a name="input_db_name"></a> [db\_name](#input\_db\_name) | The name of the database to be created or used. | `string` | n/a | yes |
| <a name="input_db_password"></a> [db\_password](#input\_db\_password) | The password associated with the database user. | `string` | n/a | yes |
| <a name="input_db_tier"></a> [db\_tier](#input\_db\_tier) | The tier of the database instance (e.g., db-f1-micro, db-n1-standard-1). | `string` | n/a | yes |
| <a name="input_db_user"></a> [db\_user](#input\_db\_user) | The username for accessing the database. | `string` | n/a | yes |
| <a name="input_domain_name"></a> [domain\_name](#input\_domain\_name) | The domain name where the application will be hosted. | `string` | n/a | yes |
| <a name="input_gcp_client_id"></a> [gcp\_client\_id](#input\_gcp\_client\_id) | The client ID of the GCP OAuth application. | `string` | n/a | yes |
| <a name="input_gcp_secret"></a> [gcp\_secret](#input\_gcp\_secret) | The secret key of the GCP OAuth application. | `string` | n/a | yes |
| <a name="input_github_client_id"></a> [github\_client\_id](#input\_github\_client\_id) | Client ID for Github OAuth authentication | `string` | n/a | yes |
| <a name="input_github_secret"></a> [github\_secret](#input\_github\_secret) | Client secret for Github OAuth authentication | `string` | n/a | yes |
| <a name="input_private_key"></a> [private\_key](#input\_private\_key) | The private key used for secure communication or encryption. | `string` | n/a | yes |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | The ID of the GCP project where the resources will be created. | `string` | n/a | yes |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | The name of the project. Used for identification purposes in resources and configurations. | `string` | n/a | yes |
| <a name="input_public_key"></a> [public\_key](#input\_public\_key) | The public key used for secure communication or encryption. | `string` | n/a | yes |
| <a name="input_rabbitmq_password"></a> [rabbitmq\_password](#input\_rabbitmq\_password) | The password for RabbitMQ authentication. | `string` | n/a | yes |
| <a name="input_rabbitmq_username"></a> [rabbitmq\_username](#input\_rabbitmq\_username) | The username for RabbitMQ authentication. | `string` | n/a | yes |
| <a name="input_rabbitmq_vhost"></a> [rabbitmq\_vhost](#input\_rabbitmq\_vhost) | The RabbitMQ virtual host to be used for organizing queues and exchanges. | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | The GCP region where the resources will be deployed. | `string` | n/a | yes |
| <a name="input_secret_key"></a> [secret\_key](#input\_secret\_key) | A secret key used for server-side cryptographic operations. | `string` | n/a | yes |
| <a name="input_superuser_email"></a> [superuser\_email](#input\_superuser\_email) | The email address of the superuser account. | `string` | n/a | yes |
| <a name="input_superuser_password"></a> [superuser\_password](#input\_superuser\_password) | The password for the superuser account. | `string` | n/a | yes |
| <a name="input_zone"></a> [zone](#input\_zone) | The specific zone within the selected GCP region for resource deployment. | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->