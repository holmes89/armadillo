provider "aws" {
  region = var.region
}

data "archive_file" "dummy" {
  type        = "zip"
  output_path = "${path.module}/main.zip"

  source {
    content  = "hello"
    filename = "dummy.txt"
  }
}

data "aws_region" "current" {}
data "aws_caller_identity" "current" {}