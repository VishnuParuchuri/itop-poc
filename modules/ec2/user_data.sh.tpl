#!/bin/bash
set -xe

LOG_FILE="/var/log/itop-userdata.log"
exec > >(tee -a "$${LOG_FILE}" | logger -t user-data -s 2>/dev/console) 2>&1

WEB_ROOT="${itop_web_root}"

echo "===== Starting iTop EC2 bootstrap ====="

# -----------------------------------
# 1. Fix curl conflict on AL2023 (if any)
# -----------------------------------
sudo dnf remove -y curl-minimal || true

# -----------------------------------
# 2. Install Apache + PHP + all required iTop extensions
# -----------------------------------
sudo dnf install -y --allowerasing \
    httpd \
    php \
    php-cli \
    php-mysqlnd \
    php-mbstring \
    php-json \
    php-xml \
    php-gd \
    php-soap \
    php-pdo \
    php-intl \
    php-process \
    php-pecl-zip \
    unzip \
    tar

systemctl enable httpd
systemctl start httpd

# Enable .htaccess support (required by iTop)
sed -i 's/AllowOverride None/AllowOverride All/g' /etc/httpd/conf/httpd.conf
systemctl restart httpd

# -----------------------------------
# 3. Create web root and redirect root → /itop
# -----------------------------------
mkdir -p "$${WEB_ROOT}"
cd "$${WEB_ROOT}"

cat > index.php <<'EOF'
<?php
header("Location: /itop");
exit;
?>
EOF

# -----------------------------------
# 4. Download and unpack iTop
# -----------------------------------
cd /tmp
curl -L "https://sourceforge.net/projects/itop/files/latest/download" -o itop.zip

unzip -o itop.zip -d /tmp/itop-src

ITOP_WEB_DIR=$$(find /tmp/itop-src -type d -name "web" | head -n 1)

mkdir -p "$${WEB_ROOT}/itop"
cp -r $${ITOP_WEB_DIR}/* "$${WEB_ROOT}/itop/"

# -----------------------------------
# 5. Permissions and final restart
# -----------------------------------
chown -R apache:apache "$${WEB_ROOT}"
chmod -R 755 "$${WEB_ROOT}"

systemctl restart httpd

echo "===== iTop installed successfully ====="
echo "Access at: http://<EC2_PUBLIC_IP>/itop"
