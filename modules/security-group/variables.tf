variable "name" {
  type        = string
  description = "The name of the security group"
}

variable "description" {
  type        = string
  description = "The description for the security group"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID where the security group is deployed"
}

variable "ingress_rules" {
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
  description = "List of ingress rules"
}

variable "revoke_rules_on_delete" {
  type        = bool
  default     = false
  description = "Whether to revoke rules when the security group is deleted"
}
