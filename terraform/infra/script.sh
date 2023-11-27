#!/bin/bash

sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -s -c ssm:AmazonCloudWatch-linux-dev

sudo mount.objectivefs -omkdir,mt,nonempty mount-uploads /content

# apache should start first 

APACHE_CONFIG=$(aws secretsmanager get-secret-value --secret-id /apache2/default.conf | jq -r .SecretString)
echo "$APACHE_CONFIG" > /etc/apache2/sites-enabled/000-default.conf

apachectl -t 
if [ $? -eq 0 ]; then
    sudo systemctl restart apache2
echo "Apache started successfully."
else 
    echo "Apache configuration syntax is invalid. Please check your configuration."
fi

#NGINX_CONFIG=$(aws secretsmanager get-secret-value --secret-id /nginx/nginx.conf | jq -r .SecretString)
#echo "$NGINX_CONFIG" > nginx.conf
#mv nginx.conf /etc/nginx/nginx.conf

NGINX_DEFAULT_CONFIG=$(aws secretsmanager get-secret-value --secret-id /nginx/default.conf | jq -r .SecretString)
echo "$NGINX_DEFAULT_CONFIG" > /etc/nginx/sites-enabled/default

sudo nginx -t 
if [ $? -eq 0 ]; then
    sudo systemctl restart nginx
echo "NGINX started successfully."
else
    echo "NGINX configuration syntax is invalid. Please check your configuration."
fi


echo "user data executed successfully"

# redis config and proxysql configs (php.ini) fetch and configure here