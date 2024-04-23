variable "cidr_block" {
  type        = string
  description = "The CIDR block for the VPC."
}

variable "instance_tenancy" {
  type        = string
  description = "A tenancy option for instances launched into the VPC."
  default     = "default"
}

variable "name" {
  type        = string
  description = "The name of the VPC."
}
