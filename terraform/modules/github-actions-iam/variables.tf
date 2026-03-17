variable "username" {
  type        = string
  description = "IAM username for GitHub Actions"
}

variable "s3_bucket_arn" {
  type        = string
  description = "ARN of the S3 bucket to deploy to"
}
