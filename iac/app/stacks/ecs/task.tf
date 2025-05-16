/*locals {
  awslogs_group = "/ecs/${var.task_name}-${var.environment}"
  repository_url = data.terraform_remote_state.ecr.outputs.repository_name[var.task_name].repository_url
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
*/