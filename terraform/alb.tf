##################################################
# ALB
##################################################

#trivy:ignore:AVD-AWS-0053
module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 9.0"

  name = "${local.name_prefix}-alb"

  load_balancer_type = "application"

  vpc_id  = module.vpc.vpc_id
  subnets = module.vpc.public_subnets

  # Security Group
  security_groups = [aws_security_group.alb_sg.id]

  # Listeners
  listeners = {
    http-redirect = {
      port     = 80
      protocol = "HTTP"

      redirect = {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    }

    https_listener = {
      port            = 443
      protocol        = "HTTPS"
      ssl_policy      = "ELBSecurityPolicy-TLS13-1-2-Res-2021-06"
      certificate_arn = module.acm.acm_certificate_arn

      forward = {
        target_group_key = "ecs"
      }
    }
  }

  # Target Groups
  target_groups = {
    ecs = {
      protocol                          = "HTTP"
      port                              = 80
      target_type                       = "ip"
      deregistration_delay              = 5
      load_balancing_cross_zone_enabled = true

      health_check = {
        enabled             = true
        healthy_threshold   = 2
        interval            = 30
        matcher             = "200"
        path                = "/health"
        port                = "traffic-port"
        protocol            = "HTTP"
        timeout             = 20
        unhealthy_threshold = 5
      }

      # Theres nothing to attach here in this definition. Instead,
      # ECS will attach the IPs of the tasks to this target group
      create_attachment = false

      stickiness = {
        enabled         = true
        type            = "lb_cookie"
        cookie_duration = 86400
      }
    }
  }
}

##################################################
# Route53 record
##################################################

module "records" {
  source  = "terraform-aws-modules/route53/aws//modules/records"
  version = "~> 2.0"

  zone_name = data.aws_route53_zone.this.name

  records = [
    {
      name    = "${var.application}.${var.environment}"
      type    = "CNAME"
      ttl     = 300
      records = [module.alb.dns_name]
    }
  ]
}

##################################################
# ACM Certificate
##################################################

module "acm" {
  source  = "terraform-aws-modules/acm/aws"
  version = "~> 4.0"

  domain_name = var.domain_name
  zone_id     = data.aws_route53_zone.this.id

  subject_alternative_names = [
    "www.${var.domain_name}",
    "*.${var.application}.${var.domain_name}"
  ]

  wait_for_validation = false

}
