#!/bin/bash
suffix=$(date +%s)
export TF_LOG=TRACE
export TF_LOG_PATH="tofu-install.txt"
check_aws_credentials(){
  export AWS_ACCESS_KEY_ID=`aws configure get default.aws_access_key_id`
  export AWS_SECRET_ACCESS_KEY=`aws configure get default.aws_secret_access_key`
  export AWS_DEFAULT_REGION=`aws configure get default.region`
    if [ -z ${AWS_DEFAULT_REGION} ] || [ -z ${AWS_SECRET_ACCESS_KEY} ] || [ -z ${AWS_ACCESS_KEY_ID} ]
    then
        echo "AWS environment variables does not exist. Please set these variables and then run script"
        exit 1
    fi 
}

check_region_availability(){
  [[ -z "$1" ]] && r="$AWS_DEFAULT_REGION" || r="$1"
  regions=($(aws ec2 describe-regions | grep -i "$regionname" | awk '{print $2}' | tr -d '",'))
  if ! printf '%s\n' "${regions[@]}" | grep -qx "$r"; then
    echo "You are trying to deploy SectigoAWSCM to non-existent AWS region or this region is not available for your account"
    exit 0
  fi
}

# Configure Backend s3 bucket
configure_backend() {
  default_bucket_name=$(cat main.tf | grep -A 1 -i backend | grep bucket | cut -d"=" -f2 | tr -d '""')
  backend_region=$(cat main.tf | grep region | head -1 | awk '{print $3}' |tr -d '"')
  backend_bucket_name="sectigo-tf-state-$suffix"
  if [ "$default_bucket_name" == " sectigo-aws-cm-tf-states" ]
  then
    sed -i "s/sectigo-aws-cm-tf-states/${backend_bucket_name}/g" main.tf
   sed -i "s/$backend_region/$AWS_DEFAULT_REGION/" main.tf
    aws s3 mb s3://$backend_bucket_name --region "$AWS_DEFAULT_REGION"
  fi
  tofu init
}
# # Configure s3 bucket for accounts
configure_bucket() {
  WORK_SPACE=$1
    if [[ -z "$WORK_SPACE" ]]; then
      WORK_SPACE="$AWS_DEFAULT_REGION"
    fi
  echo 'sectigo_bucket = "'"sectigo-aws-cm-$WORK_SPACE-$suffix"'"' > $WORK_SPACE-tofu.tfvars
}

# # Configure Workspace for region
configure_workspace(){
  WORK_SPACE=$1
    if [[ -z "$WORK_SPACE" ]]; then
      WORK_SPACE="$AWS_DEFAULT_REGION"
    fi
    configure_backend $WORK_SPACE
    tofu workspace select $WORK_SPACE || tofu workspace new $WORK_SPACE
}
# Check existing infrastructure
check_infrastructure(){
  WORK_SPACE=$1
    if [[ -z "$WORK_SPACE" ]]; then
      WORK_SPACE="$AWS_DEFAULT_REGION"
    fi
    aws s3 ls | grep "sectigo-aws-cm-$WORK_SPACE" > /dev/null
    if [ $? -eq 0 ]
    then 
      echo "SectigoAWSCM is already installed to $WORK_SPACE region..."
      exit 0
    fi
}

# # tofu Execute
tofu_execute(){
    check_infrastructure $1
    configure_bucket $1
    configure_workspace $1 && tofu plan && tofu apply -auto-approve -var-file="$WORK_SPACE-tofu.tfvars"
    tofu output > install-$WORK_SPACE.log
    if [ $? -eq 0 ]; 
    then
      echo Finish with success...
      aws s3 cp acme_accounts.yaml s3://sectigo-aws-cm-$WORK_SPACE-$suffix/
    else
      echo "Something is wrong... tofu will delete failed resources"
      sleep 3
      chmod +x destroy.sh && ./destroy.sh $1
      echo "Run install.sh script again please..."
    fi
}
check_aws_credentials
check_region_availability $1
tofu_execute $1
