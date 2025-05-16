locals {
  service_name     = var.service_name
  container_name   = "${var.container_name}-${var.environment}"

  target_group_arns = [
    data.terraform_remote_state.alb.outputs.beverages_target_group_arn,
    data.terraform_remote_state.alb.outputs.ingredients_target_group_arn
  ]

  lb_sg_ids = [
    data.terraform_remote_state.alb.outputs.public_alb_sg_id,
    data.terraform_remote_state.alb.outputs.internal_alb_sg_id
  ]

  subnet_ids = data.terraform_remote_state.vpc.outputs.private_subnets_id
  vpc_id     = data.terraform_remote_state.vpc.outputs.vpc_id

  awslogs_group = "/ecs/${var.task_name}-${var.environment}"
  repository_url = data.terraform_remote_state.ecr.outputs.repository_name[var.task_name].repository_url
}



resource "aws_ecs_cluster" "main" {
  name = "${var.ecs_cluster_name}-ecs-${var.environment}"
  tags = merge(
    { Name = "${var.ecs_cluster_name}-ecs-${var.environment}" },
    var.tags
  )
}

resource "aws_security_group" "fargate_sg" {
  name        = "${local.service_name}-fargate-sg-${var.environment}"
  description = "ECS Fargate service SG"
  vpc_id      = local.vpc_id

  ingress {
    description     = "Allow LB Access"
    from_port       = var.container_port
    to_port         = var.container_port
    protocol        = "TCP"
    security_groups = local.lb_sg_ids
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    { Name = "${local.service_name}-fargate-sg-${var.environment}" },
    var.tags
  )
}

resource "aws_cloudwatch_log_group" "cw_container_log" {
  name = local.awslogs_group
  tags = var.tags
}

resource "aws_ecs_task_definition" "td" {
  family                   = "${var.task_name}-${var.environment}"
  container_definitions    = templatefile(var.container_definitions_path, {
    name            = "${var.task_name}-${var.environment}"
    container_image = "${local.repository_url}:${var.environment}-latest"
    awslogs-group   = local.awslogs_group
  })
  task_role_arn            = aws_iam_role.ecs_task_execution_role.arn
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  network_mode             = "awsvpc"
  cpu                      = var.container_cpu
  memory                   = var.container_memory
  requires_compatibilities = ["FARGATE"]
}

resource "aws_iam_role" "ecs_task_execution_role" {
  name               = "ecs-task-execution-role-${var.task_name}-${var.environment}"
  assume_role_policy = file("${path.module}/task-definitions/ecs_task_execution_role.json")
}

resource "aws_iam_role_policy_attachment" "ecs_policies" {
  for_each = {
    ecs_execution = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
    ses_access    = "arn:aws:iam::aws:policy/AmazonSESFullAccess"
    ssm_access    = "arn:aws:iam::aws:policy/AmazonSSMFullAccess"
  }

  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = each.value
}

module "ecs_service" {
  source      = "git::https://github.com/nimbux911/terraform-aws-ecs-fargate-service.git?ref=v1.1.0"
  environment = var.environment

  fargate_services = {
    service_name          = "${local.service_name}-${var.environment}"
    task_definition_arn   = aws_ecs_task_definition.td.arn
    service_desired_count = var.service_desired_count
    lb_config = [
      for tg_arn in local.target_group_arns : {
        target_group_arn = tg_arn
        container_name   = local.container_name
        container_port   = var.container_port
      }
    ]
  }

  cluster_id                           = aws_ecs_cluster.main.id
  cluster_name                         = aws_ecs_cluster.main.name
  security_group_ids                   = [aws_security_group.fargate_sg.id]
  subnet_ids                           = local.subnet_ids
  enable_autoscaling                   = var.enable_autoscaling
  deployment_minimum_healthy_percent  = 100
  deployment_maximum_percent          = 200
  tags                                 = var.tags
}

resource "aws_appautoscaling_target" "ecs_service_target" {
  max_capacity        = var.asg_max_capacity
  min_capacity        = var.asg_min_capacity
  resource_id         = "service/${aws_ecs_cluster.main.id}/${local.service_name}-${var.environment}"
  scalable_dimension  = "ecs:service:DesiredCount"
  service_namespace   = "ecs"
}
