variable "bucket_name" {
  description = "Name of the S3 bucket"
}

variable "index_document" {
  description = "Index document for the S3 bucket website"
  default     = "index.html"
}

variable "error_document" {
  description = "Error document for the S3 bucket website"
  default     = "error.html"
}

variable "cloudfront_oai_iam_arn" {
  description = "The IAM ARN for CloudFront OAI to allow access to the S3 bucket"
  type        = string
}
