# # ==================================
# # API Services
# # ==================================
# locals {
#   api_services_list = [
#     "run.googleapis.com", // Cloud Run
#   ]

# }

# # Enable Service APIs
# resource "google_project_service" "api_services" {
#   count   = length(local.api_services_list)
#   project = var.project_id
#   service = local.api_services_list[count.index]

#   disable_dependent_services = true
# }

# # ==================================
# # Services
# # ==================================
# resource "google_cloud_run_service" "service" {
#   name     = "photo-shop"
#   location = var.region

#   template {
#     spec {
#       containers {
#         image = "docker.io/awoisoak/photo-shop:latest"
#         ports {
#           container_port = 9000
#         }
#       }
#     }
#   }
#   traffic {
#     percent = 100
#     latest_revision = true
#   }
#   depends_on = [google_project_service.api_services]
# }


# # ==================================
# # IAM
# # ==================================

# data "google_iam_policy" "noauth" {
#   binding {
#     role = "roles/run.invoker"
#     members = [
#       "allUsers",
#     ]
#   }
# }

# resource "google_cloud_run_service_iam_policy" "noauth" {
#   location = google_cloud_run_service.service.location
#   project  = google_cloud_run_service.service.project
#   service  = google_cloud_run_service.service.name

#   policy_data = data.google_iam_policy.noauth.policy_data
# }

# output "service_url" {
#   value = google_cloud_run_service.service.status[0].url

# }