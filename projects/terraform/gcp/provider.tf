terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.45.0"
    }
  }
}

provider "google" {
  credentials = file(var.service_account_key_path)

  project = var.project_id
  region  = var.region
  zone    = var.zone
}