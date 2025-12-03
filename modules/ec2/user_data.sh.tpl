#!/bin/bash
# iTop PoC userdata for Amazon Linux 2023
# This script:
#  - Installs Apache + PHP + MySQL drivers
#  - Downloads and installs iTop under ${itop_web_root}/itop
#  - Creates index.php to redirect to /itop
#  - Logs to /var/log/itop-userdata.log

set -xe

LOG_FILE="/var/log/itop-userdata.log"
exec > >(tee -a "$${LOG_FILE}" | logger -t user-data -s 2>/dev/console) 2>&1

WEB_ROOT="${itop_web_root}"

echo "===== iTop PoC bootstrap starting on $(date) ====="
echo "WEB_ROOT=$${WEB_ROOT}"

# -----------------------------
# 1. Update system packages
# -----------------------------
# Amazon Linux 2023 uses dnf
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

# Enable and start Apache
systemctl enable httpd
systemctl start httpd

# -----------------------------
# 3. Prepare web root
# -----------------------------
mkdir -p "$${WEB_ROOT}"
cd "$${WEB_ROOT}"

# Simple index that redirects to /itop (for nicer UX)
cat > index.php <<'EOF'
<?php
// Simple redirect to iTop installer
header("Location: /itop");
exit;
?>
EOF

# -----------------------------
# 4. Download iTop
# -----------------------------
echo "Downloading iTop from SourceForge..."
# -L is CRITICAL to follow redirects
curl -L "https://sourceforge.net/projects/itop/files/latest/download" -o itop.zip

if [ ! -s itop.zip ]; then
  echo "ERROR: Failed to download iTop archive." >> "$${LOG_FILE}"
  # Leave index.php in place so you can see Apache is working
  exit 0
fi

echo "Unzipping iTop..."
unzip -o itop.zip

# Find extracted folder (usually itop-<version>)
ITOP_DIR=$$(ls -d itop* | grep -v '\.zip' | head -n 1 || true)

if [ -z "$${ITOP_DIR}" ]; then
  echo "ERROR: Could not find extracted iTop directory." >> "$${LOG_FILE}"
  exit 0
fi

# Rename to "itop" if needed
if [ "$${ITOP_DIR}" != "itop" ]; then
  mv "$${ITOP_DIR}" itop
fi

# -----------------------------
# 5. Permissions
# -----------------------------
chown -R apache:apache itop
chmod -R 755 itop

echo "===== iTop PoC bootstrap completed at $(date) ====="
echo "You should now be able to open: http://<EC2_PUBLIC_IP>/itop"