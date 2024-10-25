provider "aws" {
  region = "us-east-1"
}

data "aws_s3_bucket" "existing_bucket" {
  bucket = "sovwva-aws-cd-html-bucket"
}

resource "aws_s3_bucket" "website_bucket" {
  count = data.aws_s3_bucket.existing_bucket.id != "" ? 0 : 1

  bucket = "sovwva-aws-cd-html-bucket"

  website {
    index_document = "index.html"
    error_document = "error.html"
  }
}

resource "aws_s3_bucket_object" "html_files" {
  for_each = fileset("html_files", "*.html")

  bucket = data.aws_s3_bucket.existing_bucket.id != "" ? data.aws_s3_bucket.existing_bucket.id : aws_s3_bucket.website_bucket[0].id
  key    = each.key
  source = "html_files/${each.key}"
  acl    = "public-read"  # This allows individual objects to be publicly readable
}

output "website_url" {
  value = data.aws_s3_bucket.existing_bucket.id != "" ? data.aws_s3_bucket.existing_bucket.website_endpoint : aws_s3_bucket.website_bucket[0].website_endpoint
  description = "URL of the website hosted on S3"
}
