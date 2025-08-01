module "db" {
  source  = "terraform-aws-modules/rds/aws"
  version = "6.12.0"

  identifier = "${local.name_prefix}-rds"

  engine                = "mysql"
  engine_version        = "8.0"
  instance_class        = "db.t4g.large"
  allocated_storage     = 20
  max_allocated_storage = 100

  db_name  = "${local.name_prefix}-db"
  username = "db-admin"
  port     = "3306"

  multi_az = true

  iam_database_authentication_enabled = true

  vpc_security_group_ids = [
    aws_security_group.mysql_sg.id
  ]

  maintenance_window = "Mon:00:00-Mon:03:00"
  backup_window      = "03:00-06:00"

  # DB subnet group
  db_subnet_group_name   = module.vpc.database_subnet_group
  create_db_subnet_group = false

  # DB parameter group
  family = "mysql8.0"

  # DB option group
  major_engine_version = "8.0"

  # Database Deletion Protection
  deletion_protection = true

  parameters = [
    {
      name  = "character_set_client"
      value = "utf8mb4"
    },
    {
      name  = "character_set_server"
      value = "utf8mb4"
    }
  ]
}
