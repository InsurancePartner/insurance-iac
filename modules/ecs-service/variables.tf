variable "name" {}
variable "cluster_id" {}
variable "task_definition_arn" {}
variable "desired_count" {}
variable "assign_public_ip" {}
variable "subnets" {
  type = list(string)
}
variable "security_groups" {
  type = list(string)
}
variable "target_group_arn" {}
variable "container_name" {}
variable "container_port" {}
variable "force_new_deployment" {
  type = bool
  default = true
}
