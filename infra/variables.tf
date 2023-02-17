
variable "region" {
  type        = string
  description = "AWS Region for S3 bucket"
  default     = "us-east-2"
}


variable "api_gateway_id" {
  type = string
}

variable "api_gateway_root_resource_id" {
  type = string
}

variable "api_gateway_execute_arn" {
  type = string
}

variable "cognito_client_id" {
  type = string
}

variable "cognito_pool_id" {
  type = string
}
