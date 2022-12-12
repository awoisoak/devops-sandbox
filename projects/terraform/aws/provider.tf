terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.36.1"
    }
  }
}

provider "aws" {
  region = var.region

  ##########################################################
  # Extra configuration to emulate AWS services with localstack 
  # (it works to apply tf architectures but nothing is really deployed)
  # https://docs.localstack.cloud/integrations/terraform/
  #
  # s3_use_path_style           = true
  # skip_credentials_validation = true
  # skip_metadata_api_check     = true
  # skip_requesting_account_id  = true

  # endpoints {
  #   ec2 = "http://localhost:4566"
  # }
  ##########################################################

}