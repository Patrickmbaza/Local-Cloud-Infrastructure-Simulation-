# Run this complete sequence
cd /mnt/c/Users/patri/Desktop/Infastructure-project

# Stop everything
docker-compose down

# Remove LocalStack data
sudo rm -rf .localstack

# Start fresh
docker-compose up -d
sleep 5

# Now the bucket doesn't exist anymore
# Go to terraform and destroy (it will work now)
cd terraform
terraform destroy -auto-approve