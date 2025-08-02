##################################################
# ECS CLUSTER
##################################################

module "ecs_cluster" {
  source  = "terraform-aws-modules/ecs/aws//modules/cluster"
  version = "5.9.0"

  cluster_name = "${local.name_prefix}-ecs-cluster"

  # Capacity provider
  fargate_capacity_providers = var.fargate_capacity_providers

  cloudwatch_log_group_retention_in_days = 5

  cluster_settings = [
    {
      name  = "containerInsights"
      value = "disabled"
    }
  ]

  tags = {
    Name = "${local.name_prefix}-ecs-cluster"
  }
}

###################################################
## ECS SERVICE
###################################################

module "ecs_service" {
  source  = "terraform-aws-modules/ecs/aws//modules/service"
  version = "5.9.0"

  name        = "${local.name_prefix}-service"
  cluster_arn = module.ecs_cluster.arn

  # Autoscaling
  enable_autoscaling       = true
  autoscaling_min_capacity = 2
  autoscaling_max_capacity = 4

  # Enable exec
  enable_execute_command = false

  desired_count = 2

  # Task Definition
  requires_compatibilities = ["FARGATE"]

  cpu    = 1024
  memory = 2048

  # Container definition(s)
  container_definitions = {
    "${local.name_prefix}-container" = {
      cpu                       = 1024
      memory                    = 2048
      essential                 = true
      image                     = "${var.application_image}:${var.application_tag}"
      readonly_root_filesystem  = false
      enable_cloudwatch_logging = true
      port_mappings = [
        {
          name          = "${local.name_prefix}-container"
          containerPort = 80
          hostPort      = 80
          protocol      = "tcp"
        }
      ]
    }
  }

  load_balancer = {
    service = {
      target_group_arn = module.alb.target_groups["ecs"].arn
      container_name   = "${local.name_prefix}-container"
      container_port   = 80
    }
  }


  create_task_exec_iam_role = true
  task_exec_iam_role_name   = "${local.name_prefix}-task-role"

  subnet_ids = module.vpc.private_subnets

  security_group_ids = [
    aws_security_group.ecs_sg.id
  ]
}

resource "aws_iam_role_policy_attachment" "test-attach" {
  role       = module.ecs_service.task_exec_iam_role_arn
  policy_arn = aws_iam_policy.ecs_task_policy.arn
}

resource "aws_iam_policy" "ecs_task_policy" {
  name   = "${local.name_prefix}-task-policy"
  policy = data.aws_iam_policy_document.bucket_access_policy.json
}

data "aws_iam_policy_document" "bucket_access_policy" {
  statement {
    effect = "Allow"

    actions = [
      "s3:ListBucket"
    ]

    resources = [
      "arn:aws:s3:::${local.name_prefix}-bucket",
    ]
  }
}
