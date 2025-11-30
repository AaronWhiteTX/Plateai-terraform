# PlateAI Terraform Infrastructure

Terraform IaC for PlateAI production infrastructure (26 AWS resources imported from live environment).

## Resources Managed
- **Lambda**: FoodIdentifierProcessor (Python 3.12)
- **DynamoDB**: 5 tables (users, meals, recipes, dailyPlans, conversations)
- **S3**: 2 buckets (photos + frontend hosting)
- **API Gateway**: REST API with Lambda integration
- **CloudFront**: CDN with custom domain (plateai.cloud)
- **IAM**: Lambda execution role with Bedrock/DynamoDB/S3 access
- **ACM**: SSL certificate for HTTPS

## Prerequisites
- AWS CLI configured (`aws configure`)
- Terraform >= 1.0
- Lambda source code in `../plateai/lambda_function.py`

## Deployment

### Automated (Recommended)
```bash
./deploy.sh
```

### Manual
```bash
# 1. Package Lambda
cp ../plateai/lambda_function.py .
zip lambda.zip lambda_function.py

# 2. Deploy infrastructure
terraform init
terraform plan
terraform apply
```

## Status
- Imported from production - manages live infrastructure
- terraform plan shows minimal drift
- Rate limits: 2 photos, 3 AI questions, 3 recipes per day

## Cost Protection
- Daily rate limits via frontend
- Bedrock usage: ~$1-3/month
- All other services: AWS free tier

## Repository Structure
```
.
├── .gitignore
├── .terraform.lock.hcl  # Terraform dependency lock
├── main.tf              # Infrastructure definition
├── terraform.tfstate    # Current state (tracks live AWS)
├── deploy.sh           # Automated deployment script
└── README.md           # This file
```
