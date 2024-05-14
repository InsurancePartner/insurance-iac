variable "family" {}
variable "network_mode" {}
variable "requires_compatibilities" {
  type = list(string)
}
variable "cpu" {}
variable "memory" {}
variable "execution_role_arn" {}
variable "ecr_repository_url" {}
variable "container_name" {}
variable "container_port" {}
variable "host_port" {}
variable "awslogs_group" {}
variable "awslogs_region" {}
variable "awslogs_stream_prefix" {}
variable "name" {}

variable "aws_access_key_id" {
  type        = string
  description = "AWS Access Key ID"
}

variable "aws_secret_access_key" {
  type        = string
  description = "AWS Secret Access Key"
}
