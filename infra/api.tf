module "api_label" {
  source     = "cloudposse/label/null"
  version    = "0.25.0"
  context    = module.this.context
  attributes = ["api"]
}

data "aws_iam_policy_document" "api_assume" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "lambda" {
  name               = module.api_label.id
  assume_role_policy = data.aws_iam_policy_document.api_assume.json
  tags               = module.api_label.tags
}

data "aws_iam_policy_document" "lambda" { #Should I break it up?Z
  # Dynamo Connection
  statement {
    actions = [
      "dynamodb:List*",
      "dynamodb:DescribeReservedCapacity*",
      "dynamodb:DescribeLimits",
      "dynamodb:DescribeTimeToLive"
    ]
    resources = ["*"]
  }
  statement {
    actions = [
      "dynamodb:BatchGet*",
      "dynamodb:DescribeStream",
      "dynamodb:DescribeTable",
      "dynamodb:Get*",
      "dynamodb:Query",
      "dynamodb:Scan",
      "dynamodb:BatchWrite*",
      "dynamodb:CreateTable",
      "dynamodb:Delete*",
      "dynamodb:Update*",
      "dynamodb:PutItem"
    ]
    resources = ["arn:aws:dynamodb:${data.aws_region.current.name}:*:table/${aws_dynamodb_table.armadillo_table.name}"]
  }
  statement {
    actions=[
      "cognito-idp:AdminInitiateAuth"
    ]
    resources = [var.cognitoZ_arn]
  }

}

resource "aws_iam_policy" "api_lambda" {
  name   = module.api_label.id
  policy = data.aws_iam_policy_document.lambda.json
}

resource "aws_iam_role_policy_attachment" "api_lambda" {
  role       = aws_iam_role.lambda.name
  policy_arn = aws_iam_policy.api_lambda.arn
}

resource "aws_iam_role_policy_attachment" "api_lambda_log" {
  role       = aws_iam_role.lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_lambda_function" "api_lambda" {
  function_name = module.api_label.id
  tags          = module.api_label.tags
  filename      = "${path.module}/main.zip"
  handler       = "api"
  runtime       = "go1.x"
  role          = aws_iam_role.lambda.arn
  publish       = false
  timeout = 30
  environment {
    variables = {
      DYNAMODB_TABLE = aws_dynamodb_table.armadillo_table.name
      COGNITO_CLIENT_ID = var.cognito_client_id
      COGNITO_POOL_ID = var.cognito_pool_id
    }
  }
  depends_on = [aws_cloudwatch_log_group.api_lambda]
}

resource "aws_cloudwatch_log_group" "api_lambda" {
  name              = "/aws/lambda/${module.api_label.id}"
  retention_in_days = 14
}


# Add to gateway
resource "aws_lambda_permission" "allow_api_gateway" {
  function_name = aws_lambda_function.api_lambda.function_name
  statement_id  = "AllowExecutionFromApiGateway"
  action        = "lambda:InvokeFunction"
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${var.api_gateway_execute_arn}/*/*/*"
}

resource "aws_api_gateway_method" "api_root" {
  rest_api_id   = var.api_gateway_id
  resource_id   = aws_api_gateway_resource.api_root.id
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_resource" "api_root" {
  rest_api_id = var.api_gateway_id
  parent_id   = var.api_gateway_root_resource_id
  path_part   = "armadillo"
}

resource "aws_api_gateway_integration" "api_root" {
  rest_api_id = var.api_gateway_id
  resource_id = aws_api_gateway_resource.api_root.id
  http_method = aws_api_gateway_method.api_root.http_method
  type        = "MOCK"

  request_templates = {
    "application/json" = "{ \"statusCode\": 404 }"
  }
}

resource "aws_api_gateway_method_response" "api_root" {
  depends_on  = [aws_api_gateway_method.api_root]
  rest_api_id = var.api_gateway_id
  resource_id = aws_api_gateway_resource.api_root.id
  http_method = aws_api_gateway_method.api_root.http_method
  status_code = 200

  response_parameters = local.method_response_parameters

  response_models = {
    "application/json" = "Empty"
  }
}

resource "aws_api_gateway_integration_response" "api_root" {
  depends_on          = [aws_api_gateway_integration.api_root, aws_api_gateway_method_response.api_root]
  rest_api_id         = var.api_gateway_id
  resource_id         = aws_api_gateway_resource.api_root.id
  http_method         = aws_api_gateway_method.api_root.http_method
  status_code         = 404
  response_parameters = local.integration_response_parameters

  response_templates = {
    "application/json" = "{'message':$context.error.messageString}"
  }
}

resource "aws_api_gateway_integration" "api_lambda_post" {
  rest_api_id = var.api_gateway_id
  resource_id = aws_api_gateway_method.api_proxy_post.resource_id
  http_method = aws_api_gateway_method.api_proxy_post.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.api_lambda.invoke_arn
}

resource "aws_api_gateway_integration" "api_lambda_get" {
  rest_api_id = var.api_gateway_id
  resource_id = aws_api_gateway_method.api_proxy_get.resource_id
  http_method = aws_api_gateway_method.api_proxy_get.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.api_lambda.invoke_arn
}

resource "aws_api_gateway_resource" "api_proxy" {
  rest_api_id = var.api_gateway_id
  parent_id   = aws_api_gateway_resource.api_root.id
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "api_proxy_post" {
  rest_api_id   = var.api_gateway_id
  resource_id   = aws_api_gateway_resource.api_proxy.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_method" "api_proxy_get" {
  rest_api_id   = var.api_gateway_id
  resource_id   = aws_api_gateway_resource.api_proxy.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_method" "api_cors" {
  rest_api_id   = var.api_gateway_id
  resource_id   = aws_api_gateway_resource.api_proxy.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_method_response" "api_cors" {
  depends_on  = [aws_api_gateway_method.api_cors]
  rest_api_id = var.api_gateway_id
  resource_id = aws_api_gateway_resource.api_proxy.id
  http_method = aws_api_gateway_method.api_cors.http_method
  status_code = 200

  response_parameters = local.method_response_parameters

  response_models = {
    "application/json" = "Empty"
  }
}

resource "aws_api_gateway_integration_response" "api_cors" {
  depends_on          = [aws_api_gateway_integration.api_cors, aws_api_gateway_method_response.api_cors]
  rest_api_id         = var.api_gateway_id
  resource_id         = aws_api_gateway_resource.api_proxy.id
  http_method         = aws_api_gateway_method.api_cors.http_method
  status_code         = 200
  response_parameters = local.integration_response_parameters

  response_templates = {
    "application/json" = "{'message':$context.error.messageString}"
  }
}

resource "aws_api_gateway_integration" "api_cors" {
  rest_api_id = var.api_gateway_id
  resource_id = aws_api_gateway_resource.api_proxy.id
  http_method = aws_api_gateway_method.api_cors.http_method
  type        = "MOCK"

  request_templates = {
    "application/json" = "{ \"statusCode\": 200 }"
  }
}
