terraform {
  backend "local" {}
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.47.0"
    }
    # Needed for the Artifact Registry
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "4.47.0"
    }
  }
}