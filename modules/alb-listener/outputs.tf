output "listener_arn" {
  value       = aws_lb_listener.listener.arn
  description = "The ARN of the load balancer listener."
}
