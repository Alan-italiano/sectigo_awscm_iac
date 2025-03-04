resource "aws_iam_policy" "sectigoCM-lambda-policy" {
  name   = var.lambda_policy_name
  policy = var.lambda_policy_file
}

resource "aws_iam_role" "sectigoCM-lambda-role" {
  name               = var.lambda_role_name
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "sectigocm_policy_attach_to_sectigo_role" {
  role       = aws_iam_role.sectigoCM-lambda-role.id
  policy_arn = aws_iam_policy.sectigoCM-lambda-policy.arn
}
