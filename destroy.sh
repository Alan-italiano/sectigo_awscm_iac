#!/bin/bash
export TF_LOG=TRACE
export TF_LOG_PATH="tofu-uninstall.txt"
# Check AWS Credentials
check_aws_credentials(){
    export AWS_ACCESS_KEY_ID=`aws configure get default.aws_access_key_id`
    export AWS_SECRET_ACCESS_KEY=`aws configure get default.aws_secret_access_key`
    export AWS_DEFAULT_REGION=`aws configure get default.region`
    echo AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}
    echo AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}
    echo AWS_DEFAULT_REGION=${AWS_DEFAULT_REGION}
    if [ -z ${AWS_DEFAULT_REGION} ] || [ -z ${AWS_SECRET_ACCESS_KEY} ] || [ -z ${AWS_ACCESS_KEY_ID} ]
    then
        echo "AWS environment variables does not exist. Please set these variables and then run script"
        exit 1
    fi 
}

# Chose region which you want to delete SectigoAWSCM from
region_choosing(){
    WORK_SPACE=$1
    if [[ -z "$WORK_SPACE" ]]; then
      WORK_SPACE="$AWS_DEFAULT_REGION"
    fi
}

# Clear s3 bucket for acme_account.yaml
bucket_cleaning(){
    region_choosing $1
    aws s3 ls | grep  sectigo-aws-cm-$WORK_SPACE | awk '{print $3}' | while read bucket_name
    do
        aws s3 rm s3://$bucket_name --recursive
    done
}

# Destroy Process
destroy_sectigo_aws_cm(){
    region_choosing $1
    tofu workspace select $WORK_SPACE
    tofu apply -destroy -auto-approve
    rm -rf install-$WORK_SPACE.log
    rm -rf $WORK_SPACE-tofu.tfvars
}

check_aws_credentials
tofu init && bucket_cleaning $1 && destroy_sectigo_aws_cm $1
