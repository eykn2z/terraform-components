resource "aws_s3_bucket" "lambda_inner_routing" {
  bucket = "lambda-inner-routing-source"
}

resource "aws_s3_bucket_ownership_controls" "lambda_inner_routing" {
  bucket = aws_s3_bucket.lambda_inner_routing.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "lambda_inner_routing" {
  bucket = aws_s3_bucket.lambda_inner_routing.id
  acl    = "private"
}

data "archive_file" "lambda_inner_routing" {
  type        = "zip"
  source_file = "${path.module}/../../../app/lambda-inner-routing/bootstrap" # Goのビルド済みバイナリへのパス
  output_path = "${path.module}/../../../app/lambda-inner-routing/lambda-inner-routing.zip"
}

resource "aws_s3_object" "lambda_inner_routing_object" {
  bucket = aws_s3_bucket.lambda_inner_routing.bucket
  key    = "lambda-inner-routing.zip"
  source = data.archive_file.lambda_inner_routing.output_path
  etag   = filemd5(data.archive_file.lambda_inner_routing.output_path)
}
