# Cloud Resume

My personal resume site, powered by a serverless AI chatbot on AWS. Everything is managed with Terraform.

## Architecture

- **S3** — hosts the static resume site
- **CloudFront** — serves the site over HTTPS via OAC
- **Lambda** — handles chat requests using Bedrock's RetrieveAndGenerate API
- **API Gateway** — HTTP API with a `POST /chat` route that triggers the Lambda
- **Bedrock Knowledge Base** — RAG pipeline using S3 Vectors to answer questions about the resume
- **S3 Vectors** — cost-effective vector store for the Knowledge Base
- **GitHub Actions** — auto-deploys frontend to S3 on push via OIDC

## Project Structure

```
├── frontend/          # Static resume site (HTML/CSS/JS)
├── backend/
│   └── lambda/
│       └── ai-chat/   # Lambda function for the AI chatbot
├── .github/
│   └── workflows/
│       └── deploy-frontend.yml  # Auto-deploys frontend on push
├── terraform/
│   ├── main.tf
│   ├── variables.tf
│   ├── terraform.tf
│   └── modules/
│       ├── s3/                # S3 bucket + bucket policy
│       ├── cloudfront/        # CloudFront distribution + OAC
│       ├── bedrock-kb/        # Knowledge Base + S3 Vectors + IAM
│       ├── lambda/            # Lambda function + IAM
│       ├── api-gateway/       # HTTP API + Lambda integration
│       └── github-actions-iam/  # OIDC provider + IAM role for GitHub Actions
```

## Prerequisites

- AWS CLI configured with credentials
- Terraform >= 1.2

## Deploying

```bash
cd terraform
terraform init
terraform apply
```

After that:
1. Upload your resume PDF to the Knowledge Base S3 bucket
2. Sync the Knowledge Base so it ingests the document
3. Update `API_URL` in `frontend/index.html` with the `chat_api_endpoint` output from Terraform

## CI/CD

Any push to `main` that changes files under `frontend/` will automatically sync to S3 via GitHub Actions. Auth is handled through OIDC — no access keys needed.
