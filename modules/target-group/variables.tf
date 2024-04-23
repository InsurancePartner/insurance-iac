variable "name" {
  description = "The name of the target group"
  type        = string
}

variable "port" {
  description = "The port on which targets receive traffic"
  type        = number
}

variable "protocol" {
  description = "The protocol to use for routing traffic to the targets"
  type        = string
}

variable "vpc_id" {
  description = "The identifier of the VPC in which to create the target group"
  type        = string
}

variable "target_type" {
  description = "The type of target that you must specify when registering targets with this target group"
  type        = string
  default     = "ip"
}

variable "health_check" {
  description = "A map of health check settings"
  type        = map(any)
  default = {
    enabled             = true
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = 5
    path                = "/"
    port                = "traffic-port"
    protocol            = "HTTP"
    interval            = 60
    matcher             = "200"
  }
}

variable "tags" {
  description = "A map of tags to assign to the resource"
  type        = map(string)
  default     = {}
}
