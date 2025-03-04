output "invoke-url" {
  value = "${module.SectigoAWSCM-API-gw.url}SectigoAWSCM-${terraform.workspace}/queries?domains=ccmqa.com&account=demo2&action=enroll"
}

output "x-api-key" {
  value = nonsensitive("${module.SectigoAWSCM-API-gw.x-api-key-value}")
}

output "invoke-command" {
  value = "curl --X GET -H 'x-api-key: <x-api-key>' -H 'Content-Type: application/json' <invoke-url>"
}

output "aws_account_id" {
  value = local.account_id
}

output "lambda_function_name" {
  value = "${module.SectigoAWSCM-lambda.SectigoAWSCM-lambda-function-name}"
}

output "s3_bucket_for_accounts" {
  value = "${module.SectigoAWSCM-s3.SectigoAWSCM-s3-bucket-name}"
}

output "dynamodb_table_name" {
  value = "${module.SectigoAWSCM-dynamodb.SectigoAWSCM-dynamodb-name}"
  
}

output "lambda_invoke_command_with_cli" {
  value = "aws lambda invoke --function-name ${module.SectigoAWSCM-lambda.SectigoAWSCM-lambda-function-name} --payload '{'domains': '<domain_name>', 'account': '<account_name>', 'action': '<action_name>'}"
}