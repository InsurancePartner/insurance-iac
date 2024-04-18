variable "acm_certificate_arn" {
  description = "The ARN of the SSL certificate from AWS Certificate Manager"
  type        = string
}

variable "acm_virginia_certificate_arn" {
  description = "The ARN of the SSL certificate from AWS Certificate Manager for CloudFront"
  type        = string
}