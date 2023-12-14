#!/bin/bash
set -ex
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -s -c ssm:AmazonCloudWatch-linux-dev
if [ -d "/content" ]; then
echo "Directory already exists. Skipping steps."
else
mkdir /content
fi
# alternate for if else 
cd /etc
if [ -d "objectivefs.env" ]; then
echo "Directory already exists. Skipping steps."
else
sudo mkdir objectivefs.env
fi
cd /etc/objectivefs.env
sudo echo "EV4ASLV4NCQH72OFSQ2GKDE4" > OBJECTIVEFS_LICENSE
sudo echo "snifffruploads" > OBJECTIVEFS_PASSPHRASE
sudo echo "s3://" > OBJECTSTORE
echo "ObjeciveFS configured successfully."
ls -al /etc/objectivefs.env/
sudo mount.objectivefs -omkdir,mt,nonempty mount-uploads /content
df -Th

# apache config 
aws secretsmanager get-secret-value --secret-id /apache2/default.conf | jq -r .SecretString > /etc/apache2/sites-available/000-default.conf
aws secretsmanager get-secret-value --secret-id /apache2/ssl.conf | jq -r .SecretString > /etc/apache2/sites-available/default-ssl.conf
aws secretsmanager get-secret-value --secret-id /apache2/htaccess | jq -r .SecretString > /var/www/html/.htaccess
ln -s /etc/apache2/sites-available/default-ssl.conf /etc/apache2/sites-enabled/

apachectl -t 
if [ $? -eq 0 ]; then
    sudo systemctl restart apache2
echo "Apache started successfully."
else 
    echo "Apache configuration syntax is invalid. Please check your configuration."
    exit 1;
fi

# ssl config
cert_pem=$(aws secretsmanager get-secret-value --secret-id /ssl/cert.pem | jq -r .SecretString)
chain_pem=$(aws secretsmanager get-secret-value --secret-id /ssl/chain.pem | jq -r .SecretString)
fullchain_pem=$(aws secretsmanager get-secret-value --secret-id /ssl/fullchain.pem | jq -r .SecretString)
privkey_pem=$(aws secretsmanager get-secret-value --secret-id /ssl/privkey.pem | jq -r .SecretString)

echo "$cert_pem" > /etc/letsencrypt/live/stg.snifffr.com/cert.pem
echo "$chain_pem" > /etc/letsencrypt/live/stg.snifffr.com/chain.pem
echo "$fullchain_pem" > /etc/letsencrypt/live/stg.snifffr.com/fullchain.pem
echo "$privkey_pem" > /etc/letsencrypt/live/stg.snifffr.com/privkey.pem

# redis config and fetch and configure here

REDIS_ENDPOINT=$(aws elasticache describe-cache-clusters --cache-cluster-id production-stg-snifffr-db-redis-001 --show-cache-node-info --query 'CacheClusters[*].CacheNodes[*].Endpoint.Address[]' --output text)
sed -i "s/REDIS_ENDPOINT/${REDIS_ENDPOINT}/g" /etc/php/7.4/apache2/php.ini

# Proxysql config
RDS_END_POINT=$(aws rds describe-db-cluster-endpoints --db-cluster-identifier stg-snifffr-db --query 'DBClusterEndpoints[?EndpointType==`WRITER`].Endpoint' --output text)
aws secretsmanager get-secret-value --secret-id /etc/proxysql.cnf | jq -r .SecretString > /etc/proxysql.cnf
sed -i "s/RDS_END_POINTS/${RDS_END_POINT}/g" /etc/proxysql.cnf
cat /etc/proxysql.cnf | grep "address"
ulimit -n 102400
ulimit -c 1073741824
sudo systemctl stop proxysql
echo "proxy stops"
sleep 5s
proxysql --initial 
sleep 5s
echo "initial"
sleep 5s
sudo systemctl start proxysql
sleep 5s
sudo systemctl start proxysql
echo "running"
systemctl restart apache2
echo "user data executed successfully"
