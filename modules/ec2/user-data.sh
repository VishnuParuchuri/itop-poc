#!/bin/bash
# Update OS
yum update -y

# Install Apache, PHP, MySQL PHP extension, wget, unzip
yum install -y httpd php php-mysqlnd php-json php-mbstring wget unzip

systemctl enable httpd
systemctl start httpd

# Go to web root
cd ${itop_web_root}

# Download latest iTop
wget https://sourceforge.net/projects/itop/files/latest/download -O itop.zip

unzip itop.zip

# This folder name changes version to version, so just move first itop* folder
ITOP_DIR=$(ls -d itop* | head -n 1)

# Move/rename to "itop"
if [ "$ITOP_DIR" != "itop" ]; then
  mv "$ITOP_DIR" itop
fi

chown -R apache:apache itop
chmod -R 755 itop