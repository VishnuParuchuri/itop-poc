#!/bin/bash
# Install Apache + PHP + extensions + iTop on Amazon Linux 2023

set -xe

LOG_FILE="/var/log/itop-install.log"
exec > >(tee -a "$LOG_FILE") 2>&1

WEB_ROOT="/var/www/html"
ITOP_URL="https://sourceforge.net/projects/itop/files/latest/download"

echo "===== iTop install started at $(date) ====="

# 1. Update packages
dnf update -y || true

# 2. Install Apache, PHP and required extensions
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
  php-pecl-zip \
  unzip

# 3. Enable .htaccess (AllowOverride All for /var/www/html)
if ! grep -q 'AllowOverride All' /etc/httpd/conf/httpd.conf; then
  sed -i 's/AllowOverride None/AllowOverride All/g' /etc/httpd/conf/httpd.conf || true
fi

# 4. Enable & start Apache
systemctl enable httpd
systemctl restart httpd

# 5. Prepare web root
mkdir -p "${WEB_ROOT}"
cd "${WEB_ROOT}"

# Keep any previous itop as backup (for re-runs)
if [ -d "itop" ]; then
  mv itop "itop_$(date +%s).bak"
fi

# 6. Download iTop
echo "Downloading iTop from ${ITOP_URL} ..."
curl -L "${ITOP_URL}" -o itop.zip

if [ ! -s itop.zip ]; then
  echo "ERROR: Failed to download iTop archive."
  exit 1
fi

echo "Unzipping iTop ..."
unzip -o itop.zip

ITOP_DIR=$(ls -d iTop* itop* 2>/dev/null | grep -v '\.zip' | head -n 1 || true)

if [ -z "$ITOP_DIR" ]; then
  echo "ERROR: Could not find extracted iTop directory."
  exit 1
fi

if [ "$ITOP_DIR" != "itop" ]; then
  mv "$ITOP_DIR" itop
fi

# 7. Simple redirect index.php
cat > "${WEB_ROOT}/index.php" <<'EOF'
<?php
header('Location: /itop/');
exit;
?>
EOF

# 8. Permissions
chown -R apache:apache "${WEB_ROOT}"
chmod -R 755 "${WEB_ROOT}"

systemctl restart httpd

echo "===== iTop install finished at $(date) ====="
echo "Open:  http://<EC2_PUBLIC_IP>/itop  in your browser."
