company           = "sbo"
business_unit     = "it"
application       = "nginx"
application_image = "nginx"
application_tag   = "stable"
environment       = "dev"
domain_name       = "example.com"

availability_zones = [
  "eu-central-1a",
  "eu-central-1b"
]

alb = {
  # This will open ALB Security Group (available externally) to the given CIDRs
  allowed_inbound_cidrs = {
    ip_cidr_1 = "0.0.0.0/0" # TODO set more restricted CIDRs
  }
}

# This will set up 80% of the tasks on Spot instances besides first two inital tasks.
fargate_capacity_providers = {
  FARGATE = {
    default_capacity_provider_strategy = {
      weight = 20
      # The number of tasks, at a minimum, to run on the specified capacity provider.
      base = 2
    }
  },
  FARGATE_SPOT = {
    default_capacity_provider_strategy = {
      weight = 80
    }
  }
}
