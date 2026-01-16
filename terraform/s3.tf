# Create S3 bucket for logs
resource "aws_s3_bucket" "logs_bucket" {
  bucket = var.bucket_name
  
  tags = {
    Name        = "demo-logs-bucket"
    Environment = var.environment
    Purpose     = "web-server-logs"
  }
}

# Enable bucket versioning
resource "aws_s3_bucket_versioning" "logs_versioning" {
  bucket = aws_s3_bucket.logs_bucket.id
  
  versioning_configuration {
    status = "Enabled"
  }
}

# Upload sample log file
resource "aws_s3_object" "sample_log" {
  bucket       = aws_s3_bucket.logs_bucket.id
  key          = "logs/access.log"
  content      = "2024-01-01 10:00:00 GET /index.html 200\n2024-01-01 10:01:00 GET /style.css 200"
  content_type = "text/plain"
  
  tags = {
    Name = "sample-log-file"
  }
}

# Upload more log files to demonstrate bucket behavior
resource "aws_s3_object" "error_logs" {
  bucket       = aws_s3_bucket.logs_bucket.id
  key          = "logs/error.log"
  content      = "2024-01-01 10:00:00 ERROR: Connection timeout\n2024-01-01 10:01:00 WARN: High memory usage"
  content_type = "text/plain"
}

# Create IAM role for EC2 to write to S3
resource "aws_iam_role" "ec2_s3_role" {
  name = "ec2-s3-write-role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "s3_write_policy" {
  name = "s3-write-policy"
  role = aws_iam_role.ec2_s3_role.id
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Effect = "Allow"
        Resource = [
          "${aws_s3_bucket.logs_bucket.arn}",
          "${aws_s3_bucket.logs_bucket.arn}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ec2-s3-profile"
  role = aws_iam_role.ec2_s3_role.name
}