#!/bin/bash
# iTop PoC userdata for Amazon Linux 2023
# - Installs Apache + PHP + required extensions
# - Downloads iTop
# - Enables .htaccess and sets permissions

set -x

LOG_FILE="/var/log/itop-userdata.log"
exec > >(tee -a "$${LOG_FILE}" | logger -t user-data -s 2>/dev/console) 2>&1

WEB_ROOT="${itop_web_root}"

echo "===== [iTop userdata] Start: $(date) ====="
echo "WEB_ROOT=$${WEB_ROOT}"

# -----------------------------
# 1. Update system packages
#    --allowerasing avoids curl / curl-minimal conflicts
# -----------------------------
dnf upgrade -y --allowerasing || dnf upgrade -y || true

# -----------------------------
# 2. Install Apache, PHP and extensions
#    php-mysqlnd -> MySQL driver
#    php-soap, php-zip -> iTop prerequisites
# -----------------------------
dnf install -y \
  httpd \
  php \
  php-cli \
  php-mysqlnd \
  php-mbstring \
  php-json \
  php-xml \
  php-gd \
  php-soap \
  php-zip \
  unzip \
  curl \
  --allowerasing || true

# Enable & start Apache
systemctl enable httpd || true
systemctl restart httpd || true

# -----------------------------
# 3. Prepare web root
# -----------------------------
mkdir -p "$${WEB_ROOT}"
cd "$${WEB_ROOT}"

# Simple index that redirects to /itop
cat > index.php <<'EOF'
<?php
header("Location: /itop");
exit;
?>
EOF

# -----------------------------
# 4. Download iTop
# -----------------------------
echo "Downloading iTop from SourceForge..."
curl -L "https://sourceforge.net/projects/itop/files/latest/download" -o itop.zip

if [ ! -s itop.zip ]; then
  echo "ERROR: Failed to download iTop archive." >&2
  exit 0
fi

echo "Unzipping iTop..."
unzip -o itop.zip

# Find extracted folder (itop-<version>)
ITOP_DIR=$$(find . -maxdepth 1 -type d -name "itop*" ! -name "itop" | head -n 1 || true)

if [ -z "$${ITOP_DIR}" ]; then
  echo "ERROR: Could not find extracted iTop directory." >&2
  exit 0
fi

# Rename to /itop if needed
if [ "$${ITOP_DIR}" != "./itop" ] && [ "$${ITOP_DIR}" != "itop" ]; then
  mv "$${ITOP_DIR}" itop
fi

# -----------------------------
# 5. Permissions & Apache config
# -----------------------------
# iTop files
chown -R apache:apache "$${WEB_ROOT}/itop"
find "$${WEB_ROOT}/itop" -type d -exec chmod 755 {} \;
find "$${WEB_ROOT}/itop" -type f -exec chmod 644 {} \;

# Allow .htaccess (needed for iTop)
if grep -q "AllowOverride None" /etc/httpd/conf/httpd.conf; then
  sed -i 's/AllowOverride None/AllowOverride All/g' /etc/httpd/conf/httpd.conf
fi

systemctl restart httpd || true

echo "===== [iTop userdata] Finished: $(date) ====="
echo "USERDATA_COMPLETE" >> "$${LOG_FILE}"
echo "You should be able to open: http://<EC2_PUBLIC_IP>/itop"
