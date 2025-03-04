resource "aws_dynamodb_table" "basic-dynamodb-table" {
  name           = var.table_name
  billing_mode   = "PROVISIONED"
  read_capacity  = 5
  write_capacity = 5
  hash_key       = "RequestParameters"
  range_key      = "RequestStatus"

  attribute {
    name = "RequestParameters"
    type = "S"
  }

  attribute {
    name = "RequestStatus"
    type = "S"
  }

}