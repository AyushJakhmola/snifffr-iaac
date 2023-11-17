#!/bin/bash

sudo apt update 

# sudo apt-get install php-fpm php-mysql -y
sudo apt install apache2 -y

sudo apt install php7.4-bcmath php7.4-bz2 php7.4-cli php7.4-common php7.4-curl php7.4-gd php7.4-igbinary php7.4-imagick php7.4-intl php7.4-json php7.4-mbstring php7.4-mysql php7.4-opcache php7.4-readline php7.4-redis php7.4-xml php7.4-zip php7.4 -y

sudo apt install collectd ruby-full composer fuse wget unzip net-tools -y

# Download and install Amazon CloudWatch agent
sudo wget https://s3.amazonaws.com/amazoncloudwatch-agent/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb 
sudo dpkg -i -E ./amazon-cloudwatch-agent.deb

# Download and install AWS CodeDeploy agent
cd /tmp 
sudo wget https://aws-codedeploy-us-east-1.s3.us-east-1.amazonaws.com/latest/install
sudo chmod +x ./install 
 ./install auto 

sudo apt install lsb-release wget apt-transport-https ca-certificates gnupg -y

# install Proxysql

sudo wget -O - 'https://repo.proxysql.com/ProxySQL/proxysql-2.5.x/repo_pub_key' | apt-key add -
sudo echo "deb https://repo.proxysql.com/ProxySQL/proxysql-2.5.x/$(lsb_release -sc)/ ./" | tee /etc/apt/sources.list.d/proxysql.list

sudo apt update
apt-get -y install proxysql

# install objective FS

sudo wget https://objectivefs.com/user/download/al6v562ir/objectivefs_7.1_amd64.deb
sudo dpkg -i objectivefs_7.1_amd64.deb

echo "Script executed successfully."