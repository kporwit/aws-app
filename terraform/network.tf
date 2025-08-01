#trivy:ignore:AVD-AWS-0178
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.5.2"

  name = "${local.name_prefix}-vpc"

  cidr = "10.0.0.0/16"

  azs = var.availability_zones

  private_subnets = [
    "10.0.1.0/24",
    "10.0.2.0/24",
  ]

  create_database_subnet_group      = true
  create_database_nat_gateway_route = true
  database_subnet_group_name        = "${local.name_prefix}-db-subnet-group"

  database_subnets = [
    "10.0.3.0/24",
    "10.0.4.0/24"
  ]

  public_subnets = [
    "10.0.101.0/24",
    "10.0.102.0/24"
  ]

  enable_nat_gateway = true
  single_nat_gateway = true
}
