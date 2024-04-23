variable "vpc_id" {
  description = "The VPC ID where the route table will be created"
  type        = string
}

variable "cidr_block" {
  description = "CIDR block for the route associated with the route table"
  type        = string
}

variable "gateway_id" {
  description = "The Internet Gateway ID to be used in the route"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs to associate with the route table"
  type        = list(string)
}

variable "name" {
  description = "The name of the route table"
  type        = string
}
