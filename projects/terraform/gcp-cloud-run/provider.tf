terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 3.66"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}