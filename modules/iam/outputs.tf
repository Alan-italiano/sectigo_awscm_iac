output "SectigoAWSCM-role-arn-output" {
  value = aws_iam_role.sectigoCM-lambda-role.arn
}

output "SectigoAWSCM-role-name-output" {
  value = aws_iam_role.sectigoCM-lambda-role.name
}