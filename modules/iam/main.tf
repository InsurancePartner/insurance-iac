resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecs_task_execution_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        },
        Effect = "Allow"
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
        Action = "sts:AssumeRole"
      },
    ]
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
