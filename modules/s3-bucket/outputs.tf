output "bucket_id" {
  value = aws_s3_bucket.s3_bucket.id
}

output "bucket_name" {
  value       = aws_s3_bucket.s3_bucket.bucket
  description = "The name of the S3 bucket."
}

output "bucket_arn" {
  value       = aws_s3_bucket.s3_bucket.arn
  description = "The ARN of the S3 bucket."
}

output "bucket_domain_name" {
  value       = aws_s3_bucket.s3_bucket.bucket_regional_domain_name
  description = "The domain name of the S3 bucket."
}
