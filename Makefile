GO_VERSION := 1.17

# Common values used throughout the Makefile, not intended to be configured.
TEMPLATE = template.yaml
PACKAGED_TEMPLATE = packaged.yaml

.PHONY: clean
clean:
	rm -f api $(PACKAGED_TEMPLATE)

.PHONY: build
build: clean lambda

.PHONY: run
run: build
	sam local start-api --profile default -p 8080



api: ./cmd/lambda/api/main.go
	go build -o api ./cmd/lambda/api/main.go

.PHONY: lambda
lambda:
	GOOS=linux GOARCH=amd64 $(MAKE) api

lint:
	golangci-lint run

test:
	go test ./...

.PHONY: gen-server
gen-server:
	rm -f ./lib/handlers/rest/v1/*.go
	java -jar ./bin/openapi-gen.jar  generate -i ./spec/api/openapi.yml -g go-server --model-package models --package-name v1 --ignore-file-override false --additional-properties=sourceFolder=./internal/handlers/rest/v1 --additional-properties=featureCORS=true --additional-properties=onlyInterfaces=false -c spec/api/openapi.yml
	rm -rf spec/api
	mv ./api spec/.

gen-client:
	java -jar ./bin/openapi-gen.jar generate -i ./spec/api/openapi.yml -g typescript-axios --additional-properties=supportsES6=true -o armadillo-ui/src/client --ignore-file-override ./.openapi-generator-ignore --model-name-prefix I