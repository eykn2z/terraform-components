resource "aws_s3_bucket" "swagger_ui" {
  bucket = "${var.bucket_prefix}-swagger-ui"
}

resource "aws_s3_bucket_ownership_controls" "swagger_ui" {
  bucket = aws_s3_bucket.swagger_ui.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "swagger_ui" {
  depends_on = [aws_s3_bucket_ownership_controls.swagger_ui]

  bucket = aws_s3_bucket.swagger_ui.id
  acl    = "public-read"
}

resource "aws_s3_bucket_website_configuration" "swagger_ui" {
  bucket = aws_s3_bucket.swagger_ui.id

  index_document {
    suffix = "index.html"
  }
}

# パブリックアクセスポリシーの設定
resource "aws_s3_bucket_policy" "swagger_ui_policy" {
  bucket = aws_s3_bucket.swagger_ui.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "s3:GetObject"
        Effect    = "Allow"
        Resource  = "arn:aws:s3:::${aws_s3_bucket.swagger_ui.id}/*"
        Principal = "*"
      },
    ]
  })
}

resource "aws_s3_bucket_website_configuration" "swagger_ui_website" {
  bucket = aws_s3_bucket.swagger_ui.bucket

  index_document {
    suffix = "index.html"
  }
}

resource "aws_s3_object" "openapi" {
  bucket = aws_s3_bucket.swagger_ui.id
  key    = "openapi_sample.yml"
  content = templatefile("${path.module}/../../../openapi/openapi_sample.yml", {
    swagger_ui_url = "http://${aws_s3_bucket.swagger_ui.bucket}.s3-website-${var.aws_region}.amazonaws.com"
    apigateway_url = "https://${aws_api_gateway_rest_api.apiserver.id}.execute-api.${var.aws_region}.amazonaws.com/${aws_api_gateway_deployment.apiserver_deployment.stage_name}"
  })
  acl = "public-read"
}

resource "aws_s3_object" "index_html" {
  bucket       = aws_s3_bucket.swagger_ui.id
  key          = "index.html"
  source       = "${path.module}/../../../openapi/index.html"
  acl          = "public-read"
  content_type = "text/html"
}


