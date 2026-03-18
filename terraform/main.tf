provider "aws" {
  region = "us-east-1"

  default_tags {
    tags = {
      Project     = "Cloud Resume"
      Environment = var.environment
      Owner       = var.owner_name
    }
  }
}

module "s3" {
  source                      = "./modules/s3"
  static_bucket_name          = "cloud-resume-zhnkevin-us-east-1"
  cloudfront_distribution_arn = module.cloudfront.cloudfront_distribution_arn
}

module "cloudfront" {
  source                         = "./modules/cloudfront"
  s3_bucket_regional_domain_name = module.s3.bucket_regional_domain_name
  s3_bucket_id                   = module.s3.bucket_id
}

resource "aws_s3_bucket" "knowledge_base" {
  bucket = "cloud-resume-kb-zhnkevin-us-east-1"
}

module "bedrock_kb" {
  source                    = "./modules/bedrock-kb"
  knowledge_base_name       = "cloud-resume-kb-zhnkevin"
  knowledge_base_bucket_arn = aws_s3_bucket.knowledge_base.arn
}

module "lambda" {
  source            = "./modules/lambda"
  function_name     = "cloud-resume-ai-agent-chat"
  knowledge_base_id = module.bedrock_kb.knowledge_base_id
}

module "api_gateway" {
  source                   = "./modules/api-gateway"
  api_gateway_name         = "cloud-resume-api"
  lambda_invoke_arn        = module.lambda.invoke_arn
  lambda_function_name     = module.lambda.function_name
  cloudfront_domain_name   = module.cloudfront.cloudfront_distribution_domain_name
}

module "github_actions_iam" {
  source        = "./modules/github-actions-iam"
  role_name     = "github-actions-cloud-resume-s3-deploy"
  github_repo   = "zhnkevin/cloud-resume"
  s3_bucket_arn = module.s3.bucket_arn
}

output "chat_api_endpoint" {
  value = module.api_gateway.api_endpoint
}
