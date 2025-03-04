resource "aws_api_gateway_rest_api" "SectigoAWSCM_ag" {
  name           = "SectigoAWSCM-ag-${terraform.workspace}"
  description    = "Rest API for SectigoAWSCM lambda function"
  api_key_source = "HEADER"
  body           = var.swagger_file

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_stage" "rest_api_stage" {
  deployment_id = aws_api_gateway_deployment.SectigoAWSCM_ag_deployment.id
  rest_api_id   = aws_api_gateway_rest_api.SectigoAWSCM_ag.id
  stage_name    = "SectigoAWSCM-${terraform.workspace}"
  description = "Stage of SectigoAWSCM rest api"
}

resource "aws_api_gateway_deployment" "SectigoAWSCM_ag_deployment" {
  rest_api_id = aws_api_gateway_rest_api.SectigoAWSCM_ag.id

  triggers = {
    redeployment = sha1(jsonencode(aws_api_gateway_rest_api.SectigoAWSCM_ag.body))
  }

  lifecycle {
    create_before_destroy = true
  }
}


resource "aws_lambda_permission" "ag-invoke-lambda" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_function_name
  principal     = "apigateway.amazonaws.com"
  

  # The /*/* portion grants access from any method on any resource
  # within the specified API Gateway.
  source_arn = "${aws_api_gateway_rest_api.SectigoAWSCM_ag.execution_arn}/*/*"
}

resource "aws_api_gateway_api_key" "SectigoAWSCM-AG-api-key" {
  name = "sectigoawscm-api-key-${terraform.workspace}"
  description = "API Key for SectigoAWSCM"
}

resource "aws_api_gateway_usage_plan" "sectigoawscm-usageplan" {
  name = "default-usage-plan-${terraform.workspace}"

  api_stages {
    api_id = aws_api_gateway_rest_api.SectigoAWSCM_ag.id
    stage  = aws_api_gateway_stage.rest_api_stage.stage_name
  }
}

resource "aws_api_gateway_usage_plan_key" "main" {
  key_id        = aws_api_gateway_api_key.SectigoAWSCM-AG-api-key.id
  key_type      = "API_KEY"
  usage_plan_id = aws_api_gateway_usage_plan.sectigoawscm-usageplan.id
}