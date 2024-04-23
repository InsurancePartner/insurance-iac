output "cloudfront_distribution_id" {
  value       = aws_cloudfront_distribution.distribution.id
  description = "The ID of the CloudFront distribution"
}

output "cloudfront_distribution_domain_name" {
  value       = aws_cloudfront_distribution.distribution.domain_name
  description = "The domain name of the CloudFront distribution"
}

output "oai_iam_arn" {
  value       = aws_cloudfront_origin_access_identity.oai.iam_arn
  description = "The IAM ARN for the CloudFront Origin Access Identity"
}
