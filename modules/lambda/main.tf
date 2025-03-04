resource "aws_lambda_function" "sectigoSCM-main-python" {
  description = "Lambda Function for sectigoAWSCM project"
  filename      = "./files/sectigoAWSCM.zip"
  function_name = var.function_name
  role          = var.role_arn
  depends_on = [
    aws_iam_role_policy_attachment.lambda_logs,
    aws_cloudwatch_log_group.sectigoAWSCM-lambda-lg,
  ]

  environment {
    variables = {
      s3_bucket_yaml = "${var.sectigo_bucket}"
      lambda_name = "${var.function_name}"
      table_name = "${var.table_name}"
    }
  }

  # The filebase64sha256() function is available in Terraform 0.11.12 and later
  # For Terraform 0.11.11 and earlier, use the base64sha256() function and the file() function:
  # source_code_hash = "${base64sha256(file("lambda_function_payload.zip"))}"
  source_code_hash = filebase64sha256("./files/sectigoAWSCM.zip")

  runtime = "python3.9"
  handler = "main.main_handler"
  timeout = 600
}
resource "aws_cloudwatch_log_group" "sectigoAWSCM-lambda-lg" {
  name              = "/aws/lambda/${var.function_name}"
  retention_in_days = 14
}

# See also the following AWS managed policy: AWSLambdaBasicExecutionRole
resource "aws_iam_policy" "lambda_logging" {
  name        = "lambda_logging-${terraform.workspace}"
  path        = "/"
  description = "IAM policy for logging from a lambda"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:*:*:*",
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = var.exist_role_name
  policy_arn = aws_iam_policy.lambda_logging.arn
}

