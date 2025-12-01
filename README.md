# PlateAI Infrastructure (Terraform)

Infrastructure as Code for PlateAI - complete AWS serverless stack managed with Terraform.

**Live Application:** [plateai.cloud](https://plateai.cloud)  
**Main Repository:** [github.com/AaronWhiteTX/PlateAI](https://github.com/AaronWhiteTX/PlateAI)

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

## Quick Start
```bash
git clone https://github.com/AaronWhiteTX/Plateai-terraform.git
cd Plateai-terraform

# Update bucket names in main.tf to be globally unique
# Replace: foodidentifier-730980070158-photos
# Replace: plateai-frontend-730980070158

terraform init
terraform plan
terraform apply

# Complete teardown (zero residual cost)
terraform destroy
```

---

## Import from Production

This infrastructure was imported from the live PlateAI environment with zero downtime:
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
# ... (26 resources total)
```

**Verification:**
```bash
terraform plan
# Output: "No changes. Your infrastructure matches the configuration."
```

This confirms complete state alignment between Terraform and production AWS environment.

---

## Key Features

**Infrastructure as Code**
- 100% of PlateAI infrastructure defined in Terraform HCL
- Reproducible deployment with one command: `terraform apply`
- Complete teardown capability: `terraform destroy` (zero residual cost)
- Version-controlled infrastructure changes via Git

**Import Workflow**
- All 26 resources imported from running production application
- Zero downtime during import process
- No infrastructure changes applied during import
- Demonstrates ability to bring existing cloud resources under IaC management

**Cost Optimization**
- Resources selected for $1-3/month operation
- On-demand pricing: DynamoDB, Lambda, Bedrock (pay per use)
- Lambda right-sized: 128MB memory (75% savings vs default 512MB)
- DynamoDB TTL: Automatic cleanup of 90-day-old conversation data
- Complete infrastructure cleanup via single destroy command

---

## Repository Structure
```
.
├── main.tf                 # Complete infrastructure definition (26 resources)
├── terraform.tfstate       # Current state (tracks live AWS environment)
├── .terraform.lock.hcl     # Terraform provider version lock
├── .gitignore              # Excludes .terraform/, build artifacts
├── deploy.sh               # Automated Lambda packaging and deployment
└── README.md               # This file
```

---

## What This Demonstrates

**Terraform Expertise**
- Multi-service AWS infrastructure definition (Lambda, DynamoDB, S3, API Gateway, CloudFront, IAM)
- Resource import from existing production environments
- State management for live systems
- Zero-drift configuration (code matches production exactly)

**Cloud Architecture**
- Serverless architecture design (26 resources across 8 AWS services)
- Cost-aware resource selection and sizing
- Security configuration (IAM roles, CloudWatch logging)
- CDN and custom domain setup

**DevOps Practices**
- Infrastructure as Code with Terraform
- Reproducible deployments
- Automated provisioning and teardown
- Separation of infrastructure code from application code

---

## Production Improvements

For enterprise deployment, consider these enhancements:

**Security**
- Replace AWS managed FullAccess policies with least-privilege custom policies
- Implement resource-specific IAM permissions (limit to 5 DynamoDB tables, 2 S3 buckets)
- Add KMS encryption for data at rest
- Enable AWS WAF for API Gateway protection

**Operations**
- Remote state backend (S3 + DynamoDB state locking)
- Terraform workspaces for dev/staging/prod environments
- CI/CD pipeline integration (GitHub Actions)
- Automated testing with Terratest

**Reliability**
- Multi-region deployment for disaster recovery
- CloudWatch alarms for error rates and latency
- Lambda reserved concurrency limits
- DynamoDB PITR for backup and restore

---

**Related Repositories:**
- Application Code: [github.com/AaronWhiteTX/PlateAI](https://github.com/AaronWhiteTX/PlateAI)
- Architecture & Features: See main repository README

**Last Updated:** November 30, 2025
**Status:** Production-Ready (manages live plateai.cloud infrastructure)
```


- Emphasized Terraform expertise and DevOps practices
