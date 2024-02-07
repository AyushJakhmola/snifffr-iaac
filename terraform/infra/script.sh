#!/bin/bash
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -s -c ssm:AmazonCloudWatch-linux-dev
efs_id=$(aws efs describe-file-systems --query "FileSystems[?Name=='stg-snifffr-efs'].FileSystemId" --output text)
ln -s /var/www/html/wp-content/uploads/ /root/efs-mount-point/
sudo mount -t nfs -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport ${efs_id}.efs.us-east-1.amazonaws.com:/ ~/efs-mount-point/
# apache config 
chown -R www-data:www-data /var/www/html/
aws secretsmanager get-secret-value --secret-id /apache2/default.conf | jq -r .SecretString > /etc/apache2/sites-available/000-default.conf
aws secretsmanager get-secret-value --secret-id /apache2/ssl.conf | jq -r .SecretString > /etc/apache2/sites-available/default-ssl.conf
ln -s /etc/apache2/sites-available/default-ssl.conf /etc/apache2/sites-enabled/
systemctl start proxysql
apachectl -t 
if [ $? -eq 0 ]; then
    sudo systemctl restart apache2
echo "Apache started successfully."
else 
    echo "Apache configuration syntax is invalid. Please check your configuration."
fi
echo "user data executed successfully"
