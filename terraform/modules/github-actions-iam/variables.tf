variable "role_name" {
  type        = string
  description = "IAM role name for GitHub Actions"
}

variable "github_repo" {
  type        = string
  description = "GitHub repo in owner/repo format (e.g. zhnkevin/cloud-resume)"
}

variable "s3_bucket_arn" {
  type        = string
  description = "ARN of the S3 bucket to deploy to"
}
