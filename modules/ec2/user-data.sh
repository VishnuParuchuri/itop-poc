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
    
    # Use a more reliable download method
    if wget --timeout=300 --tries=3 https://sourceforge.net/projects/itop/files/itop/3.1.0/iTop-3.1.0-11973.zip/download -O itop.zip; then
        echo "Download successful, extracting..."
        echo "<h1>Server is running</h1><p>$(date)</p><p>Extracting iTop...</p>" > ${itop_web_root}/index.html
        
        # Extract with verbose output
        if unzip -q itop.zip; then
            echo "Extraction completed, checking contents..."
            ls -la > /tmp/extraction_debug.log
            
            # Simple approach - check for common structures
            if [ -d web ]; then
                mv web itop
                echo "Moved web directory to itop"
            elif [ -d iTop ]; then
                mv iTop itop
                echo "Moved iTop directory to itop"
            elif ls -d iTop-* 2>/dev/null; then
                mv iTop-* itop
                echo "Moved iTop-* directory to itop"
            else
                # Create itop directory and move everything
                mkdir -p itop
                find . -maxdepth 1 -type f \( -name "*.php" -o -name "*.html" -o -name "*.css" -o -name "*.js" \) -exec mv {} itop/ \;
                find . -maxdepth 1 -type d ! -name "." ! -name "itop" -exec mv {} itop/ \;
                echo "Created itop directory and moved files"
            fi
            
            # Verify installation
            if [ -d itop ] && [ "$(ls -A itop 2>/dev/null)" ]; then
                chown -R apache:apache ${itop_web_root}
                chmod -R 755 ${itop_web_root}
                echo "<h1>Server is running</h1><p>$(date)</p><p>iTop installation completed! <a href='/itop'>Access iTop</a></p>" > ${itop_web_root}/index.html
                echo "iTop installation completed successfully"
            else
                echo "<h1>Server is running</h1><p>$(date)</p><p>Error: Installation failed - no valid iTop files found</p>" > ${itop_web_root}/index.html
                echo "Error: no valid iTop files found after extraction"
            fi
        else
            echo "<h1>Server is running</h1><p>$(date)</p><p>Error: Failed to extract iTop archive</p>" > ${itop_web_root}/index.html
            echo "Error: Failed to extract iTop archive"
        fi
        rm -f itop.zip
    else
        echo "<h1>Server is running</h1><p>$(date)</p><p>Error: Failed to download iTop</p>" > ${itop_web_root}/index.html
        echo "Error: Failed to download iTop"
    fi
    
    systemctl restart httpd
    echo "Background installation completed at $(date)"
} &

echo "User-data script main part completed at $(date)"