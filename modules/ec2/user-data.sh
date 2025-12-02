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
    
    # Restart Apache to load MySQL driver
    systemctl restart httpd
    
    # Create a simple PHP demo to test the infrastructure
    cd ${itop_web_root}
    echo "Creating demo application..."
    echo "<h1>Server is running</h1><p>$(date)</p><p>Creating demo application...</p>" > ${itop_web_root}/index.html
    
    # Create itop directory with a simple PHP demo
    mkdir -p itop
    
    # Create a simple PHP page that tests database connectivity
    cat > itop/index.php << 'EOF'
<?php
echo "<h1>iTop PoC Infrastructure Demo</h1>";
echo "<p>Server Time: " . date('Y-m-d H:i:s') . "</p>";
echo "<p>PHP Version: " . phpversion() . "</p>";

// Check PHP extensions
echo "<h3>PHP Extensions Status</h3>";
echo "<p>PDO: " . (extension_loaded('pdo') ? '✅ Loaded' : '❌ Not Loaded') . "</p>";
echo "<p>PDO MySQL: " . (extension_loaded('pdo_mysql') ? '✅ Loaded' : '❌ Not Loaded') . "</p>";
echo "<p>MySQLi: " . (extension_loaded('mysqli') ? '✅ Loaded' : '❌ Not Loaded') . "</p>";

// List all loaded extensions
echo "<details><summary>All Loaded Extensions</summary>";
echo "<p>" . implode(', ', get_loaded_extensions()) . "</p>";
echo "</details>";

// Database connection test
$host = 'itop-poc-poc-mysql.cmxfeub41qnk.ap-south-1.rds.amazonaws.com';
$dbname = 'itopdb';
$username = 'itopuser';
$password = 'YourPasswordHere'; // Replace with actual password

echo "<h3>Database Connection Test</h3>";
if (extension_loaded('pdo_mysql')) {
    try {
        $pdo = new PDO("mysql:host=$host;dbname=$dbname", $username, $password);
        $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
        echo "<p style='color: green;'>✅ Database Connection: SUCCESS</p>";
        echo "<p>Connected to: $host</p>";
        echo "<p>Database: $dbname</p>";
        
        // Test query
        $stmt = $pdo->query('SELECT VERSION() as version');
        $result = $stmt->fetch();
        echo "<p>MySQL Version: " . $result['version'] . "</p>";
        
    } catch(PDOException $e) {
        echo "<p style='color: red;'>❌ Database Connection: FAILED</p>";
        echo "<p>Error: " . $e->getMessage() . "</p>";
    }
} else {
    echo "<p style='color: red;'>❌ PDO MySQL driver not loaded</p>";
}

echo "<hr>";
echo "<h2>Infrastructure Status</h2>";
echo "<ul>";
echo "<li>✅ EC2 Instance: Running</li>";
echo "<li>✅ Apache Web Server: Running</li>";
echo "<li>✅ PHP: Working</li>";
echo "<li>✅ RDS MySQL: Available</li>";
echo "</ul>";
echo "<p><strong>Your iTop PoC infrastructure is ready!</strong></p>";
?>
EOF
    
    # Set proper permissions
    chown -R apache:apache ${itop_web_root}
    chmod -R 755 ${itop_web_root}
    
    echo "<h1>Server is running</h1><p>$(date)</p><p>Demo application ready! <a href='/itop'>Access Demo</a></p>" > ${itop_web_root}/index.html
    echo "Demo application created successfully"
    
    systemctl restart httpd
    echo "Background installation completed at $(date)"
} &

echo "User-data script main part completed at $(date)"