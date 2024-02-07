#!/bin/bash
sudo apt update 

sudo sudo apt install redis-server -y
echo "redis installed successfully."

# Download and install Amazon CloudWatch agent
sudo wget https://s3.amazonaws.com/amazoncloudwatch-agent/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb 
sudo dpkg -i -E ./amazon-cloudwatch-agent.deb
echo "Cloudwatch Agent status check."

echo "script executed successfully"


