#!/bin/bash
# Deployment script for PlateAI infrastructure

set -e

echo "=== PlateAI Infrastructure Deployment ==="

# 1. Package Lambda function
echo "Packaging Lambda function..."
if [ ! -f "../plateai/lambda_function.py" ]; then
    echo "Error: lambda_function.py not found in ../plateai/"
    exit 1
fi

cp ../plateai/lambda_function.py .
zip -q lambda.zip lambda_function.py
rm lambda_function.py
echo "Lambda packaged"

# 2. Initialize Terraform
echo "Initializing Terraform..."
terraform init
echo "Terraform initialized"

# 3. Plan changes
echo "Planning infrastructure changes..."
terraform plan -out=tfplan
echo "Plan created"

# 4. Prompt for apply
read -p "Apply changes? (yes/no): " confirm
if [ "$confirm" = "yes" ]; then
    terraform apply tfplan
    rm tfplan
    echo "Deployment complete"
else
    echo "Deployment cancelled"
    rm tfplan
fi
