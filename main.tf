#Terraform Backend Config
terraform {
  backend "s3" {
    bucket = "sectigo-aws-cm-tf-states"
    key    = "terraform/terraform.tfstate"
    region = "us-east-1"
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.63.0"
    }
  }
}


# Configure the AWS Provider
provider "aws" {
  region = "${terraform.workspace}"
}
data "aws_caller_identity" "current" {}

locals {
    account_id = data.aws_caller_identity.current.account_id
}


#S3 bucket Module
module "SectigoAWSCM-s3" {
  source         = "./modules/s3"
  sectigo_bucket =  var.sectigo_bucket
}

# IAM Roles&Policy Module
module "SectigoAWSCM-iam" {
  source             = "./modules/iam"
  lambda_policy_name = "SectigoAWSCM-lambda-policy-${terraform.workspace}"
  lambda_role_name   = "SectigoAWSCM-lambda-role-${terraform.workspace}"
  lambda_policy_file = data.template_file.SectigoAWSCM-lambda-policy-template.rendered
}

data "template_file" "SectigoAWSCM-lambda-policy-template" {
  template = file("./files/lambda-policy.json")
  vars = {
    get_s3_name = "${var.sectigo_bucket}"
    get_account_id = "${local.account_id}"
    get_region_name = "${terraform.workspace}"
    function_name = "SectigoAWSCM-${terraform.workspace}"
    table_name = "SectigoAWSCM-${terraform.workspace}"
  }
}

# DynamoDB Module
module "SectigoAWSCM-dynamodb" {
  source = "./modules/dynamodb"
  table_name =  "SectigoAWSCM-${terraform.workspace}"
} 

# Main Lambda Function Module
module "SectigoAWSCM-lambda" {
  source          = "./modules/lambda"
  function_name   = "SectigoAWSCM-${terraform.workspace}"
  role_arn        = module.SectigoAWSCM-iam.SectigoAWSCM-role-arn-output
  exist_role_name = module.SectigoAWSCM-iam.SectigoAWSCM-role-name-output
  sectigo_bucket  = var.sectigo_bucket
  table_name =  "SectigoAWSCM-${terraform.workspace}"
}

# Rest API-Gateway Function Module
module "SectigoAWSCM-API-gw" {
  source               = "./modules/api-gateway"
  swagger_file         = data.template_file.SectigoAWSCM-api-gw-template.rendered
  lambda_function_name = "SectigoAWSCM-${terraform.workspace}"
}

data "template_file" "SectigoAWSCM-api-gw-template" {
  template = file("./files/swagger.json")
  vars = {
    get_lambda_arn = "${module.SectigoAWSCM-lambda.SectigoAWSCM-lambda-arn-output}"
    aws_region = "${terraform.workspace}"
  }
}

