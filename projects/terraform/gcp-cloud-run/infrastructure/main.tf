# ==================================
# API Services
# ==================================
locals {
  api_services_list = [
    # We enable Artifact Registry manually because if added here it will be disabled in 'tf destroy' and then we can't push the image anymore
    # "artifactregistry.googleapis.com",
    "run.googleapis.com",    // Clode Run
    "storage.googleapis.com" // Buckets
  ]

}

# Enable Service APIs
resource "google_project_service" "api_services" {
  count   = length(local.api_services_list)
  project = var.project_id
  service = local.api_services_list[count.index]

  disable_dependent_services = true
}
# ==================================
# Artifact Registry
# ==================================

# Commented since we are creating it manually previously (otherwise we can't manually upload the docker image)
# 
# resource "google_artifact_registry_repository" "my-repo" {
#   provider = google-beta

#   project       = var.project_id
#   location      = var.region
#   repository_id = "my-repository"
#   description   = "Docker repository within Artifact Registry"
#   format        = "DOCKER"

# }

# ==================================
# Services
# ==================================

resource "google_cloud_run_service" "service" {
  name     = "photo-shop"
  location = var.region

  template {
    spec {
      containers {
        image = "us-west1-docker.pkg.dev/cloud-run-photoshop/my-repository/photo-shop"

        # By default Google Cloud Run expects the container to expose the port 8080
        # In this case we need to specify the port exposed by photo-shop container
        ports {
          container_port = 9000
        }
      }
    }
  }
  traffic {
    // controls the traffic for this revision
    percent = 100
    // specifies that this traffic configuration needs to be used for the latest revision
    latest_revision = true
  }

  # Depends on the Cloud Run API to be enabled
  # The problem of using api_services_list is how to specify now that we want to wait just for "run.googleapis.com"?
  depends_on = [google_project_service.api_services]
}


# ==================================
# IAM
# ==================================

# Two ways of allowing unauthenticated users to invoke the service (It's a web server so we require public access):
# - iam_policy(Authoritative) 
# - iam_member (Non-authoritative)
#
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/cloud_run_service_iam
# A) Option IAM Policy
data "google_iam_policy" "noauth" {
  binding {
    role = "roles/run.invoker"
    members = [
      "allUsers",
    ]
  }
}

resource "google_cloud_run_service_iam_policy" "noauth" {
  location = google_cloud_run_service.service.location
  project  = google_cloud_run_service.service.project
  service  = google_cloud_run_service.service.name

  policy_data = data.google_iam_policy.noauth.policy_data
}
# B) Option IAM Member
# resource "google_cloud_run_service_iam_member" "run_all_users" {
#   service  = google_cloud_run_service.service.name
#   project  = google_cloud_run_service.service.project
#   location = google_cloud_run_service.service.location
#   role     = "roles/run.invoker"
#   member   = "allUsers"
# }

# ==================================
# Outputs
# ==================================

output "service_url" {
  value = google_cloud_run_service.service.status[0].url

}
