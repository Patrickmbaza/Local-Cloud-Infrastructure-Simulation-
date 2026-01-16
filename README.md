Infrastructure-as-Code Demo with Terraform & LocalStack
🚀 Project Overview

A complete Infrastructure-as-Code (IaC) demonstration that provisions AWS cloud resources locally using Terraform and LocalStack. Deploy a production-like environment with VPC networking, EC2 compute instances, S3 storage, and IAM security - all running on your local machine with zero cloud costs.

Perfect for: Learning IaC principles, AWS service demonstrations, technical interviews, or workshop training.
📁 Project Structure
text

.
├── README.md                   # This documentation file
├── destroy.sh                  # Safe infrastructure cleanup script
├── docker-compose.yml          # LocalStack & NGINX container orchestration
├── s3-demo.sh                  # Interactive S3 operations demonstration
└── terraform/                  # Infrastructure as Code definitions
    ├── main.tf                 # Core Terraform configuration
    ├── provider.tf            # AWS provider setup for LocalStack
    ├── variables.tf           # Configurable input variables
    ├── vpc.tf                 # Virtual Private Cloud networking
    ├── ec2.tf                 # Compute resources (EC2 instances)
    ├── s3.tf                  # Storage resources (S3 buckets & objects)
    ├── outputs.tf             # Output values display
    ├── terraform.tfstate      # Terraform state file (auto-generated)
    ├── terraform.tfstate.backup # State backup (auto-generated)
    └── web-app/               # Demo web application
        └── index.html         # Interactive frontend with real-time monitoring

🎯 What This Demo Creates
Infrastructure Stack

    🌐 VPC Network (10.0.0.0/16)

        Public subnet (10.0.1.0/24)

        Internet Gateway for external connectivity

        Route tables and security groups

        Custom security rules (HTTP/SSH access)

    🖥️ EC2 Instance (Simulated)

        t2.micro instance type

        Security group with proper ingress/egress rules

        User data initialization script

        Public IP assignment (conceptual demonstration)

    📦 S3 Storage

        Bucket: demo-logs-bucket

        Pre-populated log files (access.log, error.log)

        Versioning enabled (with LocalStack workarounds)

        IAM roles for secure S3 access

    🔐 IAM Security

        EC2 instance profile

        S3 write permissions policy

        Role-based access control demonstration

    🌐 Web Application

        NGINX container serving static content

        Interactive dashboard at http://localhost:8888

        Real-time service status monitoring

🚀 Quick Start - 3 Minute Setup
Prerequisites

    Docker & Docker Compose (Install Guide)

    Terraform CLI ≥ v1.0 (Install Guide)

    AWS CLI (optional, for enhanced S3 demos)

One-Command Deployment
bash

# Clone/download the project, then:
cd Infrastructure-project

# Start everything with our automated script
./s3-demo.sh

Expected Output:
text

✅ LocalStack running on http://localhost:4566
✅ Terraform initialized successfully
✅ Infrastructure deployed: VPC, EC2, S3, IAM
✅ Web application: http://localhost:8080
✅ S3 bucket ready: demo-logs-bucket

🎬 Interactive Demo Walkthrough
Step 1: Launch the Environment
bash

# Start LocalStack (AWS emulator) and NGINX
docker-compose up -d

# Verify services are healthy
curl http://localhost:4566/_localstack/health | grep s3
# Should show: "s3": "running"

Step 2: Deploy Infrastructure with Terraform
bash

cd terraform

# Initialize Terraform (first time only)
terraform init

# See what will be created
terraform plan

# Deploy everything with one command
terraform apply -auto-approve

Expected Terraform Output:
text

Apply complete! Resources: 14 added, 0 changed, 0 destroyed.

Outputs:
vpc_id = "vpc-xxxxxxxx"
web_server_id = "i-xxxxxxxx"
s3_bucket_name = "demo-logs-bucket"
web_app_url = "http://localhost:8080"

Step 3: Explore the Web Application

Open your browser to: http://localhost:8080

You'll see an interactive dashboard showing:

    Real-time service status (LocalStack, S3, EC2)

    Infrastructure architecture diagram

    Live S3 bucket contents

    Terraform code examples

    Interactive demo buttons

Step 4: Demonstrate S3 Operations
bash

# Return to project root and run the S3 demo
cd ..
chmod +x s3-demo.sh
./s3-demo.sh

Or run commands manually:
bash

# List all S3 buckets
aws --endpoint-url=http://localhost:4566 s3 ls

# See bucket contents
aws --endpoint-url=http://localhost:4566 s3 ls s3://demo-logs-bucket/ --recursive

# Upload a test file
echo "Live demo upload at $(date)" > demo.txt
aws --endpoint-url=http://localhost:4566 s3 cp demo.txt s3://demo-logs-bucket/

# Verify upload
aws --endpoint-url=http://localhost:4566 s3 ls s3://demo-logs-bucket/

Step 5: Show Terraform Code Structure

Explain each file's purpose during your demo:
bash

cd terraform
ls -la *.tf

File	Purpose	Key Feature Demonstrated
provider.tf	LocalStack configuration	Mock AWS endpoints
variables.tf	Input parameters	Configurable infrastructure
vpc.tf	Networking setup	VPC, subnets, security groups
ec2.tf	Compute resources	EC2 instances, security
s3.tf	Storage configuration	Buckets, versioning, IAM
outputs.tf	Display outputs	Resource information export
Step 6: Clean Up (Important!)
bash

# Use the safe cleanup script
./destroy.sh

# Or manually:
cd terraform
terraform destroy -auto-approve
cd ..
docker-compose down

🔧 Key Files Explained
docker-compose.yml
yaml

services:
  localstack:
    image: localstack/localstack:3.0
    ports:
      - "4566:4566"    # AWS API endpoints
      - "8091:8080"    # Web UI (optional)
    environment:
      - SERVICES=s3,ec2,iam,sts,vpc  # Only needed AWS services
      
  nginx:
    image: nginx:alpine
    ports:
      - "8888:80"      # Web app (NOTE: Changed from 8080 due to Jenkins conflict)
    volumes:
      - "./terraform/web-app:/usr/share/nginx/html"


provider "aws" {
  region = "us-east-1"
  access_key = "test"      # LocalStack mock credentials
  secret_key = "test"
  
  # LocalStack-specific configuration
  skip_credentials_validation = true
  s3_use_path_style = true
  
  endpoints {
    s3  = "http://localhost:4566"
    ec2 = "http://localhost:4566"
  }
}

Critical: The endpoints block redirects AWS API calls to LocalStack instead of real AWS.
terraform/s3.tf
hcl

resource "aws_s3_bucket" "logs_bucket" {
  bucket = "demo-logs-bucket"
  force_destroy = true  # Allows deletion of non-empty buckets
  
  tags = {
    Purpose = "web-server-logs"
  }
}

resource "aws_s3_object" "sample_log" {
  bucket = aws_s3_bucket.logs_bucket.id
  key    = "logs/access.log"
  content = "2024-01-01 GET /index.html 200"  # Content created inline
}

Note: force_destroy = true is essential for LocalStack demos to avoid "BucketNotEmpty" errors.
destroy.sh
bash

#!/bin/bash
# Safe cleanup script that handles LocalStack quirks

echo "🧹 Starting safe cleanup..."
cd terraform

# Empty S3 bucket first (prevents 'BucketNotEmpty' error)
aws --endpoint-url=http://localhost:4566 s3 rm s3://demo-logs-bucket --recursive 2>/dev/null || true

# Destroy Terraform-managed resources
terraform destroy -auto-approve -refresh=false

cd ..
docker-compose down
echo "✅ Cleanup complete!"

Why needed? LocalStack has issues deleting versioned S3 buckets. This script handles that edge case.
🎯 Presentation Points
Key Concepts to Highlight

    Infrastructure as Code Benefits

        Version control for infrastructure

        Repeatable, consistent deployments

        Self-documenting configurations

        Collaboration through code review

    LocalStack Advantages

        Zero-cost AWS environment

        Rapid prototyping

        Offline development

        Learning without fear of costs

    Terraform Features Demonstrated

        Declarative syntax

        Resource dependencies

        State management

        Modular organization

        Output variables

    Real-World Applicability

        Development environments

        CI/CD pipeline testing

        Training workshops

        Proof of concepts

5-Minute Lightning Demo Script
bash

# 1. Show starting point (10 seconds)
ls -la
echo "Empty project directory"

# 2. Start services (30 seconds)
docker-compose up -d
echo "LocalStack started - AWS emulator running locally"

# 3. Deploy infrastructure (60 seconds)
cd terraform
terraform apply -auto-approve
echo "VPC, EC2, S3, IAM created with one command"

# 4. Show results (60 seconds)
terraform output
echo "http://localhost:8888"  # Open browser
aws --endpoint-url=http://localhost:4566 s3 ls

# 5. Cleanup (20 seconds)
terraform destroy -auto-approve
cd ..
docker-compose down
echo "Everything cleaned up - zero lingering resources"

⚠️ Troubleshooting
Common Issues & Solutions
Problem	Solution
Port 8888 not accessible	Check docker ps, restart with docker-compose restart nginx
"BucketNotEmpty" error	Run ./destroy.sh instead of terraform destroy
LocalStack not responding	Restart: docker-compose restart localstack
Terraform provider errors	Delete .terraform folder and run terraform init
AWS CLI "does not exist"	Create the file first: echo "test" > filename.txt
LocalStack-Specific Notes

    Not all AWS APIs are fully implemented

        EIP (Elastic IP) has limited support

        Some S3 versioning operations may fail

        Use workarounds provided in code

    Data persists between runs

        LocalStack stores data in .localstack/ directory

        Use docker-compose down -v to remove volumes

        Or delete .localstack/ directory for complete reset

    Mock credentials required

        Always use access_key = "test" and secret_key = "test"

        Never use real AWS credentials with LocalStack

        Endpoint URL must be specified for AWS CLI

📚 Learning Resources
Deepen Your Knowledge

    Terraform Documentation

        Terraform AWS Provider

        Terraform Language

    LocalStack Guides

        LocalStack Documentation

        AWS Service Coverage

    AWS Concepts

        AWS Well-Architected Framework

        VPC Networking Basics

Next Steps for This Project

    Add modules for reusable components

    Implement remote state with Terraform Cloud

    Add validation tests with Terratest

    Create CI/CD pipeline with GitHub Actions

    Extend with more services: RDS, Lambda, API Gateway

🏆 Skills Demonstrated
Category	Specific Skills
Infrastructure as Code	Terraform syntax, state management, modular design
Cloud Networking	VPC, subnets, security groups, route tables
AWS Services	EC2, S3, IAM (conceptual understanding)
Containerization	Docker, Docker Compose, service orchestration
Local Development	Cloud emulation, offline workflows
Automation	Scripting, Makefile-like automation
Troubleshooting	Debugging LocalStack issues, workaround implementation
🔄 Development Workflow for Extensions
bash

# 1. Make changes to Terraform files
vim terraform/vpc.tf

# 2. Validate syntax
cd terraform
terraform validate
terraform fmt

# 3. Test changes
terraform plan
terraform apply -auto-approve

# 4. Verify functionality
aws --endpoint-url=http://localhost:4566 s3 ls
curl http://localhost:8888

# 5. Clean up
terraform destroy -auto-approve

📞 Getting Help
If Something Breaks

    First, try the nuclear option:
    bash

docker-compose down -v
rm -rf .localstack terraform/.terraform terraform/terraform.tfstate*
docker-compose up -d

Check service logs:
bash

docker-compose logs localstack
docker-compose logs nginx

Verify ports are free:
bash

ss -tulpn | grep -E '(4566|8888)'

Common Error Messages

    "BucketNotEmpty" → Run ./destroy.sh

    "connection refused" → LocalStack not running, restart with docker-compose restart

    "file does not exist" → Create the file before uploading to S3

    "port already in use" → Change port in docker-compose.yml

🎉 Demo Success Checklist

    terraform apply completes without errors

    Web app accessible at http://localhost:8080

    S3 bucket listed: aws --endpoint-url=http://localhost:4566 s3 ls

    Files can be uploaded to S3 bucket

    terraform destroy cleans up everything

    Docker containers stop successfully

