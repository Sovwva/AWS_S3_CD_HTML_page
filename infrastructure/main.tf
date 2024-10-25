provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "website_bucket" {
  bucket = "sovwva-aws-cd-html-bucket"

  website {
    index_document = "index.html"
    error_document = "error.html"
  }
}

resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = aws_s3_bucket.website_bucket.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = "*",
        Action = "s3:GetObject",
        Resource = "arn:aws:s3:::${aws_s3_bucket.website_bucket.id}/*"
      }
    ]
  })
}

resource "aws_s3_bucket_object" "html_files" {
  for_each = fileset("html_files", "*.html")

  bucket = aws_s3_bucket.website_bucket.id
  key    = each.key
  source = "html_files/${each.key}"
  acl    = "public-read"
}

output "website_url" {
  value = aws_s3_bucket.website_bucket.website_endpoint
  description = "URL of the website hosted on S3"
}
