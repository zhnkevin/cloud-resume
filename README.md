# Cloud Resume

A serverless resume website with an AI chatbot, built on AWS and managed with Terraform.

## Architecture

- **S3** — hosts the static resume site
- **CloudFront** — serves the site over HTTPS via OAC
- **Lambda** — handles chat requests using Bedrock's RetrieveAndGenerate API
- **API Gateway** — HTTP API with a `POST /chat` route that triggers the Lambda
- **Bedrock Knowledge Base** — RAG pipeline using S3 Vectors to answer questions about the resume
- **S3 Vectors** — cost-effective vector store for the Knowledge Base

## Project Structure

```
├── frontend/          # Static resume site (HTML/CSS/JS)
├── backend/
│   └── lambda/
│       └── ai-chat/   # Lambda function for the AI chatbot
├── terraform/
│   ├── main.tf        # Root config wiring all modules
│   ├── variables.tf   # Root variables (environment, owner)
│   ├── terraform.tf   # Provider version constraints
│   └── modules/
│       ├── s3/            # S3 bucket + bucket policy
│       ├── cloudfront/    # CloudFront distribution + OAC
│       ├── bedrock-kb/    # Knowledge Base + S3 Vectors + IAM
│       ├── lambda/        # Lambda function + IAM
│       └── api-gateway/   # HTTP API + Lambda integration
```

## Prerequisites

- AWS CLI configured with appropriate credentials
- Terraform >= 1.2

## Deploy

```bash
cd terraform
terraform init
terraform apply
```

After deploy:
1. Upload your resume PDF to the Knowledge Base S3 bucket
2. Trigger a Knowledge Base sync to ingest the document
3. Update `API_URL` in `frontend/index.html` with the `chat_api_endpoint` output
4. Upload frontend files to the static S3 bucket
