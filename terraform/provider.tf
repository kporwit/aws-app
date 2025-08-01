terraform {
  required_version = ">= 1.2.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "< 6.0.0"
    }
  }
}

provider "aws" {
  profile = "default"
  region  = "eu-central-1"

  default_tags {
    tags = {
      Company         = var.company
      BusinessUnit    = var.business_unit
      Application     = var.application
      Environment     = var.environment
      Terraform       = "true"
      CreatedManually = "false"
    }
  }
}
