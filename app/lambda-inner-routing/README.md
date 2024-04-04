# lambda-inner-routing

内部ルーティング用サンプルコード

## build
```
# m1 mac lambda用
GOOS=linux GOARCH=arm64 go build -tags lambda.norpc -o bootstrap main.go
# m1 mac ローカル確認用
go build -o main main.go
```
