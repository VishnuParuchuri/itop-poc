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
        
        # Debug: List what was extracted
        echo "Contents after extraction:"
        ls -la
        
        # Check for different possible directory structures
        if [ -d web ]; then
            echo "Found 'web' directory"
            mv web itop
        elif [ -d iTop ]; then
            echo "Found 'iTop' directory"
            mv iTop itop
        elif [ -d iTop-* ]; then
            echo "Found iTop-* directory"
            mv iTop-* itop
        else
            # Create itop directory and move all extracted files
            echo "No standard directory found, creating itop directory"
            mkdir -p itop
            # Move all files except the zip to itop directory
            find . -maxdepth 1 -type f -name "*.php" -o -name "*.css" -o -name "*.js" -o -name "*.html" | xargs -I {} mv {} itop/ 2>/dev/null || true
            find . -maxdepth 1 -type d ! -name "." ! -name "itop" | xargs -I {} mv {} itop/ 2>/dev/null || true
        fi
        
        if [ -d itop ] && [ "$(ls -A itop)" ]; then
            chown -R apache:apache ${itop_web_root}
            chmod -R 755 ${itop_web_root}
            echo "<h1>Server is running</h1><p>$(date)</p><p>iTop installation completed! <a href='/itop'>Access iTop</a></p>" > ${itop_web_root}/index.html
            echo "iTop installation completed"
        else
            echo "<h1>Server is running</h1><p>$(date)</p><p>Error: Installation failed - no valid iTop files found</p>" > ${itop_web_root}/index.html
            echo "Error: no valid iTop files found after extraction"
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