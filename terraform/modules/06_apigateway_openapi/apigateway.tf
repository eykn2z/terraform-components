resource "aws_api_gateway_rest_api" "apiserver" {
  name = "Sample User API" # 本当は画面と同じでymlのtitleを入れたい
  body = templatefile("${path.module}/../../../openapi/openapi_sample.yml", {
    swagger_ui_url = "http://${aws_s3_bucket.swagger_ui.bucket}.s3-website-${var.aws_region}.amazonaws.com"
    apigateway_url = ""
  })
}

resource "aws_api_gateway_deployment" "apiserver_deployment" {
  depends_on = [
    aws_api_gateway_rest_api.apiserver
  ]

  rest_api_id = aws_api_gateway_rest_api.apiserver.id
  stage_name  = "prod"

  triggers = {
    redeployment = sha1(jsonencode(aws_api_gateway_rest_api.apiserver.body))
  }
  lifecycle {
    create_before_destroy = true
  }
}

output "api_invoke_url" {
  value = "https://${aws_api_gateway_rest_api.apiserver.id}.execute-api.${var.aws_region}.amazonaws.com/${aws_api_gateway_deployment.apiserver_deployment.stage_name}"
}
