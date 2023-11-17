#!/bin/bash

sudo apt update 

# sudo apt-get install php-fpm php-mysql -y
sudo apt install apache2 -y

sudo apt install php7.4-bcmath php7.4-bz2 php7.4-cli php7.4-common php7.4-curl php7.4-gd php7.4-igbinary php7.4-imagick php7.4-intl php7.4-json php7.4-mbstring php7.4-mysql php7.4-opcache php7.4-readline php7.4-redis php7.4-xml php7.4-zip php7.4 -y

sudo apt install wget unzip install net-tools -y

sudo apt install collectd -y

sudo apt install ruby-full -y

sudo apt install composer

# Download and install Amazon CloudWatch agent
sudo wget https://s3.amazonaws.com/amazoncloudwatch-agent/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb 
sudo dpkg -i -E ./amazon-cloudwatch-agent.deb

# Download and install AWS CodeDeploy agent
cd /tmp 
sudo wget https://aws-codedeploy-us-east-1.s3.us-east-1.amazonaws.com/latest/install
sudo chmod +x ./install 
 ./install auto 

echo "Script executed successfully."
