terraform {
  cloud {
    hostname     = "app.terraform.io"
    organization = "awoisoak-devops"
    workspaces {
      name = "gcp-tfc"
    }
  }

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.45.0"
    }
  }
}

provider "google" {
  credentials = var.gcp_credentials
  project     = var.project_id
  region      = var.region
  zone        = var.zone
}