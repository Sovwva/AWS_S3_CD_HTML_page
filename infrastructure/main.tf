provider "aws" {
  region = "us-east-1" # Укажи нужный регион
}

# Проверка наличия бакета
resource "aws_s3_bucket" "html_bucket" {
  bucket = "sovwva-aws-cd-html-bucket"
}

# Загружаем HTML файлы в бакет
resource "aws_s3_bucket_object" "html_files" {
  for_each = fileset("html_files", "*.html")

  bucket = aws_s3_bucket.html_bucket.bucket
  key    = each.key
  source = "html_files/${each.key}"
  acl    = "public-read" # Установи нужные разрешения для объектов
}
