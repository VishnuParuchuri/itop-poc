#!/bin/bash
yum update -y
yum install -y httpd php php-mysqlnd php-gd php-xml php-mbstring php-zip wget unzip mysql

systemctl start httpd
systemctl enable httpd

cd ${itop_web_root}
wget https://sourceforge.net/projects/itop/files/itop/3.1.0/iTop-3.1.0-11973.zip/download -O itop.zip
unzip itop.zip
mv web/* .
rmdir web
rm itop.zip

chown -R apache:apache ${itop_web_root}
chmod -R 755 ${itop_web_root}

systemctl restart httpd