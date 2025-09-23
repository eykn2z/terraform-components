# API Gateway: openapiインポートパターン

- ルートディレクトリにS3で静的公開したswaggerUIを配置
  - CORSに配慮したswagger UIの用意
- S3: ブロックパブリックアクセスoff、ACL許可を行う必要あり
