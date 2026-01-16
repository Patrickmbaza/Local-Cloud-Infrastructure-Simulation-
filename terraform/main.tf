# This file ties all modules together
terraform {
  backend "local" {
    path = "terraform.tfstate"
  }
}

# Data source to get LocalStack availability
data "aws_availability_zones" "available" {
  state = "available"
}

# Tag all resources consistently
locals {
  common_tags = {
    Project     = "IaC-Demo"
    Environment = var.environment
    ManagedBy   = "Terraform"
    Repository  = "terraform-localstack-demo"
  }
}