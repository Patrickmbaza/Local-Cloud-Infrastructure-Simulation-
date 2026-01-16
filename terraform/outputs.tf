output "vpc_id" {
  description = "ID of the created VPC"
  value       = aws_vpc.demo_vpc.id
}



output "s3_bucket_name" {
  description = "Name of the created S3 bucket"
  value       = aws_s3_bucket.logs_bucket.bucket
}

output "s3_bucket_arn" {
  description = "ARN of the S3 bucket"
  value       = aws_s3_bucket.logs_bucket.arn
}

output "security_group_id" {
  description = "ID of the security group"
  value       = aws_security_group.web_sg.id
}

output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.web_server.id
}

output "web_app_url" {
  description = "URL to access the web application"
  value       = "http://localhost:8080"
}

output "localstack_ui" {
  description = "LocalStack Web UI"
  value       = "http://localhost:4566/_localstack/health"
}