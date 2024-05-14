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
      environment = [
        {
          name  = "AWS_ACCESS_KEY_ID"
          value = var.aws_access_key_id
        },
        {
          name  = "AWS_SECRET_ACCESS_KEY"
          value = var.aws_secret_access_key
        },
        {
          name  = "S3_ENDPOINT"
          value = "https://s3.eu-north-1.amazonaws.com"
        }
      ]
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
