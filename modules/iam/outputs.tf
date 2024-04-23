output "ecs_task_execution_role_arn" {
  value = aws_iam_role.ecs_task_execution_role.arn
}

output "s3_bucket_modification_role_arn" {
  value = aws_iam_role.s3_bucket_modification_role.arn
}
