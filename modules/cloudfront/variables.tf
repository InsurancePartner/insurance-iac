variable "s3_bucket_domain_name" {
  description = "The domain name of the S3 bucket for CloudFront origin"
  type        = string
}

variable "alb_dns_name" {
  description = "The DNS name of the Application Load Balancer for CloudFront origin"
  type        = string
}

variable "cloudfront_aliases" {
  description = "List of alias domain names for the CloudFront distribution"
  type        = list(string)
  default     = []
}

variable "acm_certificate_arn" {
  description = "ARN of the ACM certificate used by CloudFront"
  type        = string
}
