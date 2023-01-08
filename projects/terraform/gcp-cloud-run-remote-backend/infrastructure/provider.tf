terraform {
  # GCS supports by default state locking https://developer.hashicorp.com/terraform/language/settings/backends/gcs
  backend "gcs" {
    bucket = "tf-state-cloud-run-photoshop"
  }
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.47.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}