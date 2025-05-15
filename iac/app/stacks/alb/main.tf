locals {
  vpc_id         = data.terraform_remote_state.vpc.outputs.vpc_id
  public_subnets = data.terraform_remote_state.vpc.outputs.public_subnets_id
  lb_name        = "${var.environment}-vending-alb"
}

resource "aws_security_group" "alb_sg" {
  name        = "${local.lb_name}-sg"
  description = "Allow HTTP inbound traffic"
  vpc_id      = local.vpc_id

  ingress {
    description = "Allow HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb" "vending_alb" {
  name               = local.lb_name
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = local.public_subnets

  idle_timeout                      = 60
  enable_cross_zone_load_balancing = true
  enable_deletion_protection       = false
  enable_http2                    = false   # optional to disable HTTP/2 if you want

  tags = {
    Environment = var.environment
    Name        = local.lb_name
  }
}

resource "aws_lb_target_group" "beverages_tg" {
  name     = "${var.environment}-beverages-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = local.vpc_id

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

resource "aws_lb_target_group" "ingredients_tg" {
  name     = "${var.environment}-ingredients-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = local.vpc_id

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

resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.vending_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.beverages_tg.arn  # or one default TG you want to forward to
  }
}

resource "aws_lb_listener_rule" "ingredients_rule" {
  listener_arn = aws_lb_listener.http_listener.arn
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

resource "aws_lb_listener_rule" "beverages_rule" {
  listener_arn = aws_lb_listener.http_listener.arn
  priority     = 20

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
