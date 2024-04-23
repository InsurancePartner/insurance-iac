output "target_group_arn" {
  value       = aws_lb_target_group.tg.arn
  description = "The ARN of the target group"
}

output "target_group_id" {
  value       = aws_lb_target_group.tg.id
  description = "The ID of the target group"
}
