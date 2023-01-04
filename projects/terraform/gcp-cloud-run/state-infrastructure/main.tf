# TODO create the Artifact Registry here?
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
}
