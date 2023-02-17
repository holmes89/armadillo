module "table_label" {
  source     = "cloudposse/label/null"
  version    = "0.25.0"
  context    = module.this.context
  attributes = ["table"]
  enabled    = module.this.enabled
}

resource "aws_dynamodb_table" "armadillo_table" {
  name           = module.table_label.id
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "ID"
  range_key      = "SK"

  attribute {
    name = "ID"
    type = "S"
  }

  attribute {
    name = "SK"
    type = "S"
  }
}
