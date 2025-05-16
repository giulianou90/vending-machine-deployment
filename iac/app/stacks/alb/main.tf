locals {
  vpc_id          = data.terraform_remote_state.vpc.outputs.vpc_id
  public_subnets  = data.terraform_remote_state.vpc.outputs.public_subnets_id
  private_subnets = data.terraform_remote_state.vpc.outputs.private_subnets_id

  public_alb_name  = "${var.environment}-vending-public-alb"
  internal_alb_name = "${var.environment}-vending-internal-alb"
}


resource "aws_security_group" "public_alb_sg" {
  name        = "${local.public_alb_name}-sg"
  description = "Allow HTTP from internet"
  vpc_id      = local.vpc_id

  ingress {
    description = "Allow HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb" "public_alb" {
  name               = local.public_alb_name
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.public_alb_sg.id]
  subnets            = local.public_subnets

  enable_cross_zone_load_balancing = true
  idle_timeout                     = 60
  enable_http2                     = false

  tags = {
    Name        = local.public_alb_name
    Environment = var.environment
  }
}

resource "aws_lb_target_group" "beverages_tg" {
  name     = "${var.environment}-beverages-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = local.vpc_id
  target_type = "ip"

  health_check {
    path                = "/beverages"
    protocol            = "HTTP"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 3
    matcher             = "200-399"
  }
}

resource "aws_lb_listener" "public_http_listener" {
  load_balancer_arn = aws_lb.public_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.beverages_tg.arn
  }
}

resource "aws_lb_listener_rule" "beverages_rule" {
  listener_arn = aws_lb_listener.public_http_listener.arn
  priority     = 10

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.beverages_tg.arn
  }

  condition {
    path_pattern {
      values = ["/beverages*"]
    }
  }
}


resource "aws_security_group" "internal_alb_sg" {
  name        = "${local.internal_alb_name}-sg"
  description = "Allow HTTP only within VPC"
  vpc_id      = local.vpc_id

  ingress {
    description = "Allow HTTP from VPC CIDR"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [data.terraform_remote_state.vpc.outputs.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb" "internal_alb" {
  name               = local.internal_alb_name
  internal           = true
  load_balancer_type = "application"
  security_groups    = [aws_security_group.internal_alb_sg.id]
  subnets            = local.private_subnets

  enable_cross_zone_load_balancing = true
  idle_timeout                     = 60
  enable_http2                     = false

  tags = {
    Name        = local.internal_alb_name
    Environment = var.environment
  }
}

resource "aws_lb_target_group" "ingredients_tg" {
  name     = "${var.environment}-ingredients-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = local.vpc_id
  target_type = "ip"

  health_check {
    path                = "/ingredients"
    protocol            = "HTTP"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 3
    matcher             = "200-399"
  }
}

resource "aws_lb_listener" "internal_http_listener" {
  load_balancer_arn = aws_lb.internal_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ingredients_tg.arn
  }
}

resource "aws_lb_listener_rule" "ingredients_rule" {
  listener_arn = aws_lb_listener.internal_http_listener.arn
  priority     = 10

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ingredients_tg.arn
  }

  condition {
    path_pattern {
      values = ["/ingredients*"]
    }
  }
}
