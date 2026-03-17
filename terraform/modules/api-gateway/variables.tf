variable "api_gateway_name" {
  type        = string
  description = "Name for the API Gateway"
}

variable "lambda_invoke_arn" {
  type        = string
  description = "Invoke ARN of the Lambda function"
}

variable "lambda_function_name" {
  type        = string
  description = "Name of the Lambda function"
}

variable "cloudfront_domain_name" {
  type        = string
  description = "CloudFront distribution domain name for CORS"
}
