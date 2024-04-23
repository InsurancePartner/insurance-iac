resource "aws_ecs_task_definition" "task_definition" {
  family                   = var.family
  network_mode             = var.network_mode
  requires_compatibilities = var.requires_compatibilities
  cpu                      = var.cpu
  memory                   = var.memory
  execution_role_arn       = var.execution_role_arn

  container_definitions = jsonencode([
    {
      name      = var.container_name
      image     = "${var.ecr_repository_url}:latest"
      essential = true
      portMappings = [
        {
          containerPort = var.container_port
          hostPort      = var.host_port
          protocol      = "tcp"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = var.awslogs_group
          awslogs-region        = var.awslogs_region
          awslogs-stream-prefix = var.awslogs_stream_prefix
        }
      }
    }
  ])

  tags = {
    Name = var.name
  }
}
