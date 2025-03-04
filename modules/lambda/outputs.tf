output "SectigoAWSCM-lambda-arn-output" {
  value = aws_lambda_function.sectigoSCM-main-python.arn
}

# output "result_entry" {
#   value = jsondecode(data.aws_lambda_invocation.sectigoAWSCM-invoke.result)
# }

output "SectigoAWSCM-lambda-function-name" {
  value = aws_lambda_function.sectigoSCM-main-python.function_name
}