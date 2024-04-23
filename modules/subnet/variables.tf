variable "vpc_id" {
  type        = string
  description = "The ID of the VPC where the subnet will be created"
}

variable "cidr_block" {
  type        = string
  description = "The CIDR block for the subnet"
}

variable "availability_zone" {
  type        = string
  description = "The availability zone where the subnet will be located"
}

variable "name" {
  type        = string
  description = "The name of the subnet"
}
