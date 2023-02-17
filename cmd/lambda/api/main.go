package main

import (
	"os"

	v1 "github.com/holmes89/armadillo/internal/handlers/rest/v1"
	"github.com/holmes89/armadillo/internal/handlers/rest/v1/service"
	"github.com/holmes89/go-common/api"
	"github.com/holmes89/go-common/dynamo"

	"github.com/holmes89/armadillo/internal/login"
)

func dynamoConf() dynamo.DBConf {
	tableName := "armadillo"
	if table := os.Getenv("DYNAMODB_TABLE"); table != "" {
		tableName = table
	}
	return dynamo.DBConf{
		TableName: tableName,
	}
}

func main() {

	server := api.NewServer(new(v1.Router))

	server.RegisterService(dynamoConf)

	// Login handlers
	server.RegisterService(login.NewService)
	server.RegisterService(service.NewLoginServicer)
	server.RegisterRouter(v1.NewLoginApiController)

	server.RouteAggregator(v1.NewRouter)
	server.Run()
}
