#######################
# ALB SG
#######################
resource "aws_security_group" "alb_sg" {

  name        = "${local.name_prefix}-alb-sg"
  description = "ALB Security Group"
  vpc_id      = module.vpc.vpc_id

  tags = {
    Name = "${local.name_prefix}-alb-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "http_alb_ingress" {
  for_each = var.alb.allowed_inbound_cidrs

  security_group_id = aws_security_group.alb_sg.id
  cidr_ipv4         = each.value
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
  description       = "${each.key} HTTP to ALB access"
}

resource "aws_vpc_security_group_ingress_rule" "https_alb_ingress" {
  for_each = var.alb.allowed_inbound_cidrs

  security_group_id = aws_security_group.alb_sg.id
  cidr_ipv4         = each.value
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
  description       = "${each.key} HTTPS to ALB access"
}

resource "aws_vpc_security_group_egress_rule" "alb_egress" {
  security_group_id            = aws_security_group.alb_sg.id
  from_port                    = 80
  to_port                      = 80
  ip_protocol                  = "tcp"
  description                  = "ALB HTTP to ECS egress"
  referenced_security_group_id = aws_security_group.ecs_sg.id
}

#######################
# ECS SG
#######################
resource "aws_security_group" "ecs_sg" {

  name        = "${local.name_prefix}-ecs-sg"
  description = "ECS Security Group"
  vpc_id      = module.vpc.vpc_id

  tags = {
    Name = "${local.name_prefix}-ecs-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "ecs_ingress" {
  security_group_id            = aws_security_group.ecs_sg.id
  from_port                    = 80
  to_port                      = 80
  ip_protocol                  = "tcp"
  description                  = "ALB to ECS ingress"
  referenced_security_group_id = aws_security_group.alb_sg.id
}

resource "aws_vpc_security_group_egress_rule" "mysql_egress" {
  security_group_id            = aws_security_group.ecs_sg.id
  from_port                    = 3306
  to_port                      = 3306
  ip_protocol                  = "tcp"
  description                  = "ECS to MySQL egress"
  referenced_security_group_id = aws_security_group.mysql_sg.id
}

#######################
# MYSQL SG
#######################
resource "aws_security_group" "mysql_sg" {

  name        = "${local.name_prefix}-mysql-ec2-sg"
  description = "MySQL Security Group"
  vpc_id      = module.vpc.vpc_id

  tags = {
    Name = "${local.name_prefix}-mysql-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "mysql_ingress" {
  security_group_id            = aws_security_group.mysql_sg.id
  from_port                    = 3306
  to_port                      = 3306
  ip_protocol                  = "tcp"
  description                  = "ECS to MySQL ingress"
  referenced_security_group_id = aws_security_group.ecs_sg.id
}
