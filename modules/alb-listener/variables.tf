variable "load_balancer_arn" {
  description = "The ARN of the load balancer to which to attach the listener."
  type        = string
}

variable "port" {
  description = "The port on which the load balancer is listening."
  type        = string
}

variable "protocol" {
  description = "The protocol for connections from clients to the load balancer."
  type        = string
}

variable "ssl_policy" {
  description = "The security policy if the protocol is HTTPS."
  type        = string
}

variable "certificate_arn" {
  description = "The ARN of the SSL server certificate."
  type        = string
}

variable "target_group_arn" {
  description = "The ARN of the target group to which to route traffic."
  type        = string
}
