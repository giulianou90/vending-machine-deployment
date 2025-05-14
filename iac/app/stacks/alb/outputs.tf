output "lb_id" {
  description = "The ID of the load balancer created."
  value       = aws_lb.vending_alb.id
}

output "lb_arn" {
  description = "The ARN of the load balancer created."
  value       = aws_lb.vending_alb.arn
}

output "lb_arn_suffix" {
  description = "The ARN suffix for use with CloudWatch Metrics."
  value       = aws_lb.vending_alb.arn_suffix
}

output "tg_arn_suffix" {
  description = "The ARN suffixes for the target groups."
  value       = [
    aws_lb_target_group.beverages_tg.arn_suffix,
    aws_lb_target_group.ingredients_tg.arn_suffix,
  ]
}

output "listener_arn" {
  description = "The ARN of the HTTP listener."
  value       = aws_lb_listener.http_listener.arn
}

output "target_group_arn" {
  description = "ARNs of the target groups."
  value       = [
    aws_lb_target_group.beverages_tg.arn,
    aws_lb_target_group.ingredients_tg.arn,
  ]
}

output "target_group_arn_map" {
  description = "Map of target group names to their ARNs."
  value = tomap({
    (aws_lb_target_group.beverages_tg.name)   = aws_lb_target_group.beverages_tg.arn,
    (aws_lb_target_group.ingredients_tg.name) = aws_lb_target_group.ingredients_tg.arn,
  })
}

output "lb_sg_id" {
  description = "The ID of the load balancer's security group."
  value       = aws_security_group.alb_sg.id
}
