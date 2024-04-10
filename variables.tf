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

variable "security_audit_bucket_name" {
  type        = string
  default     = null
  description = "S3 bucket name to which Security Audit account CloudTrail logs will be sent"
}

variable "cloudwatch_email" {
  type        = string
  default     = null
  description = "Email address to which the CloudWatch metric alarms will be sent"
}

variable "account_email" {
  type        = string
  description = "Email address that supports plus addressing (e.g., GMail)"
}

variable "sso_display_name" {
  type        = string
  description = "Display name used for admin/default user in Identity Center"
}

variable "organizational_units" {
  type        = list(string)
  description = "List of additional OU names (with the exception of Security)"
}

variable "account_to_ou_mapping" {
  type        = map(list(string))
  description = "Map of AWS accounts to their respective OUs (excluding the SecurityAudit account)"
}

variable "log_archive_account_id" {
  type        = string
  description = "Account ID for the LogArchive (formerly SecurityAudit) to be imported"
}
