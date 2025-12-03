#!/bin/bash
# Install iTop on Amazon Linux 2023 from Jenkins after infra provisioning

set -xe

LOG_FILE="/var/log/itop-install.log"

# Ensure log directory exists (it will, but harmless)
mkdir -p "$(dirname "$LOG_FILE")"

# Simple, safe logging: write to file AND show in Jenkins
exec > >(tee -a "$LOG_FILE") 2>&1

WEB_ROOT="/var/www/html"
ITOP_URL="https://sourceforge.net/projects/itop/files/latest/download"

echo "===== iTop install started at $(date) ====="

# 1. Update system
dnf update -y || true

# 2. Install Apache + PHP + required extensions
dnf install -y \
  httpd \
  php \
  php-cli \
  php-common \
  php-mysqlnd \
  php-mbstring \
  php-json \
  php-xml \
  php-gd \
  php-soap \
  unzip \
  curl

# 3. Enable + start Apache
systemctl enable httpd
systemctl start httpd

# 4. Prepare web root
mkdir -p "$WEB_ROOT"
cd "$WEB_ROOT"

# Simple redirect to /itop
cat > index.php <<'EOF'
<?php
header("Location: /itop");
exit;
?>
EOF

# 5. Download iTop
echo "Downloading iTop..."
curl -L "$ITOP_URL" -o itop.zip

if [ ! -s itop.zip ]; then
  echo "ERROR: Failed to download iTop archive"
  exit 1
fi

echo "Unzipping iTop..."
unzip -o itop.zip

ITOP_DIR="$(ls -d itop* | grep -v '\.zip' | head -n 1 || true)"

if [ -z "$ITOP_DIR" ]; then
  echo "ERROR: Could not find extracted iTop directory"
  exit 1
fi

if [ "$ITOP_DIR" != "itop" ]; then
  mv "$ITOP_DIR" itop
fi

# 6. Apache config: allow .htaccess (needed by iTop)
cat >/etc/httpd/conf.d/itop.conf <<'EOF'
<VirtualHost *:80>
    DocumentRoot "/var/www/html"
    <Directory "/var/www/html">
        AllowOverride All
        Require all granted
    </Directory>
</VirtualHost>
EOF

# 7. Permissions
chown -R apache:apache "$WEB_ROOT"
# SELinux commands are harmless on AL2023 (no SELinux by default), but keep them just in case
chcon -R -t httpd_sys_content_t "$WEB_ROOT" 2>/dev/null || true
chcon -R -t httpd_sys_rw_content_t "$WEB_ROOT/itop/conf" "$WEB_ROOT/itop/data" 2>/dev/null || true

# 8. Restart Apache
systemctl restart httpd

echo "===== iTop install finished at $(date) ====="
echo "iTop should now be available at: http://<EC2_PUBLIC_IP>/itop"