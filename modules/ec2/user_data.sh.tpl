#!/bin/bash
# iTop PoC userdata for Amazon Linux 2023
# - Installs Apache + PHP + MySQL drivers
# - Enables .htaccess (AllowOverride All)
# - Downloads iTop and exposes it at http://<EC2_IP>/itop
# - Logs to /var/log/itop-userdata.log

set -xe

LOG_FILE="/var/log/itop-userdata.log"
exec > >(tee -a "$${LOG_FILE}" | logger -t user-data -s 2>/dev/console) 2>&1

# Terraform will replace this with the value you pass in itop_web_root
WEB_ROOT="${itop_web_root}"

echo "===== iTop PoC bootstrap starting on $(date) ====="
echo "WEB_ROOT=$${WEB_ROOT}"

# -----------------------------
# 1. Update system packages
# -----------------------------
dnf update -y || true

# -----------------------------
# 2. Install Apache + PHP + required extensions
# -----------------------------
# --allowerasing avoids conflicts between PHP/httpd deps and existing packages
dnf install -y --allowerasing \
  httpd \
  php \
  php-cli \
  php-mysqlnd \
  php-mbstring \
  php-json \
  php-xml \
  php-gd \
  php-soap \
  php-pecl-zip \
  unzip

# Allow .htaccess files (needed by iTop for directory-level config)
sed -i 's/AllowOverride None/AllowOverride All/g' /etc/httpd/conf/httpd.conf

systemctl enable httpd
systemctl start httpd

# -----------------------------
# 3. Prepare web root
# -----------------------------
mkdir -p "$${WEB_ROOT}"
cd "$${WEB_ROOT}"

# Root index: redirect to /itop
cat > index.php << 'EOF'
<?php
header("Location: /itop");
exit;
?>
EOF

# Simple health page (optional, for quick debugging)
cat > health.php << 'EOF'
<?php
echo "<h1>iTop PoC Infrastructure Demo</h1>";
echo "<p>Server Time: " . date('Y-m-d H:i:s') . "</p>";
echo "<h2>PHP Info (short)</h2>";
echo "<p>PHP Version: " . phpversion() . "</p>";
?>
EOF

# -----------------------------
# 4. Download iTop from SourceForge
# -----------------------------
echo "Downloading iTop from SourceForge..."
cd /tmp
curl -L "https://sourceforge.net/projects/itop/files/latest/download" -o itop.zip

if [ ! -s itop.zip ]; then
  echo "ERROR: Failed to download iTop archive." >> "$${LOG_FILE}"
  # Leave Apache running so at least health.php works
  exit 0
fi

rm -rf /tmp/itop-src
mkdir -p /tmp/itop-src
unzip -o itop.zip -d /tmp/itop-src

# Find the 'web' directory where the iTop PHP app lives
ITOP_WEB_DIR=$$(find /tmp/itop-src -maxdepth 3 -type d -name "web" | head -n 1 || true)

if [ -z "$${ITOP_WEB_DIR}" ]; then
  echo "ERROR: Could not find iTop 'web' directory after unzip." >> "$${LOG_FILE}"
  exit 0
fi

echo "Using ITOP_WEB_DIR=$${ITOP_WEB_DIR}"

# -----------------------------
# 5. Copy iTop into Apache docroot
# -----------------------------
mkdir -p "$${WEB_ROOT}/itop"
cp -r "$${ITOP_WEB_DIR}/"* "$${WEB_ROOT}/itop/"

# Permissions
chown -R apache:apache "$${WEB_ROOT}"
chmod -R 755 "$${WEB_ROOT}"

# Restart Apache to ensure new config is active
systemctl restart httpd

echo "===== iTop PoC bootstrap completed at $(date) ====="
echo "Open: http://<EC2_PUBLIC_IP>/itop" >> "$${LOG_FILE}"
