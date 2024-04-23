variable "name" {
  description = "The name of the load balancer"
  type        = string
}

variable "internal" {
  description = "Indicates if the load balancer is internal"
  type        = bool
  default     = false
}

variable "load_balancer_type" {
  description = "The type of load balancer to create"
  type        = string
  default     = "application"
}

variable "security_groups" {
  description = "A list of security group IDs to assign to the ALB"
  type        = list(string)
}

variable "subnets" {
  description = "A list of subnet IDs to attach to the ALB"
  type        = list(string)
}

variable "enable_deletion_protection" {
  description = "Indicates if deletion protection is enabled on the load balancer"
  type        = bool
  default     = false
}

variable "tags" {
  description = "A map of tags to assign to the resource"
  type        = map(string)
  default     = {}
}
