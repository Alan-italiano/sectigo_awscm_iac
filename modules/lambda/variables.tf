variable "function_name" {
  description = "Name of main lambda function"
  type        = string
}

variable "role_arn" {
  description = "Reliable role for main lambda function"
  type        = string
}

variable "exist_role_name" {
  description = "Name of exist role for lambda"
  type        = string
}

variable "sectigo_bucket" {
  description = "Bucket name of accounts file"
}

variable "table_name" { 
  description = "Name of DynamoDB table"
}