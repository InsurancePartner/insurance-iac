variable "name" {
  description = "The name of the ECR Repository."
  type        = string
}

variable "image_tag_mutability" {
  description = "The image tag mutability settings."
  type        = string
  default     = "MUTABLE"
}

variable "scan_on_push" {
  description = "Indicates whether images are scanned after being pushed to the repository."
  type        = bool
  default     = true
}
