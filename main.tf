terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region  = "eu-north-1"
}

resource "aws_vpc" "insurancepartner_vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "insurancepartner_vpc"
  }
}

resource "aws_subnet" "insurancepartner_public_subnet_1" {
  vpc_id            = aws_vpc.insurancepartner_vpc.id
  cidr_block        = "10.0.10.0/24"
  availability_zone = "eu-north-1a"
  tags = {
    Name = "insurancepartner_public_subnet_1"
  }
}

resource "aws_subnet" "insurancepartner_public_subnet_2" {
  vpc_id            = aws_vpc.insurancepartner_vpc.id
  cidr_block        = "10.0.20.0/24"
  availability_zone = "eu-north-1b"
  tags = {
    Name = "insurancepartner_public_subnet_2"
  }
}

resource "aws_security_group" "insurancepartner_sg_public" {
  name        = "insurancepartner-sg-public"
  description = "Security group for the web server"
  vpc_id      = aws_vpc.insurancepartner_vpc.id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 3002
    to_port     = 3002
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  revoke_rules_on_delete = false
}

resource "aws_internet_gateway" "insurancepartner_igw" {
  vpc_id = aws_vpc.insurancepartner_vpc.id

  tags = {
    Name = "insurancepartner-igw"
  }
}

resource "aws_route_table" "insurancepartner_route_table" {
  vpc_id = aws_vpc.insurancepartner_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.insurancepartner_igw.id
  }

  tags = {
    Name = "insurancepartner-route-table"
  }
}

resource "aws_route_table_association" "insurancepartner_rta_association_1" {
  subnet_id      = aws_subnet.insurancepartner_public_subnet_1.id
  route_table_id = aws_route_table.insurancepartner_route_table.id
}

resource "aws_route_table_association" "insurancepartner_rta_association_2" {
  subnet_id      = aws_subnet.insurancepartner_public_subnet_2.id
  route_table_id = aws_route_table.insurancepartner_route_table.id
}


resource "aws_lb" "insurancepartner_alb" {
  name               = "insurancepartner-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.insurancepartner_sg_public.id]
  subnets            = [aws_subnet.insurancepartner_public_subnet_1.id, aws_subnet.insurancepartner_public_subnet_2.id]

  enable_deletion_protection = false

  tags = {
    Name = "insurancepartner-alb"
  }
}

resource "aws_lb_target_group" "insurancepartner_tg" {
  name     = "insurancepartner-tg"
  port     = 3002
  protocol = "HTTP"
  vpc_id   = aws_vpc.insurancepartner_vpc.id
  target_type = "ip"

  health_check {
    enabled             = true
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = 5
    path                = "/"
    port                = "traffic-port"
    protocol            = "HTTP"
    interval            = 60
    matcher             = "200"
  }

  tags = {
    Name = "insurancepartner-tg"
  }
}

resource "aws_lb_listener" "insurancepartner_alb_listener" {
  load_balancer_arn = aws_lb.insurancepartner_alb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"

  certificate_arn   = var.acm_certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.insurancepartner_tg.arn
  }
}

resource "aws_ecs_cluster" "insurance_cluster" {
  name = "insurance-cluster"
}

resource "aws_ecr_repository" "insurance_api_ecr" {
  name                 = "insurance-api-ecr"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name = "Insurance API ECR Repository"
  }
}

resource "aws_cloudwatch_log_group" "insurance_api_log_group" {
  name = "/ecs/insurance_api"

  retention_in_days = 90

  tags = {
    Name = "InsuranceAPILogs"
  }
}

resource "aws_ecs_task_definition" "insurance_api_task" {
  family                   = "insurance_api"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "512" 
  memory                   = "1024" 
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      name      = "insurance_api_container"
      image     = "${aws_ecr_repository.insurance_api_ecr.repository_url}:latest"
      essential = true
      portMappings = [
        {
          containerPort = 3002
          hostPort      = 3002
          protocol      = "tcp"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "/ecs/insurance_api"
          awslogs-region        = "eu-north-1"
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])

  tags = {
    Name = "insurance_api_task"
  }
}

resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecs_task_execution_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
        Effect = "Allow"
        Sid    = ""
      },
    ]
  })

  tags = {
    Name = "ecs_task_execution_role"
  }
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role" "s3_bucket_modification_role" {
  name = "s3_bucket_modification_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "ecs-tasks.amazonaws.com" 
        },
        Action = "sts:AssumeRole",
      },
    ],
  })
}

resource "aws_iam_policy" "s3_bucket_modification" {
  name        = "s3_bucket_modification"
  description = "Policy for S3 bucket ACL modification"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = "s3:PutBucketAcl",
        Resource = "arn:aws:s3:::insurance-ui"
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "s3_bucket_modification_policy" {
  role       = aws_iam_role.s3_bucket_modification_role.name
  policy_arn = aws_iam_policy.s3_bucket_modification.arn
}

resource "aws_iam_policy" "ecs_logs_policy" {
  name        = "ecs_logs_policy"
  description = "Allows ECS tasks to create and put logs in CloudWatch"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = "arn:aws:logs:*:*:log-group:/ecs/insurance_api:*"
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_logs_policy_attachment" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = aws_iam_policy.ecs_logs_policy.arn
}

resource "aws_ecs_service" "insurance_api_service" {
  name            = "insurance-api-service"
  cluster         = aws_ecs_cluster.insurance_cluster.id
  task_definition = aws_ecs_task_definition.insurance_api_task.arn
  desired_count   = 1

  launch_type = "FARGATE"

  network_configuration {
    assign_public_ip = true
    subnets          = [aws_subnet.insurancepartner_public_subnet_1.id, aws_subnet.insurancepartner_public_subnet_2.id]
    security_groups  = [aws_security_group.insurancepartner_sg_public.id]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.insurancepartner_tg.arn
    container_name   = "insurance_api_container"
    container_port   = 3002
  }

  force_new_deployment = true  
  depends_on = [aws_ecs_task_definition.insurance_api_task]
}

resource "aws_s3_bucket" "insurance_ui_bucket" {
  bucket = "insurance-ui"
}

resource "aws_s3_bucket_website_configuration" "insurance_ui_website_configuration" {
  bucket = aws_s3_bucket.insurance_ui_bucket.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

resource "aws_cloudfront_origin_access_identity" "insurance_ui_oai" {
  comment = "OAI for insurance UI"
}

resource "aws_cloudfront_distribution" "insurance_ui_distribution" {
  origin {
    domain_name = aws_s3_bucket.insurance_ui_bucket.bucket_regional_domain_name
    origin_id   = "insuranceUIOrigin"

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.insurance_ui_oai.cloudfront_access_identity_path
    }
  }

  origin {
    domain_name = aws_lb.insurancepartner_alb.dns_name
    origin_id   = "ECSALBOrigin"  

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "https-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  enabled             = true
  default_root_object = "index.html"

  aliases = ["insurance-partner.net"]

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "insuranceUIOrigin"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
  }

  ordered_cache_behavior {
    path_pattern     = "/api/*"
    allowed_methods  = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
    cached_methods   = ["GET", "HEAD"]

    target_origin_id = "ECSALBOrigin"

    forwarded_values {
      query_string = true
      headers      = ["Host", "Content-Type", "Accept", "Authorization"] 

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 0
    max_ttl                = 0
  }

  viewer_certificate {
    acm_certificate_arn = var.acm_virginia_certificate_arn
    ssl_support_method  = "sni-only"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
}

resource "aws_s3_bucket_policy" "insurance_ui_bucket_policy" {
  bucket = aws_s3_bucket.insurance_ui_bucket.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          AWS = aws_cloudfront_origin_access_identity.insurance_ui_oai.iam_arn
        },
        Action = "s3:GetObject",
        Resource = "arn:aws:s3:::${aws_s3_bucket.insurance_ui_bucket.bucket}/*"
      },
    ]
  })
}
