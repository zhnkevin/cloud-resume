variable "static_bucket_name" {
  type        = string
  description = "Name for S3 bucket hosting static content"
}

variable "cloudfront_distribution_arn" {
  type        = string
  description = "ARN of the CloudFront distribution allowed to access this bucket"
}
