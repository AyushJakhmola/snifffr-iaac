#!/bin/bash
sudo apt update 

sudo apt install apache2 -y
echo "Apache installed successfully."

sudo apt -y install php7.4
sudo apt-get install php-fpm php-mysql -y
sudo apt install php7.4-bcmath php7.4-bz2 php7.4-cli php7.4-common php7.4-curl php7.4-gd php7.4-igbinary php7.4-imagick php7.4-intl php7.4-json php7.4-mbstring php7.4-mysql php7.4-opcache php7.4-readline php7.4-redis php7.4-xml php7.4-zip php7.4 -y
sudo apt install collectd ruby-full composer fuse wget unzip net-tools -y
sudo apt install php7.4-fpm -y
sudo apt-get install unzip -y
echo "PHP installed successfully."

# dependencies
sudo apt install composer -y
sudo apt install jq -y
sudo apt install libapache2-mod-fcgid -y
sudo apt install mysql-client -y
sudo apt install certbot -y
sudo apt install unzip -y
sudo apt install nfs-common -y
sudo apt install lsb-release wget apt-transport-https ca-certificates gnupg -y
echo "Dependenices installed successfully."

# aws cli 
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
echo "AWS CLI installed successfully."

# Download and install Amazon CloudWatch agent
sudo wget https://s3.amazonaws.com/amazoncloudwatch-agent/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb 
sudo dpkg -i -E ./amazon-cloudwatch-agent.deb
echo "Cloudwatch Agent status check."

# Download and install AWS CodeDeploy agent
sudo wget https://aws-codedeploy-us-east-1.s3.us-east-1.amazonaws.com/latest/install
sudo chmod +x ./install
sudo ./install auto
echo "Code Deploy agent status check."

# install Proxysql
sudo wget https://github.com/sysown/proxysql/releases/download/v2.5.1/proxysql_2.5.1-ubuntu20_amd64.deb
sudo apt install ./proxysql_2.5.1-ubuntu20_amd64.deb
echo "Proxysql server installed successfully."

# certificate configuration
sudo mkdir /etc/letsencrypt/live/
sudo mkdir /etc/letsencrypt/live/dev.snifffr.com
sudo touch /etc/letsencrypt/live/dev.snifffr.com/cert.pem
sudo touch /etc/letsencrypt/live/dev.snifffr.com/chain.pem
sudo touch /etc/letsencrypt/live/dev.snifffr.com/fullchain.pem
sudo touch /etc/letsencrypt/live/dev.snifffr.com/privkey.pem
ls -al /etc/letsencrypt/live
ls -al /etc/letsencrypt/live/dev.snifffr.com/

sudo a2dismod php7.4
sudo a2dismod mpm_worker
sudo a2dismod mpm_prefork
sudo a2enmod mpm_event
sudo a2enmod access_compat actions alias auth_basic authn_core authn_file authz_core authz_host authz_user autoindex cache deflate dir env expires fcgid filter headers mime mpm_event negotiation proxy proxy_fcgi remoteip reqtimeout rewrite setenvif socache_shmcb ssl status

sudo systemctl restart apache2
apachectl -M

sudo mkdir /root/efs-mount-point  
sudo mkdir /var/log/proxysql
sudo touch /var/log/proxysql/proxysql.log 
sudo chmod 777 -R /var/log/proxysql/
sudo ulimit -n 102400
sudo ulimit -c 1073741824

echo "script executed successfully"


