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

module "vpc" {
  source = "./modules/vpc"
  cidr_block = "10.0.0.0/16"
  instance_tenancy = "default"
  name = "insurancepartner_vpc"
}

module "public_subnet_1" {
  source              = "./modules/subnet"
  vpc_id              = module.vpc.vpc_id
  cidr_block          = "10.0.10.0/24"
  availability_zone   = "eu-north-1a"
  name                = "insurancepartner_public_subnet_1"
}

module "public_subnet_2" {
  source              = "./modules/subnet"
  vpc_id              = module.vpc.vpc_id
  cidr_block          = "10.0.20.0/24"
  availability_zone   = "eu-north-1b"
  name                = "insurancepartner_public_subnet_2"
}

module "security_group_public" {
  source           = "./modules/security-group"
  name             = "insurancepartner-sg-public"
  description      = "Security group for the web server"
  vpc_id           = module.vpc.vpc_id
  ingress_rules    = [
    {
      from_port   = 443,
      to_port     = 443,
      protocol    = "tcp",
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      from_port   = 3002,
      to_port     = 3002,
      protocol    = "tcp",
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
  revoke_rules_on_delete = false
}

module "internet_gateway" {
  source = "./modules/internet-gateway"
  vpc_id = module.vpc.vpc_id
  name   = "insurancepartner-igw"
}

module "route_table" {
  source     = "./modules/route-table"
  vpc_id     = module.vpc.vpc_id
  cidr_block = "0.0.0.0/0"
  gateway_id = module.internet_gateway.igw_id
  name       = "insurancepartner-route-table"
  subnet_ids = [module.public_subnet_1.subnet_id, module.public_subnet_2.subnet_id]
}

module "alb" {
  source     = "./modules/alb"
  name       = "insurancepartner-alb"
  security_groups = [module.security_group_public.security_group_id]
  subnets    = [module.public_subnet_1.subnet_id, module.public_subnet_2.subnet_id]
  tags       = {
    Name = "insurancepartner-alb"
  }
}

module "target_group" {
  source       = "./modules/target-group"
  name         = "insurancepartner-tg"
  port         = 3002
  protocol     = "HTTP"
  vpc_id       = module.vpc.vpc_id
  target_type  = "ip"
  tags         = {
    Name = "insurancepartner-tg"
  }
}

module "alb_listener" {
  source            = "./modules/alb-listener"
  load_balancer_arn = module.alb.alb_arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.acm_certificate_arn
  target_group_arn  = module.target_group.target_group_arn
}

module "ecs_cluster" {
  source = "./modules/ecs-cluster"
  name   = "insurance-cluster"
}

module "ecr_repository" {
  source              = "./modules/ecr-repository"
  name                = "insurance-api-ecr"
  image_tag_mutability = "MUTABLE"
  scan_on_push        = true
}

module "insurance_api_log_group" {
  source            = "./modules/log-group"
  name              = "/ecs/insurance_api"
  retention_in_days = 90
  tags              = { 
    Name = "InsuranceAPILogs" 
  }
}

module "ecs_task_definition" {
  source                 = "./modules/ecs-task-definition"
  family                 = "insurance_api"
  network_mode           = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                    = "512"
  memory                 = "1024"
  execution_role_arn     = module.iam.ecs_task_execution_role_arn
  ecr_repository_url     = module.ecr_repository.repository_url
  container_name         = "insurance_api_container"
  container_port         = 3002
  host_port              = 3002
  awslogs_group          = "/ecs/insurance_api"
  awslogs_region         = "eu-north-1"
  awslogs_stream_prefix  = "ecs"
  name                   = "insurance_api_task"
  aws_access_key_id      = var.aws_access_key_id
  aws_secret_access_key  = var.aws_secret_access_key
}

module "iam" {
  source = "./modules/iam"
}

module "ecs_service" {
  source              = "./modules/ecs-service"
  name                = "insurance-api-service"
  cluster_id          = module.ecs_cluster.cluster_id
  task_definition_arn = module.ecs_task_definition.task_definition_arn
  desired_count       = 1
  assign_public_ip    = true
  subnets             = [module.public_subnet_1.subnet_id, module.public_subnet_2.subnet_id]
  security_groups     = [module.security_group_public.security_group_id]
  target_group_arn    = module.target_group.target_group_arn
  container_name      = "insurance_api_container"
  container_port      = 3002
  force_new_deployment = true
}

module "s3_ui_bucket" {
  source        = "./modules/s3-bucket"
  bucket_name   = "insurance-ui"
  cloudfront_oai_iam_arn = module.cloudfront.oai_iam_arn
}

module "s3_img_bucket" {
  source        = "./modules/s3-bucket"
  bucket_name   = "insurances-img"
  cloudfront_oai_iam_arn = module.cloudfront.oai_iam_arn
}

module "cloudfront" {
  source              = "./modules/cloudfront"
  s3_bucket_domain_name = module.s3_ui_bucket.bucket_domain_name
  alb_dns_name        = module.alb.dns_name
  cloudfront_aliases  = ["insurance-partner.net"]
  acm_certificate_arn = var.acm_virginia_certificate_arn
}
