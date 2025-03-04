variable "sectigo_bucket" {
  description = "Name of s3 bucket"
  type        = string
  default     = "sectigo-awscm-ca"
}

variable "region_name" {
  description = "Set aws region for SectigoAWSCM installation"
  default = "us-east-1"
}

variable "function_name" {
  description = "Name of Lambda function"
  default = "SectigoAWSCM"
}

variable "lambda_policy_name" {
  description = "Policy for Lambda"
  default     = "SectigoAWSCM-lambda-policy"
}

variable "lambda_role_name" {
  description = "IAM role for Lambda"
  default     = "SectigoAWSCM-lambda-role"
}

variable "table_name" {
  description = "Dynamodb table for function"
  default  = "sectigoAWSCM"
}