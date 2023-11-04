#!/bin/bash

# Function to display error message and exit
display_error() {
  echo "Error: $1"
  exit 1
}

# Update package repositories
 apt update || display_error "Failed to update package repositories"

# Download and install Amazon CloudWatch agent
wget https://s3.amazonaws.com/amazoncloudwatch-agent/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb || display_error "Failed to download Amazon CloudWatch agent"
 dpkg -i -E ./amazon-cloudwatch-agent.deb || display_error "Failed to install Amazon CloudWatch agent"

# Install Ruby
 apt install ruby-full -y || display_error "Failed to install Ruby"

# # Change to the home directory
cd /tmp || display_error "Failed to change directory"

# Download and install AWS CodeDeploy agent
wget https://aws-codedeploy-us-west-2.s3.us-west-2.amazonaws.com/latest/install || display_error "Failed to download AWS CodeDeploy agent"
chmod +x ./install || display_error "Failed to set execute permissions"
 ./install auto || display_error "Failed to install AWS CodeDeploy agent"

# # Create a new user
 useradd -m admin -g admin || display_error "Failed to create user"

wget https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/debian_amd64/amazon-ssm-agent.deb
sudo dpkg -i amazon-ssm-agent.deb
sudo systemctl enable amazon-ssm-agent
sudo systemctl start amazon-ssm-agent

echo "Script executed successfully."
