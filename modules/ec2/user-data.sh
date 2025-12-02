#!/bin/bash
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1
echo "Starting user-data script at $(date)"

# Update system
yum update -y

# Install packages
yum install -y httpd php php-mysqlnd php-gd php-xml php-mbstring php-zip wget unzip mysql

# Start and enable Apache
systemctl start httpd
systemctl enable httpd
systemctl status httpd

# Create a simple test page first
echo "<h1>Server is running</h1><p>$(date)</p>" > ${itop_web_root}/index.html

# Download and install iTop
cd ${itop_web_root}
echo "Downloading iTop..."
wget https://sourceforge.net/projects/itop/files/itop/3.1.0/iTop-3.1.0-11973.zip/download -O itop.zip

if [ -f itop.zip ]; then
    echo "Extracting iTop..."
    unzip itop.zip
    if [ -d web ]; then
        mv web itop
        chown -R apache:apache ${itop_web_root}
        chmod -R 755 ${itop_web_root}
        echo "iTop installation completed"
    else
        echo "Error: web directory not found after extraction"
    fi
    rm itop.zip
else
    echo "Error: Failed to download iTop"
fi

# Restart Apache
systemctl restart httpd
systemctl status httpd

echo "User-data script completed at $(date)"