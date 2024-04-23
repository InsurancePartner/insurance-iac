resource "aws_ecs_service" "ecs_service" {
  name            = var.name
  cluster         = var.cluster_id
  task_definition = var.task_definition_arn
  desired_count   = var.desired_count

  launch_type = "FARGATE"

  network_configuration {
    assign_public_ip = var.assign_public_ip
    subnets          = var.subnets
    security_groups  = var.security_groups
  }

  load_balancer {
    target_group_arn = var.target_group_arn
    container_name   = var.container_name
    container_port   = var.container_port
  }

  force_new_deployment = var.force_new_deployment
}
