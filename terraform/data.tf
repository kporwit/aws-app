data "aws_route53_zone" "this" {
  name = var.domain_name
}

data "aws_caller_identity" "current" {}
