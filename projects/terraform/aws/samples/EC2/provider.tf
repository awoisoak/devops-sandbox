terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.15.0"
    }
  }
}
provider "aws" {
  region                      = var.region
  skip_credentials_validation = true
  skip_requesting_account_id  = true

  endpoints {
    ec2 = "http://aws:4566"
  }
}