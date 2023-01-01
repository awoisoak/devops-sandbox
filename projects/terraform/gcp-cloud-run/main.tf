locals {
  api_services_list = [
    # "cloudbuild.googleapis.com" #TODO confirm if needed. Maybe no since we are using here the docker registry image, we are not buyilding it
    "run.googleapis.com",
  ]

}

# Enable Service APIs
resource "google_project_service" "api_services" {
  count   = length(local.api_services_list)
  project = var.project_id
  service = local.api_services_list[count.index]

  disable_dependent_services = true
}


resource "google_cloud_run_service" "service" {
  name     = "photo-shop"
  location = var.region

  template {
    spec {
      containers {
        #TODO importing images from Docker Registry is not supported
        # https://cloud.google.com/run/docs/deploying#other-registries
        image = "awoisoak/photo-shop"
      }
    }
  }
  traffic {
    // controls the traffic for this revision
    percent = 100
    // specifies that this traffic configuration needs to be used for the latest revision
    latest_revision = true
  }

  # Waits for the Cloud Run API to be enabled
  # The problem of using api_services_list is how to specify now that we want to wait just for "run.googleapis.com"?
  depends_on = [google_project_service.api_services]
}

# Two ways of allowing unauthenticated users to invoke the service?
# (It's a web server so we reuqire public access)

# iam_policy(Authoritative) vs iam_member(Non-authoritative)
# iam_policy looks complex but much more flexible
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/cloud_run_service_iam

# Option iam_member
resource "google_cloud_run_service_iam_member" "run_all_users" {
  service  = google_cloud_run_service.service.name
  project  = google_cloud_run_service.service.project
  location = google_cloud_run_service.service.location
  role     = "roles/run.invoker"
  member   = "allUsers"
}

# Output the service URL
output "service_url" {
  value = google_cloud_run_service.service.status[0].url

}
