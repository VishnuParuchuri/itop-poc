#!/bin/bash
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1
echo "Starting user-data script at $(date)"

# Install Apache and PHP first (minimal packages)
yum install -y httpd php

# Create test page immediately
echo "<h1>Server is running</h1><p>$(date)</p><p>User-data in progress...</p>" > ${itop_web_root}/index.html

# Start Apache immediately
systemctl start httpd
systemctl enable httpd

# Continue with full installation in background
{
    echo "Installing additional packages..."
    echo "<h1>Server is running</h1><p>$(date)</p><p>Installing packages...</p>" > ${itop_web_root}/index.html
    yum update -y
    yum install -y php-mysqlnd php-gd php-xml php-mbstring php-zip wget unzip mysql
    
    # Download and install iTop
    cd ${itop_web_root}
    echo "Downloading iTop..."
    echo "<h1>Server is running</h1><p>$(date)</p><p>Downloading iTop (this may take a few minutes)...</p>" > ${itop_web_root}/index.html
    wget https://sourceforge.net/projects/itop/files/itop/3.1.0/iTop-3.1.0-11973.zip/download -O itop.zip
    
    if [ -f itop.zip ]; then
        echo "Extracting iTop..."
        echo "<h1>Server is running</h1><p>$(date)</p><p>Extracting iTop...</p>" > ${itop_web_root}/index.html
        unzip itop.zip
        if [ -d web ]; then
            mv web itop
            chown -R apache:apache ${itop_web_root}
            chmod -R 755 ${itop_web_root}
            echo "<h1>Server is running</h1><p>$(date)</p><p>iTop installation completed! <a href='/itop'>Access iTop</a></p>" > ${itop_web_root}/index.html
            echo "iTop installation completed"
        else
            echo "<h1>Server is running</h1><p>$(date)</p><p>Error: Installation failed - web directory not found</p>" > ${itop_web_root}/index.html
            echo "Error: web directory not found after extraction"
        fi
        rm itop.zip
    else
        echo "<h1>Server is running</h1><p>$(date)</p><p>Error: Failed to download iTop</p>" > ${itop_web_root}/index.html
        echo "Error: Failed to download iTop"
    fi
    
    systemctl restart httpd
    echo "Background installation completed at $(date)"
} &

echo "User-data script main part completed at $(date)"