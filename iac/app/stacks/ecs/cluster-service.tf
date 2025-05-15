locals {
  service_name        = var.service_name
  container_name      = "${var.container_name}-${var.environment}"
  target_group_arn    = data.terraform_remote_state.alb.outputs.target_group_arn_map["${var.service_name}-tg-${var.environment}"]
  #task_definition_arn = data.terraform_remote_state.ecs-task.outputs.aws_ecs_task_definition_td_arn
  #cluster_id          = data.terraform_remote_state.ecs-cluster.outputs.fargate_id
  #cluster_name        = data.terraform_remote_state.ecs-cluster.outputs.fargate_name
  subnet_ids          = data.terraform_remote_state.vpc.outputs.private_subnets_id
  vpc_id              = data.terraform_remote_state.vpc.outputs.vpc_id
  lb_sg_id            = data.terraform_remote_state.alb.outputs.lb_sg_id
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
    security_groups = [local.lb_sg_id]
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

module "ecs_service" {
  source      = "git::https://github.com/nimbux911/terraform-aws-ecs-fargate-service.git?ref=v1.1.0"
  environment = var.environment

  fargate_services = {
    service_name          = "${local.service_name}-${var.environment}"
    task_definition_arn   = aws_ecs_task_definition.td.arn
    service_desired_count = var.service_desired_count
    lb_config             = local.target_group_arn == null ? null : [{
      target_group_arn = local.target_group_arn
      container_name   = local.container_name
      container_port   = var.container_port
    }]
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
