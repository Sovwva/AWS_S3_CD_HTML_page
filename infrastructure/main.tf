provider "aws" {
  region = "us-west-2"  # Замените на нужный вам регион
}

resource "aws_s3_bucket" "website_bucket" {
  bucket = "sovwva-aws-cd-html-bucket"
  acl    = "public-read"
}

resource "aws_s3_bucket_website_configuration" "website" {
  bucket = aws_s3_bucket.website_bucket.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

resource "aws_s3_object" "html_files" {
  bucket = aws_s3_bucket.website_bucket.id
  key    = "index.html"
  source = "path/to/index.html"  # Замените на фактический путь к вашему HTML файлу
  acl    = "public-read"
}

resource "aws_s3_object" "error_file" {
  bucket = aws_s3_bucket.website_bucket.id
  key    = "error.html"
  source = "path/to/error.html"  # Замените на фактический путь к вашему HTML файлу
  acl    = "public-read"
}

# Добавьте другие HTML файлы по мере необходимости
# Например:
resource "aws_s3_object" "other_file" {
  bucket = aws_s3_bucket.website_bucket.id
  key    = "other_file.html"
  source = "path/to/other_file.html"  # Замените на фактический путь
  acl    = "public-read"
}
