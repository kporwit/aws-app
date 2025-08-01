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
}

module "s3-bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "4.1.0"

  bucket = "terraform-state-application"

  versioning = {
    enabled    = true
    mfa_delete = false
  }

  server_side_encryption_configuration = {
    rule = {
      bucket_key_enabled = true
      apply_server_side_encryption_by_default = {
        sse_algorithm = "AES256"
      }
    }
  }

  tags = {
    terraform = "true"
  }
}

module "dynamodb-table" {
  source  = "terraform-aws-modules/dynamodb-table/aws"
  version = "4.0.0"

  name     = "terraform-lock-table"
  hash_key = "LockID"

  point_in_time_recovery_enabled = true

  attributes = [
    {
      name = "LockID"
      type = "S"
    }
  ]

  tags = {
    terraform = "true"
  }
}
