package main

import (
	"context"
    "github.com/aws/aws-lambda-go/lambda"
    "github.com/aws/aws-lambda-go/events"
    "github.com/gin-gonic/gin"
    "github.com/awslabs/aws-lambda-go-api-proxy/gin"
    "net/http"
)

var ginLambda *ginadapter.GinLambda

func init() {
    r := gin.Default()

    r.GET("/", func(c *gin.Context) {
        c.JSON(http.StatusOK, gin.H{
            "message": "Welcome to the home page!",
        })
    })

    r.GET("/hello", func(c *gin.Context) {
        c.JSON(http.StatusOK, gin.H{
            "message": "Hello, world!",
        })
    })

    r.POST("/submit", func(c *gin.Context) {
        var data map[string]interface{}
        if err := c.BindJSON(&data); err != nil {
            c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
            return
        }
        c.JSON(http.StatusOK, gin.H{"received": data})
    })

	r.GET("/api/v1/users", func(c *gin.Context) {
        // ユーザーの一覧を取得する処理
        // ここではダミーのデータを返す
        users := []string{"John", "Doe", "Jane", "Smith"}
        c.JSON(http.StatusOK, gin.H{"users": users})
    })

    ginLambda = ginadapter.New(r)
}

func Handler(ctx context.Context, req events.APIGatewayProxyRequest) (events.APIGatewayProxyResponse, error) {
    // If no name is provided in the HTTP request body, throw an error
    return ginLambda.Proxy(req)
}

func main() {
    lambda.Start(Handler)
}
