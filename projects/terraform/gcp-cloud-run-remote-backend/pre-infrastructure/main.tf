# ==================================
# API Services
# ==================================
locals {
  api_services_list = [
    "artifactregistry.googleapis.com",
    "storage.googleapis.com" // Buckets
  ]
}
resource "google_project_service" "api_services" {
  count   = length(local.api_services_list)
  project = var.project_id
  service = local.api_services_list[count.index]

  disable_dependent_services = true
}
# ==================================
# Storage
# ==================================
resource "google_storage_bucket" "default" {
  project = var.project_id
  name    = "tf-state-cloud-run-photoshop"
  # Probably not what we want in a real environment
  force_destroy = true
  location      = var.region

  # Avoid using ACL and handle permissions exclusively through IAM
  uniform_bucket_level_access = true

  versioning {
    enabled = true
  }
  depends_on = [google_project_service.api_services]
}

# ==================================
# Artifact Registry
# ==================================

resource "google_artifact_registry_repository" "my-repo" {
  provider = google-beta

  project       = var.project_id
  location      = var.region
  repository_id = "my-repository"
  description   = "Docker repository within Artifact Registry"
  format        = "DOCKER"

  depends_on = [google_project_service.api_services]
}