output "alb_arn" {
  value       = aws_lb.alb.arn
  description = "The ARN of the load balancer"
}

output "dns_name" {
  value       = aws_lb.alb.dns_name
  description = "The DNS name of the load balancer"
}
