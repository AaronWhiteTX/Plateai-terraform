# PlateAI Terraform Infrastructure

Complete Infrastructure as Code for the live PlateAI production application.

**Live Application**: [plateai.cloud](https://plateai.cloud)  
**Main Repository**: [github.com/AaronWhiteTX/plateai](https://github.com/AaronWhiteTX/plateai)  
**Deployment Guide**: [DEPLOYMENT.md](https://github.com/AaronWhiteTX/plateai/blob/main/DEPLOYMENT.md)

---

## Overview

This repository contains Terraform configuration for 26 AWS resources that power PlateAI. The infrastructure was **imported from the live production environment** with zero downtime and zero changes applied, demonstrating the ability to bring existing cloud resources under Infrastructure as Code management.

**Status**: `terraform plan` shows no changes needed - complete alignment between code and live environment.

---

## Resources Managed (26 Total)

### Compute & API
- **Lambda Function**: Python 3.12 (FoodIdentifierProcessor)
- **API Gateway**: REST API with Lambda proxy integration
- **API Gateway Methods**: POST, OPTIONS (CORS support)
- **API Gateway Stage**: Production deployment
- **Lambda Permission**: API Gateway invoke access

### Storage
- **DynamoDB Tables** (5):
  - `users` - User accounts and preferences
  - `meals` - Analyzed food history
  - `recipes` - AI-generated recipe alternatives
  - `dailyPlans` - Meal planning data
  - `conversations` - AI coach chat history (90-day TTL)
- **S3 Buckets** (2):
  - Photos bucket (public read, stores food images)
  - Frontend bucket (website hosting)
- **S3 Bucket Policies** (2): Public read access configuration
- **S3 Website Configuration**: Static site hosting for frontend

### CDN & Security
- **CloudFront Distribution**: Global CDN for plateai.cloud
- **ACM Certificate**: SSL/TLS for HTTPS (plateai.cloud, www.plateai.cloud)

### IAM & Monitoring
- **IAM Role**: Lambda execution role
- **IAM Policy Attachments** (4):
  - AWSLambdaBasicExecutionRole (CloudWatch logging)
  - AmazonDynamoDBFullAccess (database operations)
  - AmazonS3FullAccess (photo storage)
  - AmazonBedrockFullAccess (AI model access)
- **CloudWatch Log Group**: Lambda function logs (7-day retention)

**Note on IAM Permissions**: This portfolio project uses AWS managed policies (FullAccess) for rapid prototyping. Production deployment would require custom policies with least-privilege access scoped to specific resources (e.g., DynamoDB actions limited to the 5 application tables, S3 access restricted to the two application buckets).

---

## Key Features

### Import from Production
- All resources imported from running application
- Zero infrastructure changes during import
- Proves Terraform manages actual production environment

### Automated Deployment
- `deploy.sh` script handles Lambda packaging and deployment
- One-command infrastructure provisioning
- Clean teardown with `terraform destroy`

### Cost Control
- Infrastructure designed for $1-3/month operation
- Complete cleanup capability (zero residual costs)
- On-demand billing for all resources

---

## Prerequisites

- AWS CLI configured with valid credentials
- Terraform >= 1.0 installed
- Lambda source code from main repository

---

## Quick Start

### Deploy to Your AWS Account
```bash
# 1. Clone this repository
git clone https://github.com/AaronWhiteTX/Plateai-terraform.git
cd Plateai-terraform

# 2. Clone Lambda source
git clone https://github.com/AaronWhiteTX/plateai.git ../plateai

# 3. Update main.tf with your unique bucket names
# Edit lines with "foodidentifier-730980070158-photos" 
# and "plateai-frontend-730980070158"

# 4. Deploy infrastructure
./deploy.sh
```

### Manual Deployment
```bash
# Package Lambda
wget https://raw.githubusercontent.com/AaronWhiteTX/plateai/main/lambda_function.py
zip lambda.zip lambda_function.py

# Deploy infrastructure
terraform init
terraform plan
terraform apply
```

---

## Repository Structure
```
.
├── .gitignore              # Excludes .terraform/, build artifacts
├── .terraform.lock.hcl     # Terraform dependency lock
├── main.tf                 # Complete infrastructure definition
├── terraform.tfstate       # Current state (tracks live AWS)
├── deploy.sh              # Automated deployment script
└── README.md              # This file
```

---

## Verification

After import, verify Terraform manages the live environment:
```bash
terraform plan
# Expected output: "No changes. Your infrastructure matches the configuration."
```

This confirms:
- All 26 resources successfully imported
- Terraform state matches live AWS environment
- No drift between code and production

---

## Cleanup

Complete infrastructure teardown:
```bash
# Empty S3 buckets (required before deletion)
aws s3 rm s3://YOUR-PHOTOS-BUCKET --recursive
aws s3 rm s3://YOUR-FRONTEND-BUCKET --recursive

# Destroy all resources
terraform destroy
```

Result: Zero residual cost, all resources deleted.

---

## Production Improvements

For enterprise deployment, the following enhancements are recommended:

### Security
- Replace AWS managed FullAccess policies with custom least-privilege IAM policies
- Implement resource-level permissions (specific DynamoDB tables, S3 buckets)
- Add KMS encryption for data at rest
- Enable CloudTrail for audit logging
- Implement WAF rules for API Gateway

### Reliability
- Multi-region deployment for disaster recovery
- DynamoDB global tables for cross-region replication
- Lambda reserved concurrency limits
- CloudWatch alarms for error rates and latency

### Operations
- Remote state backend (S3 + DynamoDB state locking)
- Terraform workspaces for dev/staging/prod environments
- CI/CD pipeline integration (GitHub Actions, AWS CodePipeline)
- Automated testing with Terratest

---

## Technical Demonstrations

This repository showcases:

- **Infrastructure as Code**: Complete production environment defined in code
- **Import Workflows**: Bringing existing resources under Terraform management
- **Zero-Downtime Operations**: Import with no service interruption
- **Cost Optimization**: Resource selection for minimal monthly spend
- **Automation**: Scripted deployment and teardown processes
- **State Management**: Proper handling of Terraform state for live environments

---

**Related Repositories**:
- Application Code: [github.com/AaronWhiteTX/plateai](https://github.com/AaronWhiteTX/plateai)
- Deployment Guide: [DEPLOYMENT.md](https://github.com/AaronWhiteTX/plateai/blob/main/DEPLOYMENT.md)

**Last Updated**: November 30, 2024  
**Status**: Production-Ready (Portfolio Demonstration)
