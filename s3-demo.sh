# 1. Show infrastructure is deployed
terraform output

# 2. Show S3 bucket exists
aws --endpoint-url=http://localhost:4566 s3 ls

# 3. Upload a file during presentation
echo "Live demo upload at $(date)" > live-demo.txt
aws --endpoint-url=http://localhost:4566 s3 cp live-demo.txt s3://demo-logs-bucket/live-demo/

# 4. Show it was uploaded
aws --endpoint-url=http://localhost:4566 s3 ls s3://demo-logs-bucket/live-demo/

# 5. Download and show content
aws --endpoint-url=http://localhost:4566 s3 cp s3://demo-logs-bucket/live-demo/live-demo.txt -