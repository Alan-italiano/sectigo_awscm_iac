variable "lambda_policy_name" {
  description = "SectigoAWSCM lambda policy"
  type        = string
  default     = "SectigoAWSCM-lambda-policy"
}

variable "lambda_policy_file" {
  description = "Policy JSON file for lambda"

}
variable "lambda_role_name" {
  description = "SectigoAWSCM lambda role"
  type        = string
  default     = "SectigoAWSCM-lambda-policy"
}