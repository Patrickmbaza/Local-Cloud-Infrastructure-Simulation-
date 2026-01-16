# Create EC2 Instance (simulated in LocalStack)
resource "aws_instance" "web_server" {
  ami                    = "ami-12345678"
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public_subnet.id
  vpc_security_group_ids = [aws_security_group.web_sg.id]
  
  tags = {
    Name        = "demo-web-server"
    Environment = var.environment
    Service     = "nginx"
  }
  
  user_data = <<-EOF
              #!/bin/bash
              echo "Web server provisioned by Terraform + LocalStack"
              echo "NOTE: EIP not implemented in LocalStack demo"
              EOF
}

# NO EIP RESOURCE - LocalStack doesn't support it properly
# For demo, use a simulated output instead
