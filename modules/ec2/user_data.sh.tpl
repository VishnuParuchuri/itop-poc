#!/bin/bash
# iTop PoC userdata for Amazon Linux 2023

set -xe

LOG_FILE="/var/log/itop-userdata.log"
exec > >(tee -a "$${LOG_FILE}" | logger -t user-data -s 2>/dev/console) 2>&1

WEB_ROOT="${itop_web_root}"

echo "===== iTop PoC bootstrap starting on $(date) ====="
echo "WEB_ROOT=$${WEB_ROOT}"

# -----------------------------
# 1. Update system packages
# -----------------------------
dnf update -y || true

# -----------------------------
# 2. Install Apache, PHP, MySQL drivers, tools
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
  curl \
  unzip

systemctl enable httpd
systemctl start httpd

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
# 4. Download and extract iTop
# -----------------------------
echo "Downloading iTop from SourceForge..."
cd /tmp
curl -L "https://sourceforge.net/projects/itop/files/latest/download" -o itop.zip

if [ ! -s itop.zip ]; then
  echo "ERROR: Failed to download iTop archive." >> "$${LOG_FILE}"
  exit 0
fi

echo "Unzipping iTop..."
rm -rf /tmp/itop-src
mkdir -p /tmp/itop-src
unzip -o itop.zip -d /tmp/itop-src

# Find the 'web' directory (where the PHP app lives)
ITOP_WEB_DIR=$$(find /tmp/itop-src -maxdepth 3 -type d -name "web" | head -n 1 || true)

if [ -z "$${ITOP_WEB_DIR}" ]; then
  echo "ERROR: Could not find iTop 'web' directory after unzip." >> "$${LOG_FILE}"
  exit 0
fi

echo "Copying iTop web files from $${ITOP_WEB_DIR} to $${WEB_ROOT}/itop ..."
rm -rf "$${WEB_ROOT}/itop"
mkdir -p "$${WEB_ROOT}/itop"
cp -r "$${ITOP_WEB_DIR}/"* "$${WEB_ROOT}/itop/"

# -----------------------------
# 5. Permissions
# -----------------------------
chown -R apache:apache "$${WEB_ROOT}"
chmod -R 755 "$${WEB_ROOT}"

systemctl restart httpd

echo "===== iTop PoC bootstrap completed at $(date) ====="
echo "You should now be able to open: http://<EC2_PUBLIC_IP>/itop"
