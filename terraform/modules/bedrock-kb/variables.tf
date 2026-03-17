variable "knowledge_base_name" {
  type        = string
  description = "Name for the Bedrock Knowledge Base"
}

variable "knowledge_base_bucket_arn" {
  type        = string
  description = "ARN of the S3 bucket containing files for the AI agent to use as context"
}
