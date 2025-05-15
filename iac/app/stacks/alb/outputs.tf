########################################
# Public ALB Outputs (Beverages)
########################################

output "public_alb_id" {
  description = "The ID of the public ALB."
  value       = aws_lb.public_alb.id
}

output "public_alb_arn" {
  description = "The ARN of the public ALB."
  value       = aws_lb.public_alb.arn
}

output "public_alb_arn_suffix" {
  description = "The ARN suffix for the public ALB (for CloudWatch)."
  value       = aws_lb.public_alb.arn_suffix
}

output "public_alb_dns_name" {
  description = "DNS name of the public ALB."
  value       = aws_lb.public_alb.dns_name
}

output "public_alb_sg_id" {
  description = "Security group ID of the public ALB."
  value       = aws_security_group.public_alb_sg.id
}

output "beverages_target_group_arn" {
  description = "ARN of the beverages target group."
  value       = aws_lb_target_group.beverages_tg.arn
}

output "beverages_target_group_arn_suffix" {
  description = "ARN suffix of the beverages target group."
  value       = aws_lb_target_group.beverages_tg.arn_suffix
}

output "public_listener_arn" {
  description = "ARN of the public HTTP listener."
  value       = aws_lb_listener.public_http_listener.arn
}

output "beverages_listener_rule_arn" {
  description = "ARN of the listener rule for /beverages path."
  value       = aws_lb_listener_rule.beverages_rule.arn
}


########################################
# Internal ALB Outputs (Ingredients)
########################################

output "internal_alb_id" {
  description = "The ID of the internal ALB."
  value       = aws_lb.internal_alb.id
}

output "internal_alb_arn" {
  description = "The ARN of the internal ALB."
  value       = aws_lb.internal_alb.arn
}

output "internal_alb_arn_suffix" {
  description = "The ARN suffix for the internal ALB (for CloudWatch)."
  value       = aws_lb.internal_alb.arn_suffix
}

output "internal_alb_dns_name" {
  description = "DNS name of the internal ALB."
  value       = aws_lb.internal_alb.dns_name
}

output "internal_alb_sg_id" {
  description = "Security group ID of the internal ALB."
  value       = aws_security_group.internal_alb_sg.id
}

output "ingredients_target_group_arn" {
  description = "ARN of the ingredients target group."
  value       = aws_lb_target_group.ingredients_tg.arn
}

output "ingredients_target_group_arn_suffix" {
  description = "ARN suffix of the ingredients target group."
  value       = aws_lb_target_group.ingredients_tg.arn_suffix
}

output "internal_listener_arn" {
  description = "ARN of the internal HTTP listener."
  value       = aws_lb_listener.internal_http_listener.arn
}

output "ingredients_listener_rule_arn" {
  description = "ARN of the listener rule for /ingredients path."
  value       = aws_lb_listener_rule.ingredients_rule.arn
}
