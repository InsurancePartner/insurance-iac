variable "name" {
  description = "The name of the log group"
  type        = string
}

variable "retention_in_days" {
  description = "The number of days to retain log events"
  type        = number
  default     = 90
}

variable "tags" {
  description = "Tags to assign to the resource"
  type        = map(string)
  default     = {}
}
