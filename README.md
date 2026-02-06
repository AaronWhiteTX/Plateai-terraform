
# PlateAI Infrastructure (Terraform)

Infrastructure as Code for PlateAI - complete AWS serverless stack managed with Terraform.

**Live Application:** [plateai.cloud](https://plateai.cloud)
**Main Repository:** [github.com/AaronWhiteTX/PlateAI](https://github.com/AaronWhiteTX/PlateAI)

![Terraform CI/CD](https://github.com/AaronWhiteTX/Plateai-terraform/actions/workflows/ci.yml/badge.svg)

---

## What This Manages

26 AWS resources for the PlateAI production environment in us-east-1:

**Compute & API**
- Lambda: FoodIdentifierProcessor (Python 3.12, 128MB, 30s timeout)
- API Gateway: FoodIdentifierAPI (s8w5yfkidb) with Lambda proxy integration
- IAM Role: FoodIdentifierAppRole with DynamoDB, S3, Bedrock permissions
- CloudWatch Log Group: /aws/lambda/FoodIdentifierProcessor (7-day retention)

**Storage**
- DynamoDB tables (5): users, meals, recipes, dailyPlans, conversations (90-day TTL)
- S3 buckets (2): foodidentifier-730980070158-photos, plateai-frontend-730980070158

**CDN & Security**
- CloudFront: d1ws39rn0mdavv.cloudfront.net (global CDN)
- ACM certificate: SSL/TLS for plateai.cloud

**See the [main PlateAI repository](https://github.com/AaronWhiteTX/PlateAI) for architecture diagrams, feature details, and usage documentation.**

---

## CI/CD Pipeline

This repository includes a full CI/CD pipeline using GitHub Actions:

| Trigger | What Happens |
|---------|--------------|
| Push to main | fmt check, validate, plan, apply |
| Pull request | fmt check, validate, plan (no apply) |

**Pipeline Steps:**
- terraform fmt -check: Validates code formatting
- terraform validate: Checks syntax
- terraform plan: Previews changes
- terraform apply: Deploys to production (main branch only)

**State Management:**
- Remote state stored in S3
- Enables safe CI/CD deployments
- Single source of truth for infrastructure state

---

## Quick Start

```bash
git clone https://github.com/AaronWhiteTX/Plateai-terraform.git
cd Plateai-terraform
terraform init
terraform plan
terraform apply
```

Update bucket names in main.tf to be globally unique before applying.

---

## Import from Production

This infrastructure was imported from the live PlateAI environment with zero downtime.

Example import commands used:

```bash
terraform import aws_lambda_function.food_processor FoodIdentifierProcessor
terraform import aws_dynamodb_table.users users
terraform import aws_dynamodb_table.meals meals
terraform import aws_dynamodb_table.recipes recipes
terraform import aws_dynamodb_table.daily_plans dailyPlans
terraform import aws_dynamodb_table.conversations conversations
terraform import aws_s3_bucket.photos foodidentifier-730980070158-photos
terraform import aws_s3_bucket.frontend plateai-frontend-730980070158
terraform import aws_api_gateway_rest_api.api s8w5yfkidb
terraform import aws_cloudfront_distribution.cdn E2D4G621UQDPM6
```

26 resources total. Complete state alignment between Terraform and production AWS environment.

---

## Key Features

**CI/CD Pipeline**
- Automated validation on every push
- Infrastructure deploys automatically on merge to main
- Pull requests run plan without applying
- Remote state in S3 for safe deployments

**Infrastructure as Code**
- 100% of PlateAI infrastructure defined in Terraform HCL
- Reproducible deployment with one command
- Complete teardown capability with terraform destroy
- Version-controlled infrastructure changes via Git

**Import Workflow**
- All 26 resources imported from running production application
- Zero downtime during import process
- Demonstrates ability to bring existing cloud resources under IaC management

**Cost Optimization**
- Resources selected for $1-3/month operation
- On-demand pricing: DynamoDB, Lambda, Bedrock
- Lambda right-sized: 128MB memory
- DynamoDB TTL: Automatic cleanup of 90-day-old conversation data

---

## Repository Structure

```
.
├── .github/
│   └── workflows/
│       └── ci.yml
├── main.tf
├── .terraform.lock.hcl
├── .gitignore
├── deploy.sh
└── README.md
```

---

## What This Demonstrates

**CI/CD and DevOps**
- Full CI/CD pipeline with GitHub Actions
- Automated infrastructure deployment on merge
- Remote state management with S3
- Safe PR workflow with plan only

**Terraform Expertise**
- Multi-service AWS infrastructure definition
- Resource import from existing production environments
- State management for live systems
- Zero-drift configuration

**Cloud Architecture**
- Serverless architecture design across 8 AWS services
- Cost-aware resource selection and sizing
- Security configuration with IAM roles
- CDN and custom domain setup

---

## Future Improvements

**Security**
- Replace AWS managed FullAccess policies with least-privilege custom policies
- Add KMS encryption for data at rest
- Enable AWS WAF for API Gateway protection

**Operations**
- DynamoDB state locking for team collaboration
- Terraform workspaces for dev/staging/prod environments
- Automated testing with Terratest

**Reliability**
- Multi-region deployment for disaster recovery
- CloudWatch alarms for error rates and latency
- DynamoDB PITR for backup and restore

---

**Related Repositories:**
- Application Code: [github.com/AaronWhiteTX/PlateAI](https://github.com/AaronWhiteTX/PlateAI)

**Last Updated:** February 2026
**Status:** Production-Ready
```

---

## What I Fixed

| Issue | Fix |
|-------|-----|
| Bash code block bleeding | Closed code blocks properly |
| Simplified formatting | Removed nested backticks |
| Cleaner structure | Less clutter |

---
