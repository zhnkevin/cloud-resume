data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# S3 Vector Bucket + Index
resource "aws_s3vectors_vector_bucket" "this" {
  vector_bucket_name = "${var.knowledge_base_name}-vectors"
}

resource "aws_s3vectors_index" "this" {
  index_name         = "${var.knowledge_base_name}-index"
  vector_bucket_name = aws_s3vectors_vector_bucket.this.vector_bucket_name
  dimension          = 1024
  distance_metric    = "cosine"
  data_type          = "float32"
}

# IAM Role for Bedrock Knowledge Base
resource "aws_iam_role" "bedrock_kb" {
  name = "${var.knowledge_base_name}-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = { Service = "bedrock.amazonaws.com" }
      Action = "sts:AssumeRole"
      Condition = {
        StringEquals = {
          "aws:SourceAccount" = data.aws_caller_identity.current.account_id
        }
      }
    }]
  })
}

resource "aws_iam_policy" "bedrock_kb" {
  name = "${var.knowledge_base_name}-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["bedrock:InvokeModel"]
        Resource = "arn:aws:bedrock:${data.aws_region.current.id}::foundation-model/amazon.titan-embed-text-v2:0"
      },
      {
        Effect   = "Allow"
        Action   = ["s3:GetObject", "s3:ListBucket"]
        Resource = [var.knowledge_base_bucket_arn, "${var.knowledge_base_bucket_arn}/*"]
      },
      {
        Effect = "Allow"
        Action = [
          "s3vectors:CreateIndex",
          "s3vectors:PutVectors",
          "s3vectors:QueryVectors",
          "s3vectors:GetVectors",
          "s3vectors:DeleteVectors",
          "s3vectors:ListVectors"
        ]
        Resource = [
          aws_s3vectors_vector_bucket.this.vector_bucket_arn,
          aws_s3vectors_index.this.index_arn
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "bedrock_kb" {
  role       = aws_iam_role.bedrock_kb.name
  policy_arn = aws_iam_policy.bedrock_kb.arn
}

# Bedrock Knowledge Base
resource "aws_bedrockagent_knowledge_base" "this" {
  name     = var.knowledge_base_name
  role_arn = aws_iam_role.bedrock_kb.arn

  knowledge_base_configuration {
    type = "VECTOR"

    vector_knowledge_base_configuration {
      embedding_model_arn = "arn:aws:bedrock:${data.aws_region.current.id}::foundation-model/amazon.titan-embed-text-v2:0"

      embedding_model_configuration {
        bedrock_embedding_model_configuration {
          dimensions = 1024
        }
      }
    }
  }

  storage_configuration {
    type = "S3_VECTORS"

    s3_vectors_configuration {
      vector_bucket_arn = aws_s3vectors_vector_bucket.this.vector_bucket_arn
      index_name        = aws_s3vectors_index.this.index_name
    }
  }
}

# Data Source (points to the S3 bucket with the resume PDF)
resource "aws_bedrockagent_data_source" "this" {
  name              = "${var.knowledge_base_name}-source"
  knowledge_base_id = aws_bedrockagent_knowledge_base.this.id

  data_source_configuration {
    type = "S3"

    s3_configuration {
      bucket_arn = var.knowledge_base_bucket_arn
    }
  }
}
