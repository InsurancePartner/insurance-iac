resource "aws_lb_target_group" "tg" {
  name        = var.name
  port        = var.port
  protocol    = var.protocol
  vpc_id      = var.vpc_id
  target_type = var.target_type

  health_check {
    enabled             = var.health_check.enabled
    healthy_threshold   = var.health_check.healthy_threshold
    unhealthy_threshold = var.health_check.unhealthy_threshold
    timeout             = var.health_check.timeout
    path                = var.health_check.path
    port                = var.health_check.port
    protocol            = var.health_check.protocol
    interval            = var.health_check.interval
    matcher             = var.health_check.matcher
  }

  tags = var.tags
}
