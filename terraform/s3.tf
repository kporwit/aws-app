#trivy:ignore:AVD-AWS-0065
resource "aws_kms_key" "s3_kms_key" {
  description             = "KMS key is used to encrypt bucket objects"
  deletion_window_in_days = 7
}

module "s3_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "4.11.0"

  bucket = "${local.name_prefix}-bucket"

  expected_bucket_owner = data.aws_caller_identity.current.account_id

  acl = "private"

  versioning = {
    status     = true
    mfa_delete = false
  }


  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        kms_master_key_id = aws_kms_key.s3_kms_key.arn
        sse_algorithm     = "aws:kms"
      }
    }
  }
}
