#!/bin/bash

sudo yum update -y
sudo yum install -y httpd busybox 
sudo sed -i 's/Listen 80/Listen 8080/g' /etc/httpd/conf/httpd.conf 
sudo usermod -a -G apache ec2-user
sudo chown -R ec2-user:apache /var/www
sudo chmod 2775 /var/www
sudo find /var/www -type d -exec sudo chmod 2775 {} \;
sudo find /var/www -type f -exec sudo chmod 0664 {} \;
sudo touch /var/www/html/index.html
OUT=/var/www/html/index.html

#create index.html
sudo cat <<EOF > $OUT
<h1> Hello, World OK! </h1>
<p> Db address: ${db_address} </p>
<p> DB port: ${db_port} </p>
<p> Today's date is $(date) </p>
EOF

#restart service
sudo service httpd start