terraform {
  backend "s3" {
    bucket = "plateai-terraform-state"
    key    = "terraform.tfstate"
    region = "us-east-1"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# Lambda Function
resource "aws_lambda_function" "plateai" {
  function_name = "FoodIdentifierProcessor"
  role          = aws_iam_role.lambda_role.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.12"
  timeout       = 30
  memory_size   = 128

  lifecycle {
    ignore_changes = [
      filename,
      source_code_hash,
      last_modified
    ]
  }

  environment {
    variables = {
      DEBUG = "true"
    }
  }
}

# DynamoDB Tables
resource "aws_dynamodb_table" "users" {
  name         = "users"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "userId"

  attribute {
    name = "userId"
    type = "S"
  }

  ttl {
    enabled = false
  }
}

resource "aws_dynamodb_table" "meals" {
  name         = "meals"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "userId"
  range_key    = "mealId"

  attribute {
    name = "userId"
    type = "S"
  }

  attribute {
    name = "mealId"
    type = "S"
  }

  ttl {
    enabled = false
  }
}

resource "aws_dynamodb_table" "recipes" {
  name         = "recipes"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "userId"
  range_key    = "recipeId"

  attribute {
    name = "userId"
    type = "S"
  }

  attribute {
    name = "recipeId"
    type = "S"
  }

  ttl {
    enabled = false
  }
}

resource "aws_dynamodb_table" "daily_plans" {
  name         = "dailyPlans"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "userId"
  range_key    = "date"

  attribute {
    name = "userId"
    type = "S"
  }

  attribute {
    name = "date"
    type = "S"
  }

  ttl {
    enabled        = true
    attribute_name = "expiryTime"
  }
}

resource "aws_dynamodb_table" "conversations" {
  name         = "conversations"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "userId"
  range_key    = "timestamp"

  attribute {
    name = "userId"
    type = "S"
  }

  attribute {
    name = "timestamp"
    type = "S"
  }

  ttl {
    enabled        = true
    attribute_name = "expiryTime"
  }
}

# S3 Buckets
resource "aws_s3_bucket" "photos" {
  bucket = "foodidentifier-730980070158-photos"
}

resource "aws_s3_bucket" "frontend" {
  bucket = "plateai-frontend-730980070158"
}

# S3 Bucket Policies
resource "aws_s3_bucket_policy" "photos" {
  bucket = aws_s3_bucket.photos.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid       = "PublicReadGetObject"
      Effect    = "Allow"
      Principal = "*"
      Action    = "s3:GetObject"
      Resource  = "${aws_s3_bucket.photos.arn}/*"
    }]
  })
}

resource "aws_s3_bucket_policy" "frontend" {
  bucket = aws_s3_bucket.frontend.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = "*"
      Action    = "s3:GetObject"
      Resource  = "${aws_s3_bucket.frontend.arn}/*"
    }]
  })
}

# S3 Website Configuration
resource "aws_s3_bucket_website_configuration" "frontend" {
  bucket = aws_s3_bucket.frontend.id

  index_document {
    suffix = "index.html"
  }
}

# API Gateway
resource "aws_api_gateway_rest_api" "plateai" {
  name = "FoodIdentifierAPI"

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_resource" "root" {
  rest_api_id = aws_api_gateway_rest_api.plateai.id
  parent_id   = aws_api_gateway_rest_api.plateai.root_resource_id
  path_part   = "food"

  lifecycle {
    ignore_changes = [
      path_part,
      parent_id
    ]
  }
}

resource "aws_api_gateway_method" "post" {
  rest_api_id   = aws_api_gateway_rest_api.plateai.id
  resource_id   = aws_api_gateway_resource.root.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_method" "options" {
  rest_api_id   = aws_api_gateway_rest_api.plateai.id
  resource_id   = aws_api_gateway_resource.root.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda" {
  rest_api_id             = aws_api_gateway_rest_api.plateai.id
  resource_id             = aws_api_gateway_resource.root.id
  http_method             = aws_api_gateway_method.post.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.plateai.invoke_arn
}

resource "aws_api_gateway_deployment" "latest" {
  rest_api_id = aws_api_gateway_rest_api.plateai.id

  depends_on = [
    aws_api_gateway_integration.lambda
  ]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "prod" {
  deployment_id = aws_api_gateway_deployment.latest.id
  rest_api_id   = aws_api_gateway_rest_api.plateai.id
  stage_name    = "prod"
}

# CloudFront Distribution
resource "aws_cloudfront_distribution" "plateai" {
  enabled         = true
  is_ipv6_enabled = true
  comment         = "PlateAI Frontend"
  price_class     = "PriceClass_All"

  aliases = ["plateai.cloud", "www.plateai.cloud"]

  origin {
    domain_name = aws_s3_bucket.frontend.website_endpoint
    origin_id   = "S3Origin"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1", "TLSv1.1", "TLSv1.2"]
    }
  }

  default_cache_behavior {
    target_origin_id       = "S3Origin"
    viewer_protocol_policy = "allow-all"
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    compress               = false

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    min_ttl     = 0
    default_ttl = 86400
    max_ttl     = 31536000
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate.plateai.arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.3_2025"
  }
}

# ACM Certificate
resource "aws_acm_certificate" "plateai" {
  domain_name               = "plateai.cloud"
  subject_alternative_names = ["www.plateai.cloud"]
  validation_method         = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

# IAM Role
resource "aws_iam_role" "lambda_role" {
  name        = "FoodIdentifierAppRole"
  description = "Allows Lambda functions to call AWS services on your behalf."

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

# IAM Policy Attachments
resource "aws_iam_role_policy_attachment" "lambda_basic" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "dynamodb" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
}

resource "aws_iam_role_policy_attachment" "s3" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_role_policy_attachment" "bedrock" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonBedrockFullAccess"
}

# Lambda Permission for API Gateway
resource "aws_lambda_permission" "api_gateway" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.plateai.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.plateai.execution_arn}/*"
}

# CloudWatch Log Group
resource "aws_cloudwatch_log_group" "lambda_logs" {
  name              = "/aws/lambda/FoodIdentifierProcessor"
  retention_in_days = 0

  lifecycle {
    ignore_changes = [
      retention_in_days
    ]
  }
}