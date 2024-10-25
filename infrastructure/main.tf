provider "aws" {
  region = "us-east-1"
}

locals {
  bucket_name = "sovwva-aws-cd-html-bucket"
}

# Check if the bucket already exists
data "aws_s3_bucket" "existing_bucket" {
  bucket = local.bucket_name
}

resource "aws_s3_bucket" "website_bucket" {
  count = length(data.aws_s3_bucket.existing_bucket.id) > 0 ? 0 : 1

  bucket = local.bucket_name

  website {
    index_document = "index.html"
    error_document = "error.html"
  }
}

resource "aws_s3_bucket_acl" "bucket_acl" {
  count = length(data.aws_s3_bucket.existing_bucket.id) > 0 ? 0 : 1

  bucket = aws_s3_bucket.website_bucket[0].id
  acl    = "public-read"
}

resource "aws_s3_bucket_policy" "bucket_policy" {
  count = length(data.aws_s3_bucket.existing_bucket.id) > 0 ? 1 : 0

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

  bucket = length(data.aws_s3_bucket.existing_bucket.id) > 0 ? data.aws_s3_bucket.existing_bucket.id : aws_s3_bucket.website_bucket[0].id
  key    = each.key
  source = "html_files/${each.key}"
  acl    = "public-read"  # Установите это только если вам нужно
}

output "website_url" {
  value = length(data.aws_s3_bucket.existing_bucket.id) > 0 ? data.aws_s3_bucket.existing_bucket.website_endpoint : aws_s3_bucket.website_bucket[0].website_endpoint
  description = "URL of the website hosted on S3"
}
