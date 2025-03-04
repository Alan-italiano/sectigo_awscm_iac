output "url" {
  value = aws_api_gateway_deployment.SectigoAWSCM_ag_deployment.invoke_url
}

output "x-api-key-value" {
  value = aws_api_gateway_api_key.SectigoAWSCM-AG-api-key.value
}