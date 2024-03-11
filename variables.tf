variable "admin_users" {
  type        = list(string)
  default     = null
  description = "List of administrator IAM users to create"
}

variable "region" {
  type        = string
  default     = "us-west-2"
  description = "AWS region"
}

variable "bucket_name" {
  type        = string
  default     = null
  description = "S3 bucket name to which CloudTrail logs will be sent"
}
