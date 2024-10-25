provider "aws" {
  region = "us-east-1"
}

locals {
  bucket_name = "sovwva-aws-cd-html-bucket"
}

# Попытка получить существующий бакет
data "aws_s3_bucket" "existing_bucket" {
  bucket = local.bucket_name
}

# Проверка существования бакета
locals {
  bucket_exists = try(data.aws_s3_bucket.existing_bucket.id != "", false)
}

resource "aws_s3_bucket" "website_bucket" {
  count = local.bucket_exists ? 0 : 1

  bucket = local.bucket_name

  website {
    index_document = "index.html"
    error_document = "error.html"
  }
}

resource "aws_s3_bucket_policy" "bucket_policy" {
  count = local.bucket_exists ? 1 : 0

  bucket = data.aws_s3_bucket.existing_bucket.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = "*",
        Action = "s3:GetObject",
        Resource = "arn:aws:s3:::${data.aws_s3_bucket.existing_bucket.id}/*"
      }
    ]
  })
}

resource "aws_s3_bucket_object" "html_files" {
  for_each = fileset("html_files", "*.html")

  bucket = local.bucket_exists ? data.aws_s3_bucket.existing_bucket.id : aws_s3_bucket.website_bucket[0].id
  key    = each.key
  source = "html_files/${each.key}"
  acl    = "public-read"
}

output "website_url" {
  value = local.bucket_exists ? data.aws_s3_bucket.existing_bucket.website_endpoint : aws_s3_bucket.website_bucket[0].website_endpoint
  description = "URL of the website hosted on S3"
}
