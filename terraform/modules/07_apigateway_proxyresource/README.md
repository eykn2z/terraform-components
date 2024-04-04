# API Gateway: プロキシリソースパターン
- lambdaの中で内部ルーティングを行う
- lambdaの処理: `app/lambda-inner-routing/main.go`へ
- `archive_file`でgoのコードをzip化し、s3バケットにアップロード、lambdaが参照し、apigatewayがプロキシリソースで参照する
