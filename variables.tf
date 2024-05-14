variable "acm_certificate_arn" {
  description = "The ARN of the SSL certificate from AWS Certificate Manager"
  type        = string
}

variable "acm_virginia_certificate_arn" {
  description = "The ARN of the SSL certificate from AWS Certificate Manager for CloudFront"
  type        = string
}

variable "aws_access_key_id" {
  description = "The ID to access the AWS environment"
  type        = string
}

variable "aws_secret_access_key" {
  description = "The secret key to access the AWS environment"
  type        = string
}