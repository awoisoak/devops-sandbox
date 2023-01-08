variable "project_id" {
}

variable "region" {
}

variable "zone" {
}

variable "gcp_credentials" {
  type        = string
  sensitive   = true
  description = "Google Cloud service account credentials"
}