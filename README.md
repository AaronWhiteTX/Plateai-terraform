# PlateAI Terraform Infrastructure

Terraform IaC for PlateAI production infrastructure (26 AWS resources imported from live environment).

## Resources Managed
Lambda, DynamoDB (5 tables), S3 (2 buckets), API Gateway, CloudFront, IAM, ACM

## Prerequisites
- AWS CLI configured
- Terraform >= 1.0
- Lambda source: https://github.com/AaronWhiteTX/plateai

## Deployment

### Automated
```bash
# Clone Lambda source
git clone https://github.com/AaronWhiteTX/plateai.git ../plateai

# Deploy infrastructure
./deploy.sh
```

### Manual
```bash
# Get Lambda code
wget https://raw.githubusercontent.com/AaronWhiteTX/plateai/main/lambda_function.py
zip lambda.zip lambda_function.py

# Deploy
terraform init
terraform plan
terraform apply
```

## Files
- main.tf - Infrastructure definition
- terraform.tfstate - Live state
- .terraform.lock.hcl - Dependencies
- deploy.sh - Deployment automation
