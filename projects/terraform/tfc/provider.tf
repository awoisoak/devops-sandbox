# ===================
# General
# ===================
terraform {
  cloud {
    organization = "awoisoak-devops"

    workspaces {
      name = "tfc-demo"
    }
  }

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">=4.49.0, <5.0.0"
    }
  }

}

provider "google" {
  project = var.project_id
  region  = var.region
}