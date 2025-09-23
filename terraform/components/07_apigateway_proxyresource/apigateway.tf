resource "aws_api_gateway_rest_api" "proxy_sample" {
  name        = "proxy-sample"
  description = "Resource Proxy Sample API"
}

resource "aws_api_gateway_resource" "proxy_resource" {
  rest_api_id = aws_api_gateway_rest_api.proxy_sample.id
  parent_id   = aws_api_gateway_rest_api.proxy_sample.root_resource_id
  path_part   = "{proxy+}" # リソースプロキシを有効にする
}

resource "aws_api_gateway_method" "proxy_method" {
  rest_api_id   = aws_api_gateway_rest_api.proxy_sample.id
  resource_id   = aws_api_gateway_resource.proxy_resource.id
  http_method   = "ANY"  # 任意のHTTPメソッド
  authorization = "NONE" # 認証なし

  request_parameters = {
    "method.request.path.proxy" = true # リソースプロキシを有効にする
  }
}


resource "aws_api_gateway_integration" "proxy_integration" {
  rest_api_id             = aws_api_gateway_rest_api.proxy_sample.id
  resource_id             = aws_api_gateway_resource.proxy_resource.id
  http_method             = aws_api_gateway_method.proxy_method.http_method
  integration_http_method = "POST" # Lambda関数との統合で使用するHTTPメソッド
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.inner_routing.invoke_arn
  content_handling        = "CONVERT_TO_TEXT"
  depends_on              = [aws_lambda_function.inner_routing]
}

resource "aws_api_gateway_deployment" "proxy_sample_deployment" {
  depends_on  = [aws_api_gateway_integration.proxy_integration]
  rest_api_id = aws_api_gateway_rest_api.proxy_sample.id
}

resource "aws_api_gateway_stage" "proxy_sample_stage" {
  stage_name    = "prod"
  rest_api_id   = aws_api_gateway_rest_api.proxy_sample.id
  deployment_id = aws_api_gateway_deployment.proxy_sample_deployment.id

}

output "api_invoke_url" {
  value = "https://${aws_api_gateway_rest_api.proxy_sample.id}.execute-api.${var.aws_region}.amazonaws.com/${aws_api_gateway_stage.proxy_sample_stage.stage_name}"
}
